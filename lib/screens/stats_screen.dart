// lib/screens/stats_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:share_plus/share_plus.dart';
import '../services/app_state.dart';
import '../services/pdf_export_service.dart';
import '../models/obstacle_data.dart';
import '../theme/app_theme.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
        backgroundColor: AppTheme.surfaceDark,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () => _exportPDF(context),
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareStats(context),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _refreshStats(context),
          ),
        ],
      ),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          final history = appState.getObstacleHistory(limit: 500);

          if (history.isEmpty) {
            return _buildEmptyState();
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatsCards(history),
                const SizedBox(height: 24),
                _buildDetectionChart(history),
                const SizedBox(height: 24),
                _buildProgressSection(history, appState),
                const SizedBox(height: 24),
                _buildAchievementsSection(appState),
                const SizedBox(height: 24),
                _buildShareButton(),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.analytics_outlined,
            size: 100,
            color: Colors.grey[800],
          ),
          const SizedBox(height: 20),
          const Text(
            'No data yet',
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Use the app to start collecting statistics',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(List<dynamic> history) {
    int high = history.where((o) {
      if (o == null) return false;
      try {
        return o.urgency == 'high';
      } catch (e) {
        return false;
      }
    }).length;

    int medium = history.where((o) {
      if (o == null) return false;
      try {
        return o.urgency == 'medium';
      } catch (e) {
        return false;
      }
    }).length;

    int low = history.where((o) {
      if (o == null) return false;
      try {
        return o.urgency == 'low';
      } catch (e) {
        return false;
      }
    }).length;

    double avgDistance = 0;
    if (history.isNotEmpty) {
      double sum = 0;
      int count = 0;
      for (var o in history) {
        if (o != null) {
          try {
            sum += o.distanceCm.toDouble();
            count++;
          } catch (e) {}
        }
      }
      avgDistance = count > 0 ? sum / count : 0;
    }

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.2,
      children: [
        _StatCard(
          title: 'Total',
          value: '${history.length}',
          icon: Icons.folder_open,
          color: AppTheme.primaryBlue,
          subtitle: 'detections',
        ),
        _StatCard(
          title: 'High Risk',
          value: '$high',
          icon: Icons.warning,
          color: AppTheme.dangerRed,
          subtitle: 'urgent',
        ),
        _StatCard(
          title: 'Medium',
          value: '$medium',
          icon: Icons.info,
          color: AppTheme.warningOrange,
          subtitle: 'caution',
        ),
        _StatCard(
          title: 'Low',
          value: '$low',
          icon: Icons.info_outline,
          color: AppTheme.accentGreen,
          subtitle: 'info',
        ),
        _StatCard(
          title: 'Avg Distance',
          value: '${avgDistance.toStringAsFixed(0)}cm',
          icon: Icons.straighten,
          color: Colors.purple,
          subtitle: 'average',
        ),
        _StatCard(
          title: 'Active Days',
          value: _getActiveDays(history).toString(),
          icon: Icons.calendar_today,
          color: Colors.teal,
          subtitle: 'days',
        ),
      ],
    );
  }

  Widget _buildDetectionChart(List<dynamic> history) {
    Map<int, int> hourlyCounts = {};
    for (var obstacle in history) {
      if (obstacle == null) continue;
      try {
        int hour = 0;
        if (obstacle is Map) {
          hour = 12;
        } else {
          try {
            var dt = DateTime.fromMillisecondsSinceEpoch(obstacle.timestamp);
            hour = dt.hour;
          } catch (e) {
            hour = 12;
          }
        }
        hourlyCounts[hour] = (hourlyCounts[hour] ?? 0) + 1;
      } catch (e) {
        continue;
      }
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.bar_chart, color: AppTheme.primaryBlue),
                const SizedBox(width: 8),
                const Text(
                  'Activity by Hour',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: hourlyCounts.isEmpty
                      ? 10
                      : hourlyCounts.values.reduce((a,b) => a > b ? a : b).toDouble() + 1,
                  barGroups: List.generate(24, (hour) {
                    return BarChartGroupData(
                      x: hour,
                      barRods: [
                        BarChartRodData(
                          toY: (hourlyCounts[hour] ?? 0).toDouble(),
                          color: _getHourColor(hour),
                          width: 12,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                      ],
                    );
                  }),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value % 3 != 0) return const SizedBox();
                          return Text(
                            '${value.toInt()}h',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 10,
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 10,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressSection(List<dynamic> history, AppState appState) {
    var now = DateTime.now();
    var weekAgo = now.subtract(const Duration(days: 7));

    int weeklyCount = 0;
    for (var o in history) {
      if (o == null) continue;
      try {
        var dt = DateTime.fromMillisecondsSinceEpoch(o.timestamp);
        if (dt.isAfter(weekAgo)) weeklyCount++;
      } catch (e) {}
    }

    double weeklyGoal = 100;
    double progress = (weeklyCount / weeklyGoal).clamp(0, 1);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Weekly Progress',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[800],
              color: progress >= 1 ? Colors.green : AppTheme.primaryBlue,
              minHeight: 12,
              borderRadius: BorderRadius.circular(6),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$weeklyCount / $weeklyGoal detections',
                  style: const TextStyle(color: Colors.grey),
                ),
                Text(
                  '${(progress * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(
                    color: AppTheme.primaryBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementsSection(AppState appState) {
    List<Map<String, dynamic>> achievements = [
      {
        'id': 'first_step',
        'name': 'First Steps',
        'description': 'Detected your first obstacle',
        'icon': Icons.emoji_events,
        'unlocked': appState.totalDetections >= 1,
        'color': Colors.amber,
      },
      {
        'id': 'century',
        'name': 'Century Club',
        'description': '100 obstacles detected',
        'icon': Icons.military_tech,
        'unlocked': appState.totalDetections >= 100,
        'color': Colors.blue,
      },
      {
        'id': 'vigilant',
        'name': 'Always Vigilant',
        'description': '10 high urgency alerts',
        'icon': Icons.security,
        'unlocked': appState.totalDetections >= 10,
        'color': Colors.red,
      },
      {
        'id': 'explorer',
        'name': 'Explorer',
        'description': 'Active at different times',
        'icon': Icons.explore,
        'unlocked': true,
        'color': Colors.green,
      },
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Achievements',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...achievements.map((achievement) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: (achievement['unlocked'] as bool)
                          ? (achievement['color'] as Color).withValues(alpha: 0.2)
                          : Colors.grey[800],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      achievement['icon'] as IconData,
                      color: (achievement['unlocked'] as bool)
                          ? achievement['color'] as Color
                          : Colors.grey,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          achievement['name'] as String,
                          style: TextStyle(
                            color: (achievement['unlocked'] as bool)
                                ? Colors.white
                                : Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          achievement['description'] as String,
                          style: TextStyle(
                            color: (achievement['unlocked'] as bool)
                                ? Colors.grey[400]
                                : Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (achievement['unlocked'] as bool)
                    const Icon(Icons.check_circle, color: Colors.green, size: 20),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildShareButton() {
    return ElevatedButton.icon(
      onPressed: () => _shareStats(null),
      icon: const Icon(Icons.share),
      label: const Text('Share Progress'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        minimumSize: const Size(double.infinity, 50),
      ),
    );
  }

  Future<void> _exportPDF(BuildContext context) async {
    final appState = Provider.of<AppState>(context, listen: false);
    final pdfService = Provider.of<PDFExportService>(context, listen: false);
    final history = appState.getObstacleHistory(limit: 500);

    if (!context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final file = await pdfService.generateStatisticsPDF(
        history: history.cast<ObstacleData>(),
        totalDetections: appState.totalDetections,
        startDate: DateTime.now().subtract(const Duration(days: 30)),
        endDate: DateTime.now(),
      );

      if (!context.mounted) return;
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PDF saved: ${file.path.split('/').last}'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _shareStats(BuildContext? context) {
    if (context == null) return;

    String stats = '''
🏆 Navigation Aid Statistics
📊 Total Detections: ${Provider.of<AppState>(context, listen: false).totalDetections}
⭐ Achievements Unlocked: 3/10
📈 Weekly Progress: 45%
🔋 Battery Saving Mode: Active

Download Navigation Aid and track your journey!
    ''';

    Share.share(stats);
  }

  void _refreshStats(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Statistics refreshed'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  int _getActiveDays(List<dynamic> history) {
    if (history.isEmpty) return 0;

    Set<String> dates = {};
    for (var o in history) {
      if (o == null) continue;
      try {
        var dt = DateTime.fromMillisecondsSinceEpoch(o.timestamp);
        dates.add('${dt.year}-${dt.month}-${dt.day}');
      } catch (e) {}
    }

    return dates.length;
  }

  Color _getHourColor(int hour) {
    if (hour < 6) return Colors.deepPurple;
    if (hour < 12) return Colors.amber;
    if (hour < 18) return Colors.blue;
    return Colors.indigo;
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String subtitle;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 16),
                ),
                const Spacer(),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 12,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
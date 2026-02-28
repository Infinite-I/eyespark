// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import 'connection_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          return Column(
            children: [
              // Status Bar
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.grey[900],
                child: Row(
                  children: [
                    // Status indicator
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: appState.isConnected ? Colors.green : Colors.red,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      appState.isConnected ? 'Connected' : 'Disconnected',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    // Battery indicator (when connected)
                    if (appState.isConnected && appState.currentStatus != null)
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Icon(
                              Icons.battery_charging_full,
                              size: 16,
                              color: _getBatteryColor(
                                appState.currentStatus!.batteryPercent,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${appState.currentStatus!.batteryPercent}%',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),

                    const Spacer(),

                    // Connect button (when disconnected)
                    if (!appState.isConnected)
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ConnectionScreen(),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.blue.withValues(alpha: 0.1), // CORRIGÉ
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text(
                          'CONNECT',
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Main Content
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Detection Indicator
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 250,
                          height: 250,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: appState.currentObstacle != null
                                  ? _getUrgencyColor(
                                appState.currentObstacle!.urgency,
                              )
                                  : Colors.grey,
                              width: 4,
                            ),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Distance
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 300),
                                  child: Text(
                                    appState.currentObstacle != null
                                        ? '${appState.currentObstacle!.distanceCm}'
                                        : '---',
                                    key: ValueKey<String>(
                                      appState.currentObstacle != null
                                          ? 'obstacle-${appState.currentObstacle!.distanceCm}'
                                          : 'no-obstacle',
                                    ),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 48,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                if (appState.currentObstacle != null)
                                  Text(
                                    'cm',
                                    style: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 18,
                                    ),
                                  ),
                                const SizedBox(height: 8),

                                // Direction badge
                                if (appState.currentObstacle != null)
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getUrgencyColor(
                                        appState.currentObstacle!.urgency,
                                      ).withValues(alpha: 0.2), // CORRIGÉ
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          _getDirectionIcon(
                                            appState.currentObstacle!.direction,
                                          ),
                                          color: _getUrgencyColor(
                                            appState.currentObstacle!.urgency,
                                          ),
                                          size: 14,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          appState.currentObstacle!.direction,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Status Message
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: _buildStatusMessage(appState),
                        ),

                        const SizedBox(height: 48),

                        // Test Controls Button
                        if (appState.isInitialized)
                          ElevatedButton.icon(
                            onPressed: () {
                              _showTestControls(context, appState);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            icon: const Icon(Icons.science, color: Colors.white),
                            label: const Text(
                              'TEST CONTROLS',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                        const SizedBox(height: 24),

                        // Error Message
                        if (appState.lastError != null)
                          _buildErrorMessage(appState.lastError!),

                        // Total detections counter
                        if (appState.totalDetections > 0)
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              'Total detections: ${appState.totalDetections}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatusMessage(AppState appState) {
    if (!appState.isConnected) {
      return const Text(
        'Connect your device to begin',
        key: ValueKey('connect-message'),
        style: TextStyle(
          color: Colors.grey,
          fontSize: 16,
        ),
      );
    } else if (appState.currentObstacle == null) {
      return const Text(
        'No obstacles detected',
        key: ValueKey('no-obstacle-message'),
        style: TextStyle(
          color: Colors.grey,
          fontSize: 16,
        ),
      );
    } else {
      return const SizedBox.shrink(key: ValueKey('empty'));
    }
  }

  Widget _buildErrorMessage(String error) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1), // CORRIGÉ
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red),
      ),
      child: Row(
        children: [
          const Icon(Icons.error, color: Colors.red, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              error,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getUrgencyColor(String urgency) {
    switch (urgency.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.blue;
    }
  }

  Color _getBatteryColor(int percent) {
    if (percent > 60) return Colors.green;
    if (percent > 20) return Colors.orange;
    return Colors.red;
  }

  IconData _getDirectionIcon(String direction) {
    switch (direction.toLowerCase()) {
      case 'front':
        return Icons.arrow_upward;
      case 'left':
        return Icons.arrow_back;
      case 'right':
        return Icons.arrow_forward;
      case 'behind':
        return Icons.arrow_downward;
      default:
        return Icons.circle;
    }
  }

  void _showTestControls(BuildContext context, AppState appState) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1E1E1E),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[600],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),

              // Title
              const Text(
                'TEST CONTROLS',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Simulate obstacle detection',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),

              // Connection test buttons
              Row(
                children: [
                  Expanded(
                    child: _buildConnectionButton(
                      'Connect',
                      Icons.bluetooth,
                      Colors.green,
                          () {
                        Navigator.pop(context);
                        appState.testConnect();
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildConnectionButton(
                      'Disconnect',
                      Icons.bluetooth_disabled,
                      Colors.red,
                          () {
                        Navigator.pop(context);
                        appState.testDisconnect();
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              const Divider(color: Colors.grey),
              const SizedBox(height: 16),

              // Distance buttons
              const Text(
                'Distance',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildTestButton(
                    'Close',
                    '30 cm',
                    Colors.orange,
                        () {
                      Navigator.pop(context);
                      appState.testObstacle(30, 'front', 'high');
                    },
                  ),
                  _buildTestButton(
                    'Medium',
                    '100 cm',
                    Colors.yellow,
                        () {
                      Navigator.pop(context);
                      appState.testObstacle(100, 'front', 'medium');
                    },
                  ),
                  _buildTestButton(
                    'Far',
                    '200 cm',
                    Colors.green,
                        () {
                      Navigator.pop(context);
                      appState.testObstacle(200, 'front', 'low');
                    },
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Direction buttons
              const Text(
                'Direction',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildDirectionButton(
                    'Front',
                    Icons.arrow_upward,
                        () {
                      Navigator.pop(context);
                      appState.testObstacle(100, 'front', 'medium');
                    },
                  ),
                  _buildDirectionButton(
                    'Left',
                    Icons.arrow_back,
                        () {
                      Navigator.pop(context);
                      appState.testObstacle(100, 'left', 'medium');
                    },
                  ),
                  _buildDirectionButton(
                    'Right',
                    Icons.arrow_forward,
                        () {
                      Navigator.pop(context);
                      appState.testObstacle(100, 'right', 'medium');
                    },
                  ),
                  _buildDirectionButton(
                    'Behind',
                    Icons.arrow_downward,
                        () {
                      Navigator.pop(context);
                      appState.testObstacle(100, 'behind', 'low');
                    },
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Clear and Close buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        appState.clearObstacle();
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(Icons.clear, size: 18),
                      label: const Text('CLEAR'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[800],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('CLOSE'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTestButton(String label, String distance, Color color, VoidCallback onPressed) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                distance,
                style: const TextStyle(
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDirectionButton(String label, IconData icon, VoidCallback onPressed) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: const BorderSide(color: Colors.grey),
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConnectionButton(String label, IconData icon, Color color, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withValues(alpha: 0.1), // CORRIGÉ
        foregroundColor: color,
        side: BorderSide(color: color),
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
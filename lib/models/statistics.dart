// lib/models/statistics.dart
import 'package:hive/hive.dart';
import 'obstacle_data.dart';

part 'statistics.g.dart';

@HiveType(typeId: 3)
class Statistics {
  @HiveField(0)
  int totalDetections;

  @HiveField(1)
  int highUrgencyCount;

  @HiveField(2)
  int mediumUrgencyCount;

  @HiveField(3)
  int lowUrgencyCount;

  @HiveField(4)
  double averageDistance;

  @HiveField(5)
  DateTime firstUse;

  @HiveField(6)
  DateTime lastUse;

  @HiveField(7)
  List<double> recentDistances;

  @HiveField(8)
  Map<String, int> detectionsByHour;

  @HiveField(9)
  List<String> achievements;

  Statistics({
    this.totalDetections = 0,
    this.highUrgencyCount = 0,
    this.mediumUrgencyCount = 0,
    this.lowUrgencyCount = 0,
    this.averageDistance = 0,
    DateTime? firstUse,
    DateTime? lastUse,
    List<double>? recentDistances,
    Map<String, int>? detectionsByHour,
    List<String>? achievements,
  }) : firstUse = firstUse ?? DateTime.now(),
        lastUse = lastUse ?? DateTime.now(),
        recentDistances = recentDistances ?? [],
        detectionsByHour = detectionsByHour ?? {},
        achievements = achievements ?? [];

  // Mettre à jour avec un nouvel obstacle
  void updateWithObstacle(ObstacleData obstacle) {
    totalDetections++;
    lastUse = DateTime.now();

    // Compter par urgence
    switch (obstacle.urgency) {
      case 'high':
        highUrgencyCount++;
        break;
      case 'medium':
        mediumUrgencyCount++;
        break;
      case 'low':
        lowUrgencyCount++;
        break;
    }

    // Distance moyenne
    recentDistances.add(obstacle.distanceCm.toDouble());
    if (recentDistances.length > 50) {
      recentDistances.removeAt(0);
    }
    averageDistance = recentDistances.reduce((a,b) => a + b) / recentDistances.length;

    // Par heure
    var hour = obstacle.getDateTime().hour.toString();
    detectionsByHour[hour] = (detectionsByHour[hour] ?? 0) + 1;

    // Vérifier les achievements
    _checkAchievements();
  }

  void _checkAchievements() {
    // Achievement: Premier obstacle
    if (totalDetections == 1 && !achievements.contains('first_step')) {
      achievements.add('first_step');
    }

    // Achievement: 100 détections
    if (totalDetections >= 100 && !achievements.contains('century')) {
      achievements.add('century');
    }

    // Achievement: Vigilant (10 urgences hautes)
    if (highUrgencyCount >= 10 && !achievements.contains('vigilant')) {
      achievements.add('vigilant');
    }

    // Achievement: Explorateur (utilisé à différentes heures)
    if (detectionsByHour.length >= 12 && !achievements.contains('explorer')) {
      achievements.add('explorer');
    }
  }

  // Obtenir les achievements avec descriptions
  Map<String, String> getAchievementsWithDescription() {
    return {
      'first_step': '🎯 First Detection - You detected your first obstacle!',
      'century': '💯 Century Club - 100 obstacles detected!',
      'vigilant': '🛡️ Always Vigilant - 10 high urgency alerts!',
      'explorer': '🗺️ Explorer - Active at 12 different hours!',
      'master': '👑 Master - 500 total detections',
      'night_owl': '🦉 Night Owl - Active after midnight',
      'early_bird': '🐦 Early Bird - Active before 6 AM',
    };
  }

  double getImprovementRate() {
    if (recentDistances.length < 20) return 0;

    var recent = recentDistances.sublist(recentDistances.length - 10);
    var older = recentDistances.sublist(0, recentDistances.length - 10);

    if (older.isEmpty) return 0;

    double recentAvg = recent.reduce((a,b) => a+b) / recent.length;
    double olderAvg = older.reduce((a,b) => a+b) / older.length;

    return ((olderAvg - recentAvg) / olderAvg * 100).clamp(-100, 100);
  }

  String getRiskLevel() {
    double highRatio = highUrgencyCount / totalDetections;
    if (highRatio > 0.3) return 'High Risk Area';
    if (highRatio > 0.15) return 'Moderate Risk';
    return 'Safe Zone';
  }
}
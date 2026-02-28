// lib/models/obstacle_data.dart
import 'package:hive/hive.dart';

part 'obstacle_data.g.dart';

@HiveType(typeId: 0)
class ObstacleData {
  @HiveField(0)
  final String type;

  @HiveField(1)
  final int timestamp;

  @HiveField(2)
  final int distanceCm;

  @HiveField(3)
  final String direction;

  @HiveField(4)
  final double confidence;

  @HiveField(5)
  final String obstacleType;

  @HiveField(6)
  final String urgency;

  ObstacleData({
    required this.type,
    required this.timestamp,
    required this.distanceCm,
    required this.direction,
    required this.confidence,
    required this.obstacleType,
    required this.urgency,
  });

  factory ObstacleData.fromJson(Map<String, dynamic> json) {
    return ObstacleData(
      type: json['type'] ?? 'obstacle',
      timestamp: json['timestamp'] ?? DateTime.now().millisecondsSinceEpoch,
      distanceCm: json['data']?['distance_cm'] ?? 0,
      direction: json['data']?['direction'] ?? 'unknown',
      confidence: (json['data']?['confidence'] ?? 0.0).toDouble(),
      obstacleType: json['data']?['obstacle_type'] ?? 'unknown',
      urgency: json['data']?['urgency'] ?? 'low',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'timestamp': timestamp,
      'data': {
        'distance_cm': distanceCm,
        'direction': direction,
        'confidence': confidence,
        'obstacle_type': obstacleType,
        'urgency': urgency,
      }
    };
  }

  DateTime getDateTime() {
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }
}
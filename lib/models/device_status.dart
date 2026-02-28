// lib/models/device_status.dart
import 'package:hive/hive.dart';

part 'device_status.g.dart';

@HiveType(typeId: 1)
class DeviceStatus {
  @HiveField(0)
  final String type;

  @HiveField(1)
  final int timestamp;

  @HiveField(2)
  final int batteryPercent;

  @HiveField(3)
  final double batteryVoltage;

  @HiveField(4)
  final double temperatureC;

  @HiveField(5)
  final int uptimeSeconds;

  @HiveField(6)
  final String cameraStatus;

  @HiveField(7)
  final List<String> errors;

  DeviceStatus({
    required this.type,
    required this.timestamp,
    required this.batteryPercent,
    required this.batteryVoltage,
    required this.temperatureC,
    required this.uptimeSeconds,
    required this.cameraStatus,
    this.errors = const [],
  });

  factory DeviceStatus.fromJson(Map<String, dynamic> json) {
    return DeviceStatus(
      type: json['type'] ?? 'status',
      timestamp: json['timestamp'] ?? DateTime.now().millisecondsSinceEpoch,
      batteryPercent: json['data']?['battery_percent'] ?? 0,
      batteryVoltage: (json['data']?['battery_voltage'] ?? 0.0).toDouble(),
      temperatureC: (json['data']?['temperature_c'] ?? 0.0).toDouble(),
      uptimeSeconds: json['data']?['uptime_seconds'] ?? 0,
      cameraStatus: json['data']?['camera_status'] ?? 'unknown',
      errors: List<String>.from(json['data']?['errors'] ?? []),
    );
  }

  String getUptimeFormatted() {
    final hours = uptimeSeconds ~/ 3600;
    final minutes = (uptimeSeconds % 3600) ~/ 60;
    return '$hours h $minutes min';
  }

  bool isHealthy() {
    return batteryPercent > 20 &&
        temperatureC < 45 &&
        cameraStatus == 'active' &&
        errors.isEmpty;
  }
}
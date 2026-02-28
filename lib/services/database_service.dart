// lib/services/database_service.dart
import 'package:flutter/material.dart'; // AJOUTEZ CET IMPORT
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import '../models/obstacle_data.dart';
import '../models/device_status.dart';
import '../models/user_settings.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  late Box<ObstacleData> obstacleBox;
  late Box<DeviceStatus> statusBox;
  late Box<UserSettings> settingsBox;

  Future<void> initialize() async {
    try {
      // Initialiser Hive
      final appDocumentDir = await path_provider.getApplicationDocumentsDirectory();
      Hive.init(appDocumentDir.path);

      // Enregistrer les adaptateurs
      Hive.registerAdapter(ObstacleDataAdapter());
      Hive.registerAdapter(DeviceStatusAdapter());
      Hive.registerAdapter(UserSettingsAdapter());

      // Ouvrir les boxes
      obstacleBox = await Hive.openBox<ObstacleData>('obstacles');
      statusBox = await Hive.openBox<DeviceStatus>('device_status');
      settingsBox = await Hive.openBox<UserSettings>('user_settings');

      debugPrint('✅ Database initialized');
    } catch (e) {
      debugPrint('❌ Database initialization error: $e');
      rethrow;
    }
  }

  // ========== MÉTHODES OBSTACLES ==========

  Future<void> saveObstacle(ObstacleData obstacle) async {
    try {
      await obstacleBox.add(obstacle);
      debugPrint('💾 Obstacle saved to database');
    } catch (e) {
      debugPrint('❌ Error saving obstacle: $e');
      rethrow;
    }
  }

  List<ObstacleData> getObstacles({int? limit}) {
    try {
      List<ObstacleData> obstacles = obstacleBox.values.toList();
      // Trier du plus récent au plus ancien
      obstacles.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      if (limit != null && obstacles.length > limit) {
        return obstacles.sublist(0, limit);
      }
      return obstacles;
    } catch (e) {
      debugPrint('❌ Error getting obstacles: $e');
      return [];
    }
  }

  // MÉTHODE POUR EFFACER LES OBSTACLES
  Future<void> clearObstacles() async {
    try {
      await obstacleBox.clear();
      debugPrint('🗑️ All obstacles cleared from database');
    } catch (e) {
      debugPrint('❌ Error clearing obstacles: $e');
      rethrow;
    }
  }

  // ========== MÉTHODES STATUS ==========

  Future<void> saveStatus(DeviceStatus status) async {
    try {
      await statusBox.add(status);
      debugPrint('💾 Status saved to database');
    } catch (e) {
      debugPrint('❌ Error saving status: $e');
      rethrow;
    }
  }

  DeviceStatus? getLatestStatus() {
    try {
      if (statusBox.isEmpty) return null;
      return statusBox.values.last;
    } catch (e) {
      debugPrint('❌ Error getting latest status: $e');
      return null;
    }
  }

  // ========== MÉTHODES PARAMÈTRES ==========

  Future<void> saveSettings(UserSettings settings) async {
    try {
      await settingsBox.put('current', settings);
      debugPrint('💾 Settings saved to database');
    } catch (e) {
      debugPrint('❌ Error saving settings: $e');
      rethrow;
    }
  }

  Future<UserSettings?> getSettings() async {
    try {
      return settingsBox.get('current');
    } catch (e) {
      debugPrint('❌ Error getting settings: $e');
      return null;
    }
  }

  // ========== MÉTHODES UTILITAIRES ==========

  Future<void> close() async {
    await obstacleBox.close();
    await statusBox.close();
    await settingsBox.close();
    debugPrint('📦 Database closed');
  }
}
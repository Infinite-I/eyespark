// lib/services/app_state.dart
import 'package:flutter/material.dart';
import 'dart:async';
import '../models/obstacle_data.dart';
import '../models/device_status.dart';
import '../models/user_settings.dart';
import 'ble_service.dart';
import 'database_service.dart';
import 'tts_service.dart';
import 'voice_command_service.dart';

class AppState extends ChangeNotifier {
  final BLEService bleService = BLEService();
  final DatabaseService dbService = DatabaseService();
  final TTSService ttsService = TTSService();

  ObstacleData? currentObstacle;
  DeviceStatus? currentStatus;
  UserSettings settings = UserSettings();

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  bool get isConnected => bleService.isConnected;
  bool get isScanning => bleService.isScanning;

  String? _lastError;
  String? get lastError => _lastError;

  int _totalDetections = 0;
  int get totalDetections => _totalDetections;

  final List<StreamSubscription> _subscriptions = [];

  void _setError(String message) {
    _lastError = message;
    notifyListeners();
    Future.delayed(const Duration(seconds: 5), () {
      if (_lastError == message) {
        _lastError = null;
        notifyListeners();
      }
    });
  }

  Future<void> initialize() async {
    try {
      debugPrint('🔄 Initializing AppState...');

      await dbService.initialize();
      await bleService.initialize();
      await ttsService.initialize();

      final loadedSettings = await dbService.getSettings();
      settings = loadedSettings ?? UserSettings();

      ttsService.setEnabled(settings.voiceEnabled);

      _subscriptions.add(bleService.obstacleStream.listen((obstacle) {
        currentObstacle = obstacle;
        dbService.saveObstacle(obstacle);
        _totalDetections++;
        ttsService.announceObstacle(
          obstacle.distanceCm,
          obstacle.direction,
          obstacle.urgency,
        );
        notifyListeners();
        debugPrint('📡 Obstacle detected: ${obstacle.distanceCm}cm');
      }));

      _subscriptions.add(bleService.statusStream.listen((status) {
        currentStatus = status;
        notifyListeners();
        debugPrint('📊 Device status updated: ${status.batteryPercent}%');
      }));

      bleService.addListener(() {
        if (bleService.lastError != null) {
          _setError(bleService.lastError!);
        }
        notifyListeners();
      });

      _isInitialized = true;
      notifyListeners();
      debugPrint('✅ AppState initialized successfully');

      ttsService.speak('Navigation assistant ready');
    } catch (e) {
      _setError('Initialization error: $e');
      debugPrint('❌ AppState initialization error: $e');
    }
  }

  // Setup voice commands
  void setupVoiceCommands(VoiceCommandService voiceService) {
    voiceService.onStatusRequested = () {
      ttsService.speak('Status: ${isConnected ? "Connected" : "Disconnected"}. '
          'Total detections: $totalDetections');
    };

    voiceService.onStopRequested = () {
      ttsService.setEnabled(false);
      Future.delayed(const Duration(seconds: 10), () {
        ttsService.setEnabled(true);
      });
      _setError('Voice alerts stopped for 10 seconds');
    };

    voiceService.onHelpRequested = () {
      ttsService.speak(voiceService.getCommandList());
    };

    voiceService.onSettingsRequested = () {
      ttsService.speak('Opening settings');
    };

    voiceService.onHistoryRequested = () {
      ttsService.speak('Opening history');
    };

    voiceService.onConnectRequested = () {
      startScan();
      ttsService.speak('Starting Bluetooth scan');
    };

    voiceService.onDisconnectRequested = () {
      disconnect();
    };

    voiceService.onPhotoRequested = () {
      ttsService.speak('Taking photo');
    };

    voiceService.onFlashOnRequested = () {
      ttsService.speak('Flash on');
    };

    voiceService.onFlashOffRequested = () {
      ttsService.speak('Flash off');
    };

    voiceService.onStartStreamRequested = () {
      ttsService.speak('Starting video stream');
    };

    voiceService.onStopStreamRequested = () {
      ttsService.speak('Stopping video stream');
    };

    voiceService.onWhereAmIRequested = () async {
      ttsService.speak('Current position not available');
    };

    voiceService.onExportPDFRequested = () {
      ttsService.speak('Exporting PDF report');
    };
  }

  Future<void> startScan() async {
    try {
      debugPrint('🔍 Starting BLE scan...');
      await bleService.startScan();
    } catch (e) {
      _setError('Scan error: $e');
      debugPrint('❌ Scan error: $e');
    }
  }

  Future<void> stopScan() async {
    try {
      await bleService.stopScan();
      debugPrint('🛑 Scan stopped');
    } catch (e) {
      _setError('Stop scan error: $e');
    }
  }

  Future<bool> connectToDevice(dynamic device) async {
    try {
      debugPrint('🔌 Connecting to device...');
      bool success = await bleService.connectToDevice(device);
      if (success) {
        await updateSettings(settings);
        ttsService.speak('Device connected');
        debugPrint('✅ Device connected successfully');
      }
      return success;
    } catch (e) {
      _setError('Connection error: $e');
      debugPrint('❌ Connection error: $e');
      return false;
    }
  }

  Future<void> disconnect() async {
    try {
      debugPrint('🔌 Disconnecting...');
      await bleService.disconnect();
      currentObstacle = null;
      currentStatus = null;
      notifyListeners();
      ttsService.speak('Device disconnected');
      debugPrint('✅ Device disconnected');
    } catch (e) {
      _setError('Disconnect error: $e');
      debugPrint('❌ Disconnect error: $e');
    }
  }

  List<dynamic> getDiscoveredDevices() {
    return bleService.getDiscoveredDevices();
  }

  void testObstacle(int distanceCm, String direction, String urgency) {
    debugPrint('🧪 Test obstacle: $distanceCm cm, $direction, $urgency');

    final testObstacle = ObstacleData(
      type: 'obstacle',
      timestamp: DateTime.now().millisecondsSinceEpoch,
      distanceCm: distanceCm,
      direction: direction,
      confidence: 0.95,
      obstacleType: 'test',
      urgency: urgency,
    );

    currentObstacle = testObstacle;
    dbService.saveObstacle(testObstacle);
    _totalDetections++;
    ttsService.announceObstacle(distanceCm, direction, urgency);
    notifyListeners();

    debugPrint('✅ Test obstacle created');
  }

  void testObstacleWithDirection(String direction) {
    int distance = 100;
    String urgency = 'medium';

    switch (direction) {
      case 'front':
        urgency = 'high';
        break;
      case 'left':
      case 'right':
        urgency = 'medium';
        break;
      case 'behind':
        urgency = 'low';
        break;
    }

    testObstacle(distance, direction, urgency);
  }

  void clearObstacle() {
    debugPrint('🧹 Clearing obstacle');
    currentObstacle = null;
    notifyListeners();
    ttsService.speak('Clear path');
    debugPrint('✅ Obstacle cleared');
  }

  void testConnect() {
    debugPrint('🧪 Test connection');
    currentStatus = DeviceStatus(
      type: 'status',
      timestamp: DateTime.now().millisecondsSinceEpoch,
      batteryPercent: 85,
      batteryVoltage: 3.7,
      temperatureC: 32.5,
      uptimeSeconds: 3600,
      cameraStatus: 'active',
      errors: const [],
    );
    notifyListeners();
    ttsService.speak('Device connected (test mode)');
    debugPrint('✅ Test connection activated');
  }

  void testDisconnect() {
    debugPrint('🧪 Test disconnection');
    currentObstacle = null;
    currentStatus = null;
    notifyListeners();
    ttsService.speak('Device disconnected');
    debugPrint('✅ Test disconnection activated');
  }

  List<ObstacleData> getObstacleHistory({int? limit}) {
    try {
      return dbService.getObstacles(limit: limit);
    } catch (e) {
      _setError('Error loading history: $e');
      debugPrint('❌ History error: $e');
      return [];
    }
  }

  Future<void> clearHistory() async {
    try {
      debugPrint('🗑️ Clearing history...');
      await dbService.clearObstacles();
      _totalDetections = 0;
      notifyListeners();
      debugPrint('✅ History cleared');
    } catch (e) {
      _setError('Error clearing history: $e');
      debugPrint('❌ Clear history error: $e');
    }
  }

  Future<void> updateSettings(UserSettings newSettings) async {
    try {
      debugPrint('⚙️ Updating settings...');
      settings = newSettings;
      await dbService.saveSettings(newSettings);
      ttsService.setEnabled(newSettings.voiceEnabled);

      if (bleService.isConnected) {
        try {
          await bleService.writeSettings(newSettings);
          debugPrint('✅ Settings sent to device');
        } catch (e) {
          _setError('Could not send settings to device');
          debugPrint('❌ Error sending settings: $e');
        }
      }

      notifyListeners();
      debugPrint('✅ Settings updated');
    } catch (e) {
      _setError('Error updating settings: $e');
      debugPrint('❌ Update settings error: $e');
    }
  }

  String getBatteryInfo() {
    if (currentStatus == null) return 'N/A';
    return '${currentStatus!.batteryPercent}%';
  }

  bool isDeviceHealthy() {
    return currentStatus?.isHealthy() ?? false;
  }

  void reset() {
    debugPrint('🔄 Resetting AppState');
    currentObstacle = null;
    currentStatus = null;
    _lastError = null;
    _totalDetections = 0;
    notifyListeners();
    debugPrint('✅ AppState reset');
  }

  @override
  void dispose() {
    debugPrint('🗑️ Disposing AppState');
    for (var sub in _subscriptions) {
      sub.cancel();
    }
    bleService.dispose();
    ttsService.dispose();
    super.dispose();
  }
}
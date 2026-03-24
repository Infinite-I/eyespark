import 'dart:ui';

import 'package:flutter/foundation.dart';

/// Represents a detected object for UI display.
class DetectedObjectInfo {
  final String label;
  final Rect boundingBox;
  final double confidence;

  DetectedObjectInfo({
    required this.label,
    required this.boundingBox,
    required this.confidence,
  });
}

class AppState extends ChangeNotifier {
  // Camera
  bool _cameraReady = false;
  bool get cameraReady => _cameraReady;
  set cameraReady(bool value) {
    _cameraReady = value;
    notifyListeners();
  }

  // Detected objects (from ML Kit)
  List<DetectedObjectInfo> _detectedObjects = [];
  List<DetectedObjectInfo> get detectedObjects => List.unmodifiable(_detectedObjects);
  set detectedObjects(List<DetectedObjectInfo> value) {
    _detectedObjects = value;
    notifyListeners();
  }

  // Bluetooth
  bool _bluetoothConnected = false;
  String _bluetoothDeviceName = '';
  bool get bluetoothConnected => _bluetoothConnected;
  String get bluetoothDeviceName => _bluetoothDeviceName;
  void setBluetoothStatus(bool connected, [String deviceName = '']) {
    _bluetoothConnected = connected;
    _bluetoothDeviceName = deviceName;
    notifyListeners();
  }

  // Voice / Listening
  bool _isListening = false;
  bool get isListening => _isListening;
  set isListening(bool value) {
    _isListening = value;
    notifyListeners();
  }

  // Last command / status message
  String _lastCommand = '';
  String get lastCommand => _lastCommand;
  set lastCommand(String value) {
    _lastCommand = value;
    notifyListeners();
  }

  // History for bottom panel
  final List<String> _history = [];
  List<String> get history => List.unmodifiable(_history);
  void addHistory(String entry) {
    _history.insert(0, entry);
    notifyListeners();
  }

  void setCommand(String cmd) {
    _lastCommand = cmd;
    notifyListeners();
  }

  // Obstacle alert (for "stop" or high-risk detection)
  bool _obstacleDetected = false;
  bool get obstacleDetected => _obstacleDetected;
  set obstacleDetected(bool value) {
    _obstacleDetected = value;
    notifyListeners();
  }

  // Last processed image size (for overlay coordinate mapping)
  Size _lastImageSize = Size.zero;
  Size get lastImageSize => _lastImageSize;
  set lastImageSize(Size value) {
    _lastImageSize = value;
    notifyListeners();
  }
}

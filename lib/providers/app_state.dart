import 'package:flutter/material.dart';
import '../models/detected_object.dart';
import '../models/command.dart';

class AppState extends ChangeNotifier {
  // 🎥 CAMERA STATE
  bool cameraReady = false;

  // 👁️ DETECTION STATE
  List<DetectedObject> _objects = [];
  Size lastImageSize = Size.zero;

  List<DetectedObject> get objects => _objects;

  set objects(List<DetectedObject> value) {
    _objects = value;
    _checkObstacle();
    notifyListeners();
  }

  // 🚨 OBSTACLE STATE
  bool _obstacleDetected = false;
  bool get obstacleDetected => _obstacleDetected;

  void _checkObstacle() {
    _obstacleDetected = _objects.any((o) => o.isObstacle);
  }

  // 🔵 BLUETOOTH STATE
  bool bluetoothConnected = false;
  String bluetoothDeviceName = '';

  void setBluetoothStatus(bool connected, [String name = '']) {
    bluetoothConnected = connected;
    bluetoothDeviceName = name;
    notifyListeners();
  }

  // 🎤 VOICE STATE
  bool isListening = false;
  String lastCommand = '';

  void setListening(bool value) {
    isListening = value;
    notifyListeners();
  }

  void setCommand(String command) {
    lastCommand = command;
    notifyListeners();
  }

  // 📜 COMMAND HISTORY
  final List<String> _history = [];

  List<String> get history => _history;

  void addHistory(String item) {
    _history.insert(0, item);
    notifyListeners();
  }

  // 🎯 COMMAND PROCESSING
  Command? _currentCommand;

  Command? get currentCommand => _currentCommand;

  void processCommand(String text) {
    final cmd = Command.fromText(text);
    _currentCommand = cmd;

    addHistory("🎤 $text");
    notifyListeners();
  }

  // 🔄 RESET SYSTEM
  void reset() {
    _objects = [];
    _obstacleDetected = false;
    lastCommand = '';
    _history.clear();
    notifyListeners();
  }
}
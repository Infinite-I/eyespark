import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TTSService extends ChangeNotifier {
  static final TTSService _instance = TTSService._internal();
  factory TTSService() => _instance;
  TTSService._internal();

  late FlutterTts _flutterTts;
  bool _isInitialized = false;
  bool _enabled = true;

  Future<void> initialize() async {
    if (_isInitialized) return;

    _flutterTts = FlutterTts();
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(0.5);

    _isInitialized = true;
    speak("Visual assist system ready");
  }

  Future<void> speak(String text) async {
    if (!_enabled || !_isInitialized) return;
    await _flutterTts.speak(text);
  }

  Future<void> announceObstacle(int distanceCm, String direction, String urgency) async {
    String announcement;
    if (urgency == 'high') {
      announcement = "Warning! Obstacle $direction, $distanceCm centimeters";
    } else if (urgency == 'medium') {
      announcement = "Caution. Obstacle $direction, $distanceCm centimeters";
    } else {
      announcement = "Object detected $direction";
    }
    await speak(announcement);
  }

  void setEnabled(bool value) {
    _enabled = value;
    notifyListeners();
  }

  Future<void> testVoice() async {
    await speak("This is a test of the voice feedback system.");
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }
}
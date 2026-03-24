import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TTSService {
  final FlutterTts _tts = FlutterTts();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    try {
      await _tts.setSpeechRate(0.5);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
      await _tts.awaitSpeakCompletion(true);
      _initialized = true;
    } catch (e) {
      debugPrint('TTS init error: $e');
    }
  }

  Future<void> speak(String text) async {
    if (text.isEmpty) return;
    await init();
    await _tts.speak(text);
  }

  Future<void> speakWarning(String text) async {
    if (text.isEmpty) return;
    await init();
    await _tts.setPitch(0.9);
    await _tts.setSpeechRate(0.6);
    await _tts.speak(text);
    await _tts.setPitch(1.0);
    await _tts.setSpeechRate(0.5);
  }

  Future<void> stop() async {
    await _tts.stop();
  }
}

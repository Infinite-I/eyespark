import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';

class VoiceService {
  final SpeechToText _speech = SpeechToText();
  bool _initialized = false;

  bool get isAvailable => _initialized;

  Future<bool> init() async {
    if (_initialized) return true;
    _initialized = await _speech.initialize(
      onStatus: (status) => debugPrint('Speech status: $status'),
      onError: (error) => debugPrint('Speech error: $error'),
    );
    return _initialized;
  }

  /// Listen for voice input. Calls onResult when user stops speaking.
  Future<void> listen({
    required Function(String) onResult,
    Function(String)? onError,
  }) async {
    if (!_initialized) {
      final ok = await init();
      if (!ok) {
        onError?.call('Speech recognition not available');
        return;
      }
    }

    await _speech.listen(
      onResult: (result) {
        if (result.finalResult && result.recognizedWords.isNotEmpty) {
          onResult(result.recognizedWords);
          _speech.stop();
        }
      },
      listenFor: const Duration(seconds: 10),
      pauseFor: const Duration(seconds: 3),
    );
  }

  Future<void> stop() async {
    await _speech.stop();
  }
}

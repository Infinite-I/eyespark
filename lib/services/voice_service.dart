import 'package:speech_to_text/speech_to_text.dart';

class VoiceService {
  final SpeechToText _speech = SpeechToText();

  Future<void> init() async {
    await _speech.initialize();
  }

  void listen(Function(String) onResult) {
    _speech.listen(
      onResult: (res) {
        if (res.finalResult) {
          onResult(res.recognizedWords);
        }
      },
    );
  }

  void stop() {
    _speech.stop();
  }
}
import '../models/command.dart';
import '../providers/app_state.dart';
import 'tts_service.dart';

class CommandProcessor {
  final TTSService tts;

  CommandProcessor(this.tts);

  void process(String text, AppState state) {
    final cmd = Command.fromText(text);

    switch (cmd.type) {
      case CommandType.scan:
        tts.speak("Scanning environment");
        break;

      case CommandType.navigate:
        tts.speak("Starting navigation");
        break;

      case CommandType.stop:
        tts.speak("Stopping");
        break;

      default:
        tts.speak("Command not recognized");
    }
  }
}
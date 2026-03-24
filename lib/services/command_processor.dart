import '../providers/app_state.dart';
import 'tts_service.dart';

class CommandProcessor {
  final TTSService tts;

  CommandProcessor(this.tts);

  void process(String command, AppState state) {
    final normalized = command.toLowerCase().trim();

    if (normalized.contains('scan') || normalized.contains('what do you see')) {
      _handleScan(state);
      return;
    }

    if (normalized.contains("what's ahead") ||
        normalized.contains('whats ahead') ||
        normalized.contains('ahead')) {
      _handleWhatsAhead(state);
      return;
    }

    if (normalized.contains('stop') || normalized.contains('halt')) {
      _handleStop(state);
      return;
    }

    if (normalized.contains('clear') ||
        normalized.contains('ok') ||
        normalized.contains('okay') ||
        normalized.contains('go')) {
      state.obstacleDetected = false;
      tts.speak('Cleared. You may proceed.');
      return;
    }

    if (normalized.contains('hello') || normalized.contains('hi')) {
      tts.speak('Hello! I am your assistive navigator. Say "scan" to detect objects, or "what\'s ahead" to hear what I see.');
      return;
    }

    tts.speak('I heard "${command.trim()}". Try saying "scan", "what\'s ahead", or "stop".');
  }

  void _handleScan(AppState state) {
    final objects = state.detectedObjects;
    if (objects.isEmpty) {
      tts.speak('I don\'t see any objects right now. The view might be clear, or detection is still starting.');
    } else {
      final names = objects
          .take(5)
          .map((o) => '${o.label} (${(o.confidence * 100).round()}% confidence)')
          .join(', ');
      tts.speak('I see: $names');
    }
  }

  void _handleWhatsAhead(AppState state) {
    final objects = state.detectedObjects;
    if (objects.isEmpty) {
      tts.speak('The path ahead appears clear.');
    } else {
      state.obstacleDetected = true;
      final nearest = objects.isNotEmpty ? objects.first : null;
      final msg = nearest != null
          ? 'Caution! I detect ${nearest.label} ahead.'
          : 'There are objects detected ahead. Please proceed with care.';
      tts.speakWarning(msg);
    }
  }

  void _handleStop(AppState state) {
    state.obstacleDetected = true;
    tts.speakWarning('Stop! Please check your surroundings.');
  }
}

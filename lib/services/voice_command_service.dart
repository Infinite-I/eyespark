// lib/services/voice_command_service.dart
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';

enum VoiceCommand {
  status,
  stop,
  help,
  settings,
  history,
  connect,
  disconnect,
  photo,
  flashOn,
  flashOff,
  startStream,
  stopStream,
  exportPDF,
  whereAmI,
}

class VoiceCommandService extends ChangeNotifier {
  final SpeechToText _speech = SpeechToText();
  bool _isAvailable = false;
  bool _isListening = false;
  String _lastCommand = '';
  String _lastError = '';

  bool get isListening => _isListening;
  bool get isAvailable => _isAvailable;
  String get lastCommand => _lastCommand;
  String get lastError => _lastError;

  Function? onStatusRequested;
  Function? onStopRequested;
  Function? onHelpRequested;
  Function? onSettingsRequested;
  Function? onHistoryRequested;
  Function? onConnectRequested;
  Function? onDisconnectRequested;
  Function? onPhotoRequested;
  Function? onFlashOnRequested;
  Function? onFlashOffRequested;
  Function? onStartStreamRequested;
  Function? onStopStreamRequested;
  Function? onExportPDFRequested;
  Function? onWhereAmIRequested;

  final Map<String, VoiceCommand> _commands = {
    'status': VoiceCommand.status,
    'state': VoiceCommand.status,
    'stop': VoiceCommand.stop,
    'help': VoiceCommand.help,
    'settings': VoiceCommand.settings,
    'history': VoiceCommand.history,
    'connect': VoiceCommand.connect,
    'disconnect': VoiceCommand.disconnect,
    'photo': VoiceCommand.photo,
    'flash on': VoiceCommand.flashOn,
    'flash off': VoiceCommand.flashOff,
    'start stream': VoiceCommand.startStream,
    'stop stream': VoiceCommand.stopStream,
    'export': VoiceCommand.exportPDF,
    'where am i': VoiceCommand.whereAmI,
  };

  Future<void> initialize() async {
    _isAvailable = await _speech.initialize(
      onStatus: _onStatus,
      onError: _onError,
    );
    notifyListeners();
  }

  void _onStatus(String status) {
    debugPrint('🎤 Speech status: $status');
  }

  void _onError(dynamic error) {
    _lastError = error.toString();
    debugPrint('❌ Speech error: $error');
    notifyListeners();
  }

  Future<void> startListening() async {
    if (!_isAvailable) {
      await initialize();
    }

    if (_isAvailable && !_isListening) {
      _isListening = true;
      notifyListeners();

      await _speech.listen(
        onResult: _onResult,
        listenFor: const Duration(seconds: 10),
        pauseFor: const Duration(seconds: 3),
        localeId: 'en_US',
        listenOptions: SpeechListenOptions(
          listenMode: ListenMode.confirmation,
        ),
      );
    }
  }

  Future<void> stopListening() async {
    if (_isListening) {
      await _speech.stop();
      _isListening = false;
      notifyListeners();
    }
  }

  void _onResult(SpeechRecognitionResult result) {
    if (result.finalResult) {
      _processCommand(result.recognizedWords);
    }
  }

  void _processCommand(String spokenText) {
    _lastCommand = spokenText;
    String lowerText = spokenText.toLowerCase().trim();

    VoiceCommand? command;

    for (var entry in _commands.entries) {
      if (lowerText.contains(entry.key)) {
        command = entry.value;
        break;
      }
    }

    if (command != null) {
      _executeCommand(command);
    }

    notifyListeners();
  }

  void _executeCommand(VoiceCommand command) {
    switch (command) {
      case VoiceCommand.status:
        onStatusRequested?.call();
        break;
      case VoiceCommand.stop:
        onStopRequested?.call();
        break;
      case VoiceCommand.help:
        onHelpRequested?.call();
        break;
      case VoiceCommand.settings:
        onSettingsRequested?.call();
        break;
      case VoiceCommand.history:
        onHistoryRequested?.call();
        break;
      case VoiceCommand.connect:
        onConnectRequested?.call();
        break;
      case VoiceCommand.disconnect:
        onDisconnectRequested?.call();
        break;
      case VoiceCommand.photo:
        onPhotoRequested?.call();
        break;
      case VoiceCommand.flashOn:
        onFlashOnRequested?.call();
        break;
      case VoiceCommand.flashOff:
        onFlashOffRequested?.call();
        break;
      case VoiceCommand.startStream:
        onStartStreamRequested?.call();
        break;
      case VoiceCommand.stopStream:
        onStopStreamRequested?.call();
        break;
      case VoiceCommand.exportPDF:
        onExportPDFRequested?.call();
        break;
      case VoiceCommand.whereAmI:
        onWhereAmIRequested?.call();
        break;
    }
  }

  String getCommandList() {
    return '''
🎤 Available voice commands:

• "Status" - Read current status
• "Stop" - Stop alerts
• "Settings" - Open settings
• "History" - Open history
• "Connect" - Start scanning
• "Disconnect" - Disconnect device
• "Photo" - Take a photo
• "Flash on/off" - Control flash
• "Start/stop stream" - Control video
• "Export" - Export as PDF
• "Where am I" - Read position
• "Help" - Show this help
    ''';
  }

  @override
  void dispose() {
    _speech.stop();
    super.dispose();
  }
}
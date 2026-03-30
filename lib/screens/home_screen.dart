import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';
import '../models/detected_object.dart';
import '../services/detection_service.dart';
import '../services/navigation_service.dart';
import '../services/tts_service.dart';
import '../services/voice_service.dart';
import '../services/command_processor.dart';
import '../widgets/status_card.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DetectionService detection = DetectionService();
  final NavigationService navigation = NavigationService();
  final TTSService tts = TTSService();
  final VoiceService voice = VoiceService();

  late CommandProcessor processor;

  bool _isProcessing = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    processor = CommandProcessor(tts);
    voice.init();
    _initAI();
  }

  Future<void> _initAI() async {
    await detection.loadModel();
    setState(() => _isInitialized = true);
  }

  /// 🧠 Run AI detection
  Future<void> _runAI() async {
    if (_isProcessing || !_isInitialized) return;

    setState(() => _isProcessing = true);

    final state = context.read<AppState>();

    try {
      List<DetectedObject> objects =
      detection.detectFromStream();

      /// ✅ ONLY THIS (AppState handles obstacle logic internally)
      state.objects = objects;

      /// 🧭 Navigation returns STRING
      final decision = navigation.decide(objects);

      /// 🔊 Speak result
      tts.speak(decision);
    } catch (e) {
      debugPrint("AI Error: $e");
    }

    setState(() => _isProcessing = false);
  }

  /// 🎤 Voice command
  void _startVoice() {
    final state = context.read<AppState>();

    state.setListening(true);

    voice.listen((text) {
      state.setListening(false);
      state.processCommand(text);
      processor.process(text, state);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      backgroundColor: const Color(0xFF020617),

      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          "EyeSpark AI",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SettingsScreen(),
                ),
              );
            },
          )
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Image.asset('assets/images/logo.png', width: 40),
                const SizedBox(width: 10),
                const Text(
                  "Smart Navigation",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: StatusCard(
                    title: "Bluetooth",
                    value: state.bluetoothConnected
                        ? "Connected"
                        : "Disconnected",
                    icon: Icons.bluetooth,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: StatusCard(
                    title: "Obstacle",
                    value: state.obstacleDetected
                        ? "Detected"
                        : "Clear",
                    icon: Icons.warning,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            StatusCard(
              title: "Last Command",
              value: state.lastCommand.isEmpty
                  ? "None"
                  : state.lastCommand,
              icon: Icons.mic,
            ),

            const SizedBox(height: 20),

            Expanded(
              child: state.objects.isEmpty
                  ? const Center(
                child: Text(
                  "No objects detected",
                  style: TextStyle(color: Colors.white54),
                ),
              )
                  : ListView.builder(
                itemCount: state.objects.length,
                itemBuilder: (context, index) {
                  final obj = state.objects[index];

                  return Card(
                    color: Colors.grey.shade900,
                    child: ListTile(
                      leading: const Icon(
                        Icons.visibility,
                        color: Colors.cyan,
                      ),
                      title: Text(
                        obj.label,
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        "Confidence: ${(obj.confidence * 100).toStringAsFixed(1)}%",
                        style: const TextStyle(color: Colors.white54),
                      ),
                    ),
                  );
                },
              ),
            ),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed:
                    (!_isInitialized || _isProcessing)
                        ? null
                        : _runAI,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyan,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: !_isInitialized
                        ? const Text(
                      "Loading AI...",
                      style: TextStyle(color: Colors.black),
                    )
                        : _isProcessing
                        ? const CircularProgressIndicator(
                      color: Colors.black,
                    )
                        : const Text(
                      "Scan",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed:
                    state.isListening ? null : _startVoice,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      state.isListening
                          ? "Listening..."
                          : "Voice",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
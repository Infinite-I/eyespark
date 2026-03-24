import 'dart:async';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';
import '../services/bluetooth_service.dart' as app_services;
import '../services/camera_service.dart';
import '../services/command_processor.dart';
import '../services/detection_service.dart';
import '../services/tts_service.dart';
import '../services/voice_service.dart';
import '../widgets/camera_view.dart';
import '../widgets/control_panel.dart';
import '../widgets/detection_overlay.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final CameraService _cameraService = CameraService();
  final DetectionService _detectionService = DetectionService();
  final app_services.BluetoothService _bluetoothService = app_services.BluetoothService();
  final VoiceService _voiceService = VoiceService();
  final TTSService _ttsService = TTSService();
  late CommandProcessor _commandProcessor;

  StreamSubscription<CameraImage>? _imageStreamSub;
  bool _detectionEnabled = true;
  int _frameSkip = 0;
  static const int _framesToSkip = 3; // Process every 4th frame for performance

  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _commandProcessor = CommandProcessor(_ttsService);
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _initApp();
  }

  Future<void> _initApp() async {
    await _requestPermissions();

    final cameraOk = await _cameraService.initCamera();
    if (mounted) {
      context.read<AppState>().cameraReady = cameraOk;
    }

    if (cameraOk) {
      await _detectionService.init();
      _startDetectionStream();
    }

    await _voiceService.init();
  }

  Future<void> _requestPermissions() async {
    await [
      Permission.camera,
      Permission.microphone,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
    ].request();
  }

  void _startDetectionStream() {
    final controller = _cameraService.controller;
    if (controller == null || !controller.value.isInitialized) return;

    controller.startImageStream((image) {
      if (!_detectionEnabled || !mounted) return;

      _frameSkip++;
      if (_frameSkip < _framesToSkip) return;
      _frameSkip = 0;

      _detectionService
          .processCameraImage(
            image,
            controller.description,
            controller.description.sensorOrientation,
            controller.value.deviceOrientation,
          )
          .then((objects) {
        if (mounted) {
          final state = context.read<AppState>();
          state.detectedObjects = objects;
          state.lastImageSize = Size(image.width.toDouble(), image.height.toDouble());
        }
      });
    });
  }

  void _startListening() {
    final state = context.read<AppState>();
    state.isListening = true;

    _voiceService.listen(
      onResult: (text) {
        if (!mounted) return;
        final s = context.read<AppState>();
        s.isListening = false;
        s.setCommand(text);
        s.addHistory('🎤 $text');

        _commandProcessor.process(text, s);
      },
      onError: (err) {
        if (mounted) {
          context.read<AppState>().isListening = false;
        }
      },
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _imageStreamSub?.cancel();
    _cameraService.controller?.stopImageStream();
    _detectionService.dispose();
    _cameraService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          _buildCameraBackground(),
          _buildDetectionOverlay(),
          _buildGradientOverlay(),
          _buildTopBar(),
          _buildObstacleAlert(),
          _buildMicrophoneButton(),
          _buildBottomPanel(),
        ],
      ),
    );
  }

  Widget _buildCameraBackground() {
    return Consumer<AppState>(
      builder: (context, state, _) {
        return CameraView(
          controller: _cameraService.controller,
          showPlaceholder: !state.cameraReady,
        );
      },
    );
  }

  Widget _buildDetectionOverlay() {
    final controller = _cameraService.controller;
    if (controller == null || !controller.value.isInitialized) {
      return const SizedBox.shrink();
    }

    return Consumer<AppState>(
      builder: (context, state, _) {
        if (state.detectedObjects.isEmpty) return const SizedBox.shrink();
        final imgSize = state.lastImageSize;
        if (imgSize == Size.zero) return const SizedBox.shrink();
        final previewSize = controller.value.previewSize;
        if (previewSize == null) return const SizedBox.shrink();

        return DetectionOverlay(
          objects: state.detectedObjects,
          imageSize: imgSize,
          previewSize: Size(previewSize.width.toDouble(), previewSize.height.toDouble()),
          mirror: controller.description.lensDirection == CameraLensDirection.front,
        );
      },
    );
  }

  Widget _buildGradientOverlay() {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withOpacity(0.3),
              Colors.black.withOpacity(0.6),
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 12,
      left: 16,
      right: 16,
      child: Consumer<AppState>(
        builder: (context, state, _) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white24, width: 1),
                ),
                child: Row(
                  children: [
                    Icon(Icons.visibility_rounded,
                        color: Colors.purple.shade300, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        state.lastCommand.isEmpty
                            ? 'Ready... Say "Scan" or "What\'s ahead"'
                            : state.lastCommand,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    _buildBluetoothIcon(state),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBluetoothIcon(AppState state) {
    return GestureDetector(
      onTap: () => _showBluetoothSheet(),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: state.bluetoothConnected
              ? Colors.green.withOpacity(0.3)
              : Colors.white.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          state.bluetoothConnected ? Icons.bluetooth_connected : Icons.bluetooth,
          color: state.bluetoothConnected ? Colors.greenAccent : Colors.white70,
          size: 24,
        ),
      ),
    );
  }

  void _showBluetoothSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Bluetooth',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            if (context.read<AppState>().bluetoothConnected)
              ListTile(
                leading: const Icon(Icons.bluetooth_connected,
                    color: Colors.greenAccent),
                title: Text(
                  'Connected: ${context.read<AppState>().bluetoothDeviceName}',
                  style: const TextStyle(color: Colors.white70),
                ),
                onTap: () async {
                  await _bluetoothService.disconnect();
                  if (context.mounted) {
                    context.read<AppState>().setBluetoothStatus(false);
                    Navigator.pop(context);
                  }
                },
              )
            else
              ListTile(
                leading: const Icon(Icons.bluetooth_searching),
                title: const Text('Scan for ESP32 devices',
                    style: TextStyle(color: Colors.white70)),
                onTap: () async {
                  Navigator.pop(context);
                  final devices = await _bluetoothService.scanForDevices();
                  if (context.mounted) {
                    _showDeviceList(devices);
                  }
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showDeviceList(List devices) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select device',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            if (devices.isEmpty)
              const Text('No devices found',
                  style: TextStyle(color: Colors.white54))
            else
              ...devices.map<Widget>((d) => ListTile(
                    leading: const Icon(Icons.devices, color: Colors.purple),
                    title: Text(
                      d.remoteId.str,
                      style: const TextStyle(color: Colors.white70),
                    ),
                    subtitle: const Text('Tap to connect',
                        style: TextStyle(color: Colors.white38, fontSize: 12)),
                    onTap: () async {
                      final ok = await _bluetoothService.connect(d);
                      if (context.mounted && ok) {
                        final name = await d.platformName;
                        if (context.mounted) {
                          context
                              .read<AppState>()
                              .setBluetoothStatus(true, name.isNotEmpty ? name : d.remoteId.str);
                          Navigator.pop(context);
                        }
                      }
                    },
                  )),
          ],
        ),
      ),
    );
  }

  Widget _buildObstacleAlert() {
    return Consumer<AppState>(
      builder: (context, state, _) {
        if (!state.obstacleDetected) return const SizedBox.shrink();

        return Positioned(
          bottom: 200,
          left: 20,
          right: 20,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: state.obstacleDetected ? 1 : 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.red.shade700, Colors.red.shade900],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.5),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      color: Colors.white, size: 32),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Obstacle detected — proceed with care',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMicrophoneButton() {
    return Positioned(
      bottom: 180,
      left: 0,
      right: 0,
      child: Center(
        child: Consumer<AppState>(
          builder: (context, state, _) {
            return ScaleTransition(
              scale: Tween(begin: 0.95, end: 1.1).animate(
                CurvedAnimation(
                  parent: _pulseController,
                  curve: Curves.easeInOut,
                ),
              ),
              child: GestureDetector(
                onTap: state.isListening ? null : _startListening,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: state.isListening
                          ? [Colors.red.shade400, Colors.orange.shade700]
                          : [
                              Colors.purple.shade600,
                              Colors.blue.shade700,
                            ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (state.isListening
                                ? Colors.red
                                : Colors.purple)
                            .withOpacity(0.5),
                        blurRadius: 24,
                        spreadRadius: 2,
                      ),
                      const BoxShadow(
                        color: Colors.black38,
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    state.isListening ? Icons.mic : Icons.mic_none_rounded,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBottomPanel() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      top: MediaQuery.of(context).size.height * 0.5,
      child: DraggableScrollableSheet(
        initialChildSize: 0.18,
        minChildSize: 0.12,
        maxChildSize: 0.45,
        builder: (context, scrollController) {
          return ControlPanel(scrollController: scrollController);
        },
      ),
    );
  }
}

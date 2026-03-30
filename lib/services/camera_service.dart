import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';

class CameraService {
  CameraController? _controller;

  CameraController? get controller => _controller;

  Future<bool> initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return false;

      _controller = CameraController(
        cameras.first,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _controller!.initialize();
      return true;
    } catch (e) {
      debugPrint("Camera error: $e");
      return false;
    }
  }

  void startStream(Function(CameraImage image) onFrame) {
    if (_controller == null || !_controller!.value.isInitialized) return;
    _controller!.startImageStream(onFrame);
  }

  Future<void> stopStream() async {
    if (_controller != null && _controller!.value.isStreamingImages) {
      await _controller!.stopImageStream();
    }
  }

  void dispose() {
    _controller?.dispose();
  }
}
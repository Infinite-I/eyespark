import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraService {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  bool _isInitialized = false;
  bool _isInitializing = false;

  CameraController? get controller => _controller;
  bool get isInitialized => _isInitialized;
  List<CameraDescription> get cameras => _cameras;

  /// Initialize camera with proper error handling and permissions.
  /// Uses nv21 for Android and bgra8888 for iOS (required for ML Kit).
  Future<bool> initCamera() async {
    if (_isInitialized) return true;
    if (_isInitializing) return false;

    _isInitializing = true;

    try {
      final cameraStatus = await Permission.camera.request();
      if (!cameraStatus.isGranted) {
        debugPrint('Camera permission denied');
        _isInitializing = false;
        return false;
      }

      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        debugPrint('No cameras available');
        _isInitializing = false;
        return false;
      }

      final camera = _cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras.first,
      );

      final imageFormat = Platform.isAndroid
          ? ImageFormatGroup.nv21
          : ImageFormatGroup.bgra8888;

      _controller = CameraController(
        camera,
        ResolutionPreset.medium,
        imageFormatGroup: imageFormat,
        enableAudio: false,
      );

      await _controller!.initialize();
      _isInitialized = true;
      _isInitializing = false;
      return true;
    } catch (e, stack) {
      debugPrint('Camera init error: $e');
      debugPrint(stack.toString());
      _isInitializing = false;
      return false;
    }
  }


  Future<void> dispose() async {
    if (_controller != null) {
      try {
        if (_controller!.value.isStreamingImages) {
          await _controller!.stopImageStream();
        }
        await _controller!.dispose();
      } catch (_) {}
      _controller = null;
    }
    _isInitialized = false;
  }
}

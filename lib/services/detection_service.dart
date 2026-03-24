import 'dart:io';

import 'dart:ui' show Size;

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';

import '../providers/app_state.dart';

class DetectionService {
  ObjectDetector? _detector;
  bool _isProcessing = false;
  bool _isDisposed = false;

  static final Map<DeviceOrientation, int> _orientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };

  /// Initialize with ML Kit base model (no custom asset needed).
  Future<void> init() async {
    if (_detector != null) return;

    try {
      final options = ObjectDetectorOptions(
        mode: DetectionMode.stream,
        classifyObjects: true,
        multipleObjects: true,
      );
      _detector = ObjectDetector(options: options);
    } catch (e) {
      debugPrint('ML Kit init error: $e');
      rethrow;
    }
  }

  InputImage? _inputImageFromCameraImage(
    CameraImage image,
    CameraDescription camera,
    int? sensorOrientation,
    DeviceOrientation? deviceOrientation,
  ) {
    InputImageRotation? rotation;
    if (Platform.isIOS) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation ?? 0);
    } else if (Platform.isAndroid) {
      var rotationCompensation = _orientations[deviceOrientation];
      if (rotationCompensation == null) return null;
      if (camera.lensDirection == CameraLensDirection.front) {
        rotationCompensation =
            ((sensorOrientation ?? 0) + rotationCompensation) % 360;
      } else {
        rotationCompensation =
            ((sensorOrientation ?? 0) - rotationCompensation + 360) % 360;
      }
      rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
    }
    if (rotation == null) return null;

    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null ||
        (Platform.isAndroid && format != InputImageFormat.nv21) ||
        (Platform.isIOS && format != InputImageFormat.bgra8888)) {
      return null;
    }

    if (image.planes.length != 1) return null;
    final plane = image.planes.first;

    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: plane.bytesPerRow,
      ),
    );
  }

  /// Process camera image and return detected objects.
  Future<List<DetectedObjectInfo>> processCameraImage(
    CameraImage image,
    CameraDescription camera,
    int? sensorOrientation,
    DeviceOrientation? deviceOrientation,
  ) async {
    if (_detector == null || _isProcessing || _isDisposed) return [];

    final inputImage = _inputImageFromCameraImage(
      image,
      camera,
      sensorOrientation,
      deviceOrientation,
    );
    if (inputImage == null) return [];

    _isProcessing = true;
    try {
      final objects = await _detector!.processImage(inputImage);

      return objects.map((obj) {
        String label = 'Object';
        double confidence = 0;
        if (obj.labels.isNotEmpty) {
          label = obj.labels.first.text;
          confidence = obj.labels.first.confidence;
        }
        return DetectedObjectInfo(
          label: label,
          boundingBox: obj.boundingBox,
          confidence: confidence,
        );
      }).toList();
    } catch (e) {
      debugPrint('Detection error: $e');
      return [];
    } finally {
      _isProcessing = false;
    }
  }

  Future<void> dispose() async {
    _isDisposed = true;
    await _detector?.close();
    _detector = null;
  }
}

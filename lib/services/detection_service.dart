import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import '../models/detected_object.dart';

class DetectionService {
  final Random _random = Random();

  bool _isLoaded = false;

  /// 🔥 Simulate loading (later replace with TFLite model load)
  Future<void> loadModel() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _isLoaded = true;
    print("✅ Detection Service Ready");
  }

  bool get isReady => _isLoaded;

  /// 🧠 MAIN METHOD USED BY HomeScreen
  List<DetectedObject> detectFromStream() {
    if (!_isLoaded) return [];

    final objects = ['Person', 'Chair', 'Wall', 'Door'];

    return List.generate(_random.nextInt(3) + 1, (i) {
      return DetectedObject(
        label: objects[_random.nextInt(objects.length)],
        confidence: 0.7 + _random.nextDouble() * 0.3,

        /// 📦 Bounding box
        boundingBox: Rect.fromLTWH(
          _random.nextDouble() * 200,
          _random.nextDouble() * 400,
          120,
          120,
        ),

        /// 📏 Distance (VERY IMPORTANT)
        distance: 0.5 + _random.nextDouble() * 2,
      );
    });
  }

  /// 🔮 Future real model hook
  List<DetectedObject> runModel(Uint8List imageBytes) {
    // TODO: Replace with YOLO inference
    return detectFromStream();
  }

  void dispose() {
    // cleanup later when model exists
  }
}
import 'dart:ui';

class DetectedObject {
  final String label;
  final double confidence;
  final Rect boundingBox;
  final double? distance; // 🔥 future: depth estimation

  DetectedObject({
    required this.label,
    required this.confidence,
    required this.boundingBox,
    this.distance,
  });

  /// 🔥 Helper: is obstacle?
  bool get isObstacle {
    final obstacles = ['person', 'chair', 'wall', 'car', 'door'];
    return obstacles.contains(label.toLowerCase());
  }

  /// 🔥 Helper: center X position (for navigation)
  double get centerX => boundingBox.left + boundingBox.width / 2;

  /// 🔥 Helper: size (bigger = closer)
  double get area => boundingBox.width * boundingBox.height;
}
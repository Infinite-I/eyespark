import 'dart:ui';

class Helpers {
  /// Convert bounding box → center X
  static double getCenterX(Rect rect) {
    return rect.left + rect.width / 2;
  }

  /// Check if object is in danger zone
  static bool isDanger(double distance) {
    return distance < 150;
  }

  /// Normalize value (0–1)
  static double normalize(double value, double max) {
    return value / max;
  }

  /// Clamp value
  static double clamp(double value, double min, double max) {
    if (value < min) return min;
    if (value > max) return max;
    return value;
  }

  /// Format distance text
  static String formatDistance(double distance) {
    return "${distance.toStringAsFixed(1)} cm";
  }
}
import 'dart:ui';
import '../../models/detected_object.dart';
import '../constants/app_constants.dart';
import 'helpers.dart';

class NavigationBrain {
  /// 🧠 Main AI decision function
  static NavigationDecision decide(
      List<DetectedObject> objects,
      Size screenSize,
      ) {
    if (objects.isEmpty) {
      return NavigationDecision.clear();
    }

    DetectedObject? closest;

    /// 🔍 Find closest valid object (safe null handling)
    for (var obj in objects) {
      final distance = obj.distance ?? double.infinity;

      if (closest == null) {
        closest = obj;
        continue;
      }

      final closestDistance = closest.distance ?? double.infinity;

      if (distance < closestDistance) {
        closest = obj;
      }
    }

    if (closest == null) return NavigationDecision.clear();

    final distance = closest.distance ?? double.infinity;

    /// 🧠 Not dangerous → safe
    if (!Helpers.isDanger(distance)) {
      return NavigationDecision.clear();
    }

    /// 📍 Get object horizontal position
    final centerX = Helpers.getCenterX(closest.boundingBox);

    final leftThreshold = screenSize.width * 0.4;
    final rightThreshold = screenSize.width * 0.6;

    /// 🚦 Navigation logic
    if (centerX < leftThreshold) {
      return NavigationDecision.moveRight(closest);
    } else if (centerX > rightThreshold) {
      return NavigationDecision.moveLeft(closest);
    } else {
      return NavigationDecision.stop(closest);
    }
  }
}

/// 🎯 Navigation Result Model
class NavigationDecision {
  final String action;
  final DetectedObject? object;

  const NavigationDecision._(this.action, this.object);

  factory NavigationDecision.clear() =>
      const NavigationDecision._("CLEAR", null);

  factory NavigationDecision.moveLeft(DetectedObject obj) =>
      NavigationDecision._("MOVE LEFT", obj);

  factory NavigationDecision.moveRight(DetectedObject obj) =>
      NavigationDecision._("MOVE RIGHT", obj);

  factory NavigationDecision.stop(DetectedObject obj) =>
      NavigationDecision._("STOP", obj);

  /// 🔊 Voice output helper
  String get voiceMessage {
    if (object == null) return "Path is clear";

    switch (action) {
      case "MOVE LEFT":
        return "Obstacle ahead. Move left.";
      case "MOVE RIGHT":
        return "Obstacle ahead. Move right.";
      case "STOP":
        return "Stop! Obstacle directly ahead.";
      default:
        return "Path is clear";
    }
  }
}
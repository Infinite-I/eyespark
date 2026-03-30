import '../models/detected_object.dart';

class NavigationService {
  String decide(List<DetectedObject> objects) {
    if (objects.isEmpty) return "Path is clear";

    final obstacle = objects.firstWhere(
          (o) => o.isObstacle,
      orElse: () => objects.first,
    );

    final center = obstacle.centerX;

    if (center < 200) {
      return "Move right";
    } else if (center > 400) {
      return "Move left";
    } else {
      return "Stop, obstacle ahead";
    }
  }
}
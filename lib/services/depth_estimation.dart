import '../models/detected_object.dart';

class DepthService {
  List<DetectedObject> estimate(List<DetectedObject> objects) {
    return objects.map((obj) {
      double size = obj.boundingBox.width * obj.boundingBox.height;

      double distance = 1000 / (size + 1); // 🔥 closer = bigger box

      return DetectedObject(
        label: obj.label,
        confidence: obj.confidence,
        boundingBox: obj.boundingBox,
        distance: distance,
      );
    }).toList();
  }
}
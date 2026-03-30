import '../models/detected_object.dart';

class TrackingService {
  List<DetectedObject> _previous = [];

  List<DetectedObject> track(List<DetectedObject> current) {
    // 🔥 Simple tracking (can upgrade to SORT/DeepSORT)
    _previous = current;
    return current;
  }
}
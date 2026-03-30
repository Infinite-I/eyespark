class AppConstants {
  // 📱 App Info
  static const String appName = "EyeSpark";
  static const String version = "1.0.0";

  // 📡 Default Stream URL (IP Webcam)
  static const String defaultStreamUrl = "http://192.168.0.100:8080/shot.jpg";

  // 🧠 AI Settings
  static const double detectionThreshold = 0.5;
  static const int inputSize = 640;

  // 📏 Navigation thresholds
  static const double dangerDistance = 150; // cm
  static const double safeDistance = 300;

  // Voice
  static const double speechRate = 0.5;

  // Bluetooth
  static const String targetDeviceName = "ESP32_CAM";

  //  Performance
  static const int frameDelayMs = 800;

  //  Commands
  static const List<String> commands = [
    "scan",
    "stop",
    "what is ahead",
    "navigate",
  ];
}
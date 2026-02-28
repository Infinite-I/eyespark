// lib/utils/constants.dart
// SUPPRIMER l'import inutile
class AppConstants {
  static const String appName = 'Navigation Aid Pro';
  static const String version = '1.0.0';

  // UUIDs Bluetooth (à personnaliser selon votre ESP32)
  static const String serviceUUID = "4fafc201-1fb5-459e-8fcc-c5c9c331914b";
  static const String obstacleCharUUID = "beb5483e-36e1-4688-b7f5-ea07361b26a8";
  static const String statusCharUUID = "beb5483e-36e1-4688-b7f5-ea07361b26a9";

  // Seuils
  static const int batteryLowThreshold = 20;
  static const int batteryCriticalThreshold = 10;
  static const int temperatureWarningThreshold = 40;

  // Messages TTS
  static const String welcomeMessage = 'Navigation assistant ready';
  static const String connectMessage = 'Device connected';
  static const String disconnectMessage = 'Device disconnected';
  static const String clearPathMessage = 'Clear path';
}
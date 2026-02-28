// lib/models/user_settings.dart
import 'package:hive/hive.dart';

part 'user_settings.g.dart';

@HiveType(typeId: 2)
class UserSettings {
  @HiveField(0)
  int audioVolume;

  @HiveField(1)
  String sensitivity;

  @HiveField(2)
  int detectionRangeCm;

  @HiveField(3)
  bool voiceEnabled;

  @HiveField(4)
  bool hapticEnabled;

  @HiveField(5)
  bool nightVisionAuto;

  @HiveField(6)
  bool darkMode;

  UserSettings({
    this.audioVolume = 80,
    this.sensitivity = 'medium',
    this.detectionRangeCm = 200,
    this.voiceEnabled = true,
    this.hapticEnabled = false,
    this.nightVisionAuto = true,
    this.darkMode = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'audio_volume': audioVolume,
      'sensitivity': sensitivity,
      'detection_range_cm': detectionRangeCm,
      'voice_enabled': voiceEnabled,
      'haptic_enabled': hapticEnabled,
      'night_vision_auto': nightVisionAuto,
      'dark_mode': darkMode,
    };
  }

  UserSettings copyWith({
    int? audioVolume,
    String? sensitivity,
    int? detectionRangeCm,
    bool? voiceEnabled,
    bool? hapticEnabled,
    bool? nightVisionAuto,
    bool? darkMode,
  }) {
    return UserSettings(
      audioVolume: audioVolume ?? this.audioVolume,
      sensitivity: sensitivity ?? this.sensitivity,
      detectionRangeCm: detectionRangeCm ?? this.detectionRangeCm,
      voiceEnabled: voiceEnabled ?? this.voiceEnabled,
      hapticEnabled: hapticEnabled ?? this.hapticEnabled,
      nightVisionAuto: nightVisionAuto ?? this.nightVisionAuto,
      darkMode: darkMode ?? this.darkMode,
    );
  }
}
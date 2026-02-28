// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserSettingsAdapter extends TypeAdapter<UserSettings> {
  @override
  final int typeId = 2;

  @override
  UserSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserSettings(
      audioVolume: fields[0] as int,
      sensitivity: fields[1] as String,
      detectionRangeCm: fields[2] as int,
      voiceEnabled: fields[3] as bool,
      hapticEnabled: fields[4] as bool,
      nightVisionAuto: fields[5] as bool,
      darkMode: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, UserSettings obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.audioVolume)
      ..writeByte(1)
      ..write(obj.sensitivity)
      ..writeByte(2)
      ..write(obj.detectionRangeCm)
      ..writeByte(3)
      ..write(obj.voiceEnabled)
      ..writeByte(4)
      ..write(obj.hapticEnabled)
      ..writeByte(5)
      ..write(obj.nightVisionAuto)
      ..writeByte(6)
      ..write(obj.darkMode);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'obstacle_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ObstacleDataAdapter extends TypeAdapter<ObstacleData> {
  @override
  final int typeId = 0;

  @override
  ObstacleData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ObstacleData(
      type: fields[0] as String,
      timestamp: fields[1] as int,
      distanceCm: fields[2] as int,
      direction: fields[3] as String,
      confidence: fields[4] as double,
      obstacleType: fields[5] as String,
      urgency: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ObstacleData obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.type)
      ..writeByte(1)
      ..write(obj.timestamp)
      ..writeByte(2)
      ..write(obj.distanceCm)
      ..writeByte(3)
      ..write(obj.direction)
      ..writeByte(4)
      ..write(obj.confidence)
      ..writeByte(5)
      ..write(obj.obstacleType)
      ..writeByte(6)
      ..write(obj.urgency);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ObstacleDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

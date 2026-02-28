// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'statistics.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StatisticsAdapter extends TypeAdapter<Statistics> {
  @override
  final int typeId = 3;

  @override
  Statistics read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Statistics(
      totalDetections: fields[0] as int,
      highUrgencyCount: fields[1] as int,
      mediumUrgencyCount: fields[2] as int,
      lowUrgencyCount: fields[3] as int,
      averageDistance: fields[4] as double,
      firstUse: fields[5] as DateTime?,
      lastUse: fields[6] as DateTime?,
      recentDistances: (fields[7] as List?)?.cast<double>(),
      detectionsByHour: (fields[8] as Map?)?.cast<String, int>(),
      achievements: (fields[9] as List?)?.cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, Statistics obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.totalDetections)
      ..writeByte(1)
      ..write(obj.highUrgencyCount)
      ..writeByte(2)
      ..write(obj.mediumUrgencyCount)
      ..writeByte(3)
      ..write(obj.lowUrgencyCount)
      ..writeByte(4)
      ..write(obj.averageDistance)
      ..writeByte(5)
      ..write(obj.firstUse)
      ..writeByte(6)
      ..write(obj.lastUse)
      ..writeByte(7)
      ..write(obj.recentDistances)
      ..writeByte(8)
      ..write(obj.detectionsByHour)
      ..writeByte(9)
      ..write(obj.achievements);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StatisticsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'password_activity_log.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PasswordActivityLogAdapter extends TypeAdapter<PasswordActivityLog> {
  @override
  final int typeId = 4;

  @override
  PasswordActivityLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PasswordActivityLog(
      id: fields[0] as String,
      passwordId: fields[1] as String,
      passwordName: fields[2] as String,
      activityType: fields[3] as ActivityType,
      timestamp: fields[4] as DateTime,
      oldValue: fields[5] as String?,
      newValue: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, PasswordActivityLog obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.passwordId)
      ..writeByte(2)
      ..write(obj.passwordName)
      ..writeByte(3)
      ..write(obj.activityType)
      ..writeByte(4)
      ..write(obj.timestamp)
      ..writeByte(5)
      ..write(obj.oldValue)
      ..writeByte(6)
      ..write(obj.newValue);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PasswordActivityLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ActivityTypeAdapter extends TypeAdapter<ActivityType> {
  @override
  final int typeId = 3;

  @override
  ActivityType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ActivityType.viewed;
      case 1:
        return ActivityType.created;
      case 2:
        return ActivityType.updated;
      case 3:
        return ActivityType.deleted;
      default:
        return ActivityType.viewed;
    }
  }

  @override
  void write(BinaryWriter writer, ActivityType obj) {
    switch (obj) {
      case ActivityType.viewed:
        writer.writeByte(0);
        break;
      case ActivityType.created:
        writer.writeByte(1);
        break;
      case ActivityType.updated:
        writer.writeByte(2);
        break;
      case ActivityType.deleted:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActivityTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

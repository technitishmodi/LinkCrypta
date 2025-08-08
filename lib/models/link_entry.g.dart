// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'link_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LinkEntryAdapter extends TypeAdapter<LinkEntry> {
  @override
  final int typeId = 1;

  @override
  LinkEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LinkEntry(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      url: fields[3] as String,
      category: fields[4] as String,
      createdAt: fields[5] as DateTime,
      updatedAt: fields[6] as DateTime,
      isFavorite: fields[7] as bool,
      isBookmarked: fields[8] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, LinkEntry obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.url)
      ..writeByte(4)
      ..write(obj.category)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.updatedAt)
      ..writeByte(7)
      ..write(obj.isFavorite)
      ..writeByte(8)
      ..write(obj.isBookmarked);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LinkEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

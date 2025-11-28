// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deadline_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DeadlineItemAdapter extends TypeAdapter<DeadlineItem> {
  @override
  final int typeId = 4;

  @override
  DeadlineItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DeadlineItem(
      title: fields[0] as String,
      courseCode: fields[1] as String,
      dueDate: fields[2] as DateTime,
      weightage: fields[3] as double,
      isCompleted: fields[4] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, DeadlineItem obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.courseCode)
      ..writeByte(2)
      ..write(obj.dueDate)
      ..writeByte(3)
      ..write(obj.weightage)
      ..writeByte(4)
      ..write(obj.isCompleted);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeadlineItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

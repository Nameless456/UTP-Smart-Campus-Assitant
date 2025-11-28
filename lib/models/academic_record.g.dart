// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'academic_record.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AcademicRecordAdapter extends TypeAdapter<AcademicRecord> {
  @override
  final int typeId = 3;

  @override
  AcademicRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AcademicRecord(
      courseCode: fields[0] as String,
      creditHours: fields[1] as double,
      predictedGrade: fields[2] as String,
      gradePointValue: fields[3] as double,
      semester: fields[4] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, AcademicRecord obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.courseCode)
      ..writeByte(1)
      ..write(obj.creditHours)
      ..writeByte(2)
      ..write(obj.predictedGrade)
      ..writeByte(3)
      ..write(obj.gradePointValue)
      ..writeByte(4)
      ..write(obj.semester);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AcademicRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

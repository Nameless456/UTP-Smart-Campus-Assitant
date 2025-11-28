import 'package:hive/hive.dart';

part 'academic_record.g.dart';

@HiveType(typeId: 3)
class AcademicRecord extends HiveObject {
  @HiveField(0)
  String courseCode;

  @HiveField(1)
  double creditHours;

  @HiveField(2)
  String predictedGrade;

  @HiveField(3)
  double gradePointValue;

  @HiveField(4)
  int? semester;

  AcademicRecord({
    required this.courseCode,
    required this.creditHours,
    required this.predictedGrade,
    required this.gradePointValue,
    this.semester = 1,
  });
}

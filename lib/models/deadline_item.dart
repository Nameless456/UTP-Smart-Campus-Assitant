import 'package:hive/hive.dart';

part 'deadline_item.g.dart';

@HiveType(typeId: 4)
class DeadlineItem extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String courseCode;

  @HiveField(2)
  DateTime dueDate;

  @HiveField(3)
  double weightage;

  @HiveField(4)
  bool isCompleted;

  DeadlineItem({
    required this.title,
    required this.courseCode,
    required this.dueDate,
    required this.weightage,
    this.isCompleted = false,
  });
}

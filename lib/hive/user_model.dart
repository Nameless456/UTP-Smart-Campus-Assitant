import 'package:hive_flutter/hive_flutter.dart';

part 'user_model.g.dart';

@HiveType(typeId: 1)
class UserModel extends HiveObject {
  @HiveField(0)
  final String uid;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String image;

  @HiveField(3)
  final String email;

  @HiveField(4)
  final String major;

  //constructor
  UserModel({
    required this.uid,
    required this.name,
    required this.image,
    required this.email,
    required this.major,
  });
}

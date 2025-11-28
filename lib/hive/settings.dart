import 'package:hive_flutter/hive_flutter.dart';

part 'settings.g.dart';

@HiveType(typeId: 2)
class Settings extends HiveObject {
  @HiveField(0)
  bool isDarkTheme = false;

  @HiveField(1)
  bool shouldSpeak = false;

  @HiveField(2)
  String language = 'en';

  //constructor
  Settings({
    required this.isDarkTheme,
    required this.shouldSpeak,
    this.language = 'en',
  });
}

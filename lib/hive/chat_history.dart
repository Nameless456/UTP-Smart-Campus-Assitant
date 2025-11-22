import 'package:hive_flutter/hive_flutter.dart';

part 'chat_history.g.dart';

@HiveType(typeId: 0)
class ChatHistory extends HiveObject{

  @HiveField(0)
  final String chatid;

  @HiveField(1)
  final String prompt;

  @HiveField(2)
  final String resonse;

  @HiveField(3)
  final List<String> imagesUrls;

  @HiveField(4)
  final DateTime timestamp;

  //constructor
  ChatHistory({
    required this.chatid,
    required this.prompt,
    required this.resonse,
    required this.imagesUrls,
    required this.timestamp

  });

}
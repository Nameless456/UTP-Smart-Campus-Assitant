import 'package:flutter_gemini/hive/chat_history.dart';
import 'package:flutter_gemini/hive/settings.dart';
import 'package:flutter_gemini/hive/user_model.dart';
import 'package:hive_flutter/hive_flutter.dart';

class Boxes {
  // get the chat history box 
  static Box<ChatHistory> getChatHistory() =>
      Hive.box<ChatHistory>('constant.chatHistoryBox');


  // get user box
  static Box<UserModel> getUser() => Hive.box<UserModel>('constant.UserBox');

  // get settings box 
  static Box<Settings> getsettings() => Hive.box<Settings>('constant.settingsBox');


}
import 'package:flutter/material.dart';
import 'package:flutter_gemini/constant.dart';
import 'package:flutter_gemini/hive/settings.dart';
import 'package:hive_flutter/hive_flutter.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _currentLocale = const Locale('en');

  Locale get currentLocale => _currentLocale;
  bool get isMalay => _currentLocale.languageCode == 'ms';

  LanguageProvider() {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final box = await Hive.openBox<Settings>(Constant.settingsBox);
    if (box.isNotEmpty) {
      final settings = box.getAt(0);
      if (settings?.language != null) {
        _currentLocale = Locale(settings!.language);
        notifyListeners();
      }
    }
  }

  Future<void> setLanguage(String languageCode) async {
    _currentLocale = Locale(languageCode);
    notifyListeners();

    final box = await Hive.openBox<Settings>(Constant.settingsBox);
    if (box.isNotEmpty) {
      final settings = box.getAt(0);
      settings?.language = languageCode;
      await settings?.save();
    }
  }

  // Localization Strings
  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'app_title': 'UTP Smart Campus',
      'chat': 'Chat',
      'chat_history': 'Chat History',
      'profile': 'Profile & Settings',
      'gpa_calculator': 'GPA Calculator',
      'deadline_tracker': 'Deadline Tracker',
      'about': 'About',
      'logout': 'Logout',
      'settings': 'Settings',
      'appearance': 'Appearance',
      'dark_mode': 'Dark Mode',
      'language': 'Language',
      'preferences': 'Preferences',
      'text_to_speech': 'Text-to-Speech',
      'edit_profile': 'Edit Profile',
      'name': 'Name',
      'major': 'Major',
      'save': 'Save',
      'cancel': 'Cancel',
      'login': 'Login',
      'welcome': 'Welcome to UTP Smart Campus!',
      'ask_anything':
          'Ask me anything about campus life, courses, or facilities.',
      'type_message': 'Type a message...',
      'search': 'Search...',
      'no_history': 'No chat history yet',
      'start_chat': 'Start a conversation to see it here',
    },
    'ms': {
      'app_title': 'Kampus Pintar UTP',
      'chat': 'Sembang',
      'chat_history': 'Sejarah Sembang',
      'profile': 'Profil & Tetapan',
      'gpa_calculator': 'Kalkulator GPA',
      'deadline_tracker': 'Penjejak Tarikh Akhir',
      'about': 'Tentang',
      'logout': 'Log Keluar',
      'settings': 'Tetapan',
      'appearance': 'Penampilan',
      'dark_mode': 'Mod Gelap',
      'language': 'Bahasa',
      'preferences': 'Pilihan',
      'text_to_speech': 'Teks-ke-Ucapan',
      'edit_profile': 'Sunting Profil',
      'name': 'Nama',
      'major': 'Program',
      'save': 'Simpan',
      'cancel': 'Batal',
      'login': 'Log Masuk',
      'welcome': 'Selamat Datang ke Kampus Pintar UTP!',
      'ask_anything':
          'Tanya saya apa sahaja tentang kehidupan kampus, kursus, atau fasiliti.',
      'type_message': 'Taip mesej...',
      'search': 'Cari...',
      'no_history': 'Tiada sejarah sembang',
      'start_chat': 'Mulakan perbualan untuk melihatnya di sini',
    },
  };

  String getText(String key) {
    return _localizedValues[_currentLocale.languageCode]?[key] ?? key;
  }
}

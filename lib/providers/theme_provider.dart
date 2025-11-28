import 'package:flutter/material.dart';
import 'package:flutter_gemini/constant.dart';
import 'package:flutter_gemini/hive/settings.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;

  ThemeProvider() {
    _loadThemePreference();
  }

  bool get isDarkMode => _isDarkMode;

  // Load theme preference from Hive
  Future<void> _loadThemePreference() async {
    final settingsBox = Hive.box<Settings>(Constant.settingsBox);

    if (settingsBox.isEmpty) {
      // Create default settings if none exist
      final defaultSettings = Settings(isDarkTheme: false, shouldSpeak: false);
      await settingsBox.add(defaultSettings);
      _isDarkMode = false;
    } else {
      final settings = settingsBox.getAt(0);
      _isDarkMode = settings?.isDarkTheme ?? false;
    }
    notifyListeners();
  }

  // Toggle theme and save to Hive
  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;

    final settingsBox = Hive.box<Settings>(Constant.settingsBox);
    final settings = settingsBox.getAt(0);

    if (settings != null) {
      settings.isDarkTheme = _isDarkMode;
      await settings.save();
    }

    notifyListeners();
  }

  // Light theme
  ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF002B5C), // UTP Deep Blue
        secondary: const Color(0xFFBEA42E), // UTP Gold
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Color(0xFF002B5C), // UTP Deep Blue
        foregroundColor: Colors.white,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 4,
        backgroundColor: Color(0xFFBEA42E), // UTP Gold
        foregroundColor: Colors.white,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
      ),
    );
  }

  // Dark theme
  ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFBEA42E), // UTP Gold
        secondary: const Color(0xFF002B5C), // UTP Deep Blue
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: const Color(0xFF121212),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Color(0xFF1F1F1F),
        foregroundColor: Color(0xFFBEA42E), // UTP Gold
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        color: const Color(0xFF1F1F1F),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 4,
        backgroundColor: Color(0xFFBEA42E), // UTP Gold
        foregroundColor: Colors.black,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2C2C2C),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
      ),
    );
  }
}

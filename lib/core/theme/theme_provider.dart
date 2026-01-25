import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ljl_colors.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  Future<void> loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final theme = prefs.getString('theme_mode') ?? 'system';
    
    switch (theme) {
      case 'light':
        _themeMode = ThemeMode.light;
        break;
      case 'dark':
        _themeMode = ThemeMode.dark;
        break;
      default:
        _themeMode = ThemeMode.system;
    }
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', mode.name);
    notifyListeners();
  }

  bool get isDarkMode {
    final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
    return _themeMode == ThemeMode.dark || 
           (_themeMode == ThemeMode.system && brightness == Brightness.dark);
  }
}

class LjlTheme {
  static ThemeData lightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: LjlColors.teal,
      scaffoldBackgroundColor: LjlColors.light,
      appBarTheme: const AppBarTheme(
        backgroundColor: LjlColors.teal,
        foregroundColor: Colors.white,
      ),
    );
  }

  static ThemeData darkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: LjlColors.gold,
      scaffoldBackgroundColor: LjlColors.dark,
      cardColor: const Color(0xFF1E2A44),
      dialogBackgroundColor: const Color(0xFF1E2A44),
      appBarTheme: const AppBarTheme(
        backgroundColor: LjlColors.dark,
        foregroundColor: Colors.white,
      ),
    );
  }
}
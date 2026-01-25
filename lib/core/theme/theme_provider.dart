import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

// Actualizar ljl_theme.dart para soportar dark mode
class LjlTheme {
  static ThemeData lightTheme() {
    return ThemeData(
      primaryColor: ljl_colors.primary,
      scaffoldBackgroundColor: Colors.white,
      brightness: Brightness.light,
      // ... tus configuraciones actuales
    );
  }

  static ThemeData darkTheme() {
    return ThemeData(
      primaryColor: ljl_colors.primaryDark,
      scaffoldBackgroundColor: Colors.grey[900],
      brightness: Brightness.dark,
      cardColor: Colors.grey[800],
      dialogBackgroundColor: Colors.grey[800],
      // ... configuraciones para dark mode
    );
  }
}
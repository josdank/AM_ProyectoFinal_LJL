import 'package:flutter/material.dart';

class LjlColors {
  // Manual de marca (HEX exactos)
  static const light = Color(0xFFC7E3E1); // #C7E3E1
  static const teal = Color(0xFF6FA7A1);  // #6FA7A1
  static const gold = Color(0xFFC99A5B);  // #C99A5B
  static const navy = Color(0xFF0F1F3A);  // #0F1F3A

  static const white = Color(0xFFFFFFFF);
  static const text = Color(0xFF0F1F3A);
}

ThemeData buildLjlTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: LjlColors.teal,
    brightness: Brightness.light,
  ).copyWith(
    primary: LjlColors.navy,
    secondary: LjlColors.teal,
    tertiary: LjlColors.gold,
    surface: LjlColors.white,
    background: LjlColors.light,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onTertiary: LjlColors.navy,
    onSurface: LjlColors.text,
    onBackground: LjlColors.text,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: LjlColors.light,

    appBarTheme: const AppBarTheme(
      backgroundColor: LjlColors.light,
      foregroundColor: LjlColors.text,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: LjlColors.text,
        fontSize: 20,
        fontWeight: FontWeight.w900,
        letterSpacing: .2,
      ),
      iconTheme: IconThemeData(color: LjlColors.text),
    ),

    textTheme: const TextTheme(
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w900,
        color: LjlColors.text,
      ),
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: LjlColors.text,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: LjlColors.text,
        height: 1.25,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: LjlColors.text,
        height: 1.25,
      ),
    ),

    cardTheme: CardThemeData(
      color: Colors.white,
      shadowColor: Colors.grey,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: LjlColors.gold,
        foregroundColor: LjlColors.navy,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: .1),
      ).copyWith(
        overlayColor: WidgetStatePropertyAll(LjlColors.navy.withOpacity(.06)),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: LjlColors.navy,
        side: BorderSide(color: LjlColors.navy.withOpacity(.18)),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: .1),
      ).copyWith(
        overlayColor: WidgetStatePropertyAll(LjlColors.navy.withOpacity(.06)),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: LjlColors.white.withOpacity(.90),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: LjlColors.navy.withOpacity(.12)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: LjlColors.navy.withOpacity(.12)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: LjlColors.teal, width: 2),
      ),
      hintStyle: TextStyle(color: LjlColors.navy.withOpacity(.45), fontWeight: FontWeight.w700),
      labelStyle: TextStyle(color: LjlColors.navy.withOpacity(.75), fontWeight: FontWeight.w800),
    ),
  );
}

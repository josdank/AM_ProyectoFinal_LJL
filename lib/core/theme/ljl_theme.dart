import 'package:flutter/material.dart';

class LjlColors {
  // Manual de marca (HEX exactos)
  static const light = Color(0xFFC7E3E1); // #C7E3E1
  static const teal = Color(0xFF6FA7A1);  // #6FA7A1
  static const gold = Color(0xFFC99A5B);  // #C99A5B
  static const navy = Color(0xFF0F1F3A);  // #0F1F3A

  // NUEVOS: Colores derivados
  static const lightTeal = Color(0xFFD8EFED); // Más claro para fondos
  static const darkNavy = Color(0xFF09152B);   // Para textos importantes
  static const mutedGold = Color(0xFFE3C9A5);  // Para fondos sutiles
  static const successGreen = Color(0xFF2E7D32); // Para estados positivos
  static const warningOrange = Color(0xFFF57C00); // Para advertencias
  static const errorRed = Color(0xFFD32F2F);    // Para estados de error

  static const white = Color(0xFFFFFFFF);
  static const offWhite = Color(0xFFFAFAFA);
  static const lightGrey = Color(0xFFF5F5F5);
  static const mediumGrey = Color(0xFFE0E0E0);
  static const darkGrey = Color(0xFF757575);
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
    // NUEVO: Estados de error/success
    error: LjlColors.errorRed,
    onError: Colors.white,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: LjlColors.light,

    appBarTheme: AppBarTheme(
      backgroundColor: LjlColors.light,
      foregroundColor: LjlColors.text,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: const TextStyle(
        color: LjlColors.text,
        fontSize: 20,
        fontWeight: FontWeight.w900,
        letterSpacing: .2,
      ),
      iconTheme: const IconThemeData(color: LjlColors.text),
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
        overlayColor: MaterialStatePropertyAll(LjlColors.navy.withOpacity(.06)),
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
        overlayColor: MaterialStatePropertyAll(LjlColors.navy.withOpacity(.06)),
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
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: LjlColors.errorRed, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: LjlColors.errorRed, width: 2),
      ),
      hintStyle: TextStyle(color: LjlColors.navy.withOpacity(.45), fontWeight: FontWeight.w700),
      labelStyle: TextStyle(color: LjlColors.navy.withOpacity(.75), fontWeight: FontWeight.w800),
      errorStyle: const TextStyle(color: LjlColors.errorRed, fontWeight: FontWeight.w600),
    ),

    // NUEVO: ChipTheme para tags/filtros
    chipTheme: ChipThemeData(
      backgroundColor: LjlColors.lightTeal,
      selectedColor: LjlColors.teal,
      disabledColor: LjlColors.mediumGrey,
      labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      secondaryLabelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: LjlColors.teal.withOpacity(0.3)),
      ),
    ),

    // NUEVO: DialogTheme para alertas/modales
    dialogTheme: const DialogThemeData(
      backgroundColor: LjlColors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: LjlColors.navy,
      ),
      contentTextStyle: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: LjlColors.navy,
      ),
    ),

    // NUEVO: DividerTheme para separadores
    dividerTheme: DividerThemeData(
      color: LjlColors.navy.withOpacity(0.12),
      thickness: 1,
      space: 16,
    ),

    // NUEVO: FloatingActionButtonTheme
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: LjlColors.gold,
      foregroundColor: LjlColors.navy,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),

    // NUEVO: SnackBar para notificaciones
    snackBarTheme: SnackBarThemeData(
      backgroundColor: LjlColors.navy,
      contentTextStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      behavior: SnackBarBehavior.floating,
    ),

    // NUEVO: ProgressIndicator
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      circularTrackColor: LjlColors.lightTeal,
      color: LjlColors.teal,
    ),
  );
}
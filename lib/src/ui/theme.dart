import 'package:flutter/material.dart';

class AimColors {
  static const Color scaffold = Color(0xFF101823);
  static const Color rail = Color(0xFF182231);
  static const Color panel = Color(0xFF1F2B3A);
  static const Color panelAlt = Color(0xFF253243);
  static const Color bubble = Color(0xFF2B384A);
  static const Color bubbleMine = Color(0xFF244C70);
  static const Color accent = Color(0xFF5BB8FF);
  static const Color accentStrong = Color(0xFF2B9BFF);
  static const Color success = Color(0xFF56D39A);
  static const Color warning = Color(0xFFF5C35B);
  static const Color danger = Color(0xFFFF6B7A);
  static const Color text = Color(0xFFF2F7FF);
  static const Color muted = Color(0xFF92A4B8);
  static const Color divider = Color(0xFF314052);
}

class AimTheme {
  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AimColors.accentStrong,
      brightness: Brightness.dark,
      surface: AimColors.scaffold,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: AimColors.scaffold,
      textTheme: Typography.whiteMountainView.apply(
        bodyColor: AimColors.text,
        displayColor: AimColors.text,
      ),
      iconTheme: const IconThemeData(color: AimColors.muted),
      dividerTheme: const DividerThemeData(
        color: AimColors.divider,
        thickness: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AimColors.panelAlt,
        contentTextStyle: const TextStyle(color: AimColors.text),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AimColors.panelAlt,
        hintStyle: const TextStyle(color: AimColors.muted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AimColors.accent, width: 1.2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AimColors.accentStrong,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AimColors.accentStrong,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AimColors.text,
          side: const BorderSide(color: AimColors.divider),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AimColors.accent),
      ),
      menuTheme: MenuThemeData(
        style: MenuStyle(
          backgroundColor: WidgetStateProperty.all(AimColors.panelAlt),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
      ),
    );
  }
}

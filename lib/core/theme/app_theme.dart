import 'package:flutter/material.dart';

/// Central horror-themed color palette.
///
/// Use [AppTheme.darkTheme] in [MaterialApp] and reference colors through
/// [AppColors] instead of hardcoding values in widgets.
/// Example: `color: AppColors.bloodRed` for damage indicators.
class AppColors {
  AppColors._();

  static const Color background = Color(0xFF0A0A0F);
  static const Color surface = Color(0xFF14141C);
  static const Color primary = Color(0xFF8B0000);
  static const Color secondary = Color(0xFF2D4A3E);
  static const Color textPrimary = Color(0xFFE8E0D5);
  static const Color textSecondary = Color(0xFF9A9088);
  static const Color bloodRed = Color(0xFFB22222);
  static const Color healthGreen = Color(0xFF3D7A4A);
  static const Color keyGold = Color(0xFFC9A227);
  static const Color overlayDark = Color(0xCC000000);
  static const Color joystickBase = Color(0x66FFFFFF);
  static const Color joystickKnob = Color(0xAAFFFFFF);
  static const Color doorBrown = Color(0xFF6B4423);
  static const Color doorBrownDark = Color(0xFF3D2814);

  /// Mansfield floor plan unit colors (from building legend).
  static const Color unitStudio = Color(0xFF5A5A5A);
  static const Color unitOneBedroom = Color(0xFFC46B6B);
  static const Color unitTwoBedroom = Color(0xFF2E3F6E);
  static const Color corridorFloor = Color(0xFFF0EDE8);
  static const Color sunDeckFloor = Color(0xFFD4C9A8);
}

/// Application theme configuration for the horror survival game.
///
/// Example:
/// ```dart
/// MaterialApp(theme: AppTheme.darkTheme, ...)
/// ```
class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
        onPrimary: AppColors.textPrimary,
        onSecondary: AppColors.textPrimary,
        onSurface: AppColors.textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: AppColors.textPrimary),
        bodyMedium: TextStyle(color: AppColors.textSecondary),
        titleLarge: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
    );
  }
}

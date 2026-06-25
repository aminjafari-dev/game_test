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

  /// Scene block palette — used verbatim by unlit 3D materials.
  static const Color mcGrass = Colors.green;
  static const Color mcWhite = Color(0xFFD4CCC0);
  static const Color mcDarkGray = Color(0xFF3A3A3A);
  static const Color mcOakWood = Color(0xFFB8956A);
  static const Color mcGlass = Color(0xAA8BB8C8);
  static const Color mcPoolWater = Color(0xCC2B5A8A);
  static const Color mcCrop = Color(0xFF3D5A32);
  static const Color mcTreeTrunk = Color(0xFF5C4528);
  static const Color mcTreeLeaves = Color(0xFF4A5C3A);

  /// Halloween coffin body — aged dark wood.
  static const Color coffinWoodDark = Color(0xFF2A1810);

  /// Halloween coffin lid — slightly lighter dusted wood.
  static const Color coffinWoodLight = Color(0xFF3D2818);

  /// Tarnished metal handles and trim on the coffin.
  static const Color coffinMetal = Color(0xFF6B5A42);

  /// Legacy map colors (kept for HUD compatibility).
  static const Color mapGrass = mcGrass;
  static const Color mapPath = mcOakWood;
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

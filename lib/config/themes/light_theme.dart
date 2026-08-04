import 'package:flutter/material.dart';
import 'package:new_strucuture/core/utils/app_constants.dart';
import 'app_colors_extension.dart';

class LightTheme {
  LightTheme._();

  static final ThemeData theme = ThemeData(
    dividerColor: Colors.transparent,

    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: AppColorsExtension.light.primary,
    colorScheme: ColorScheme.light(
      primary: AppColorsExtension.light.primary,
      secondary: AppColorsExtension.light.secondary,
      surface: AppColorsExtension.light.surface,

      error: AppColorsExtension.light.error,
    ),

    // Background colors
    scaffoldBackgroundColor: AppColorsExtension.light.background,
    cardColor: AppColorsExtension.light.cardColor,

    // App bar
    appBarTheme: AppBarTheme(
      backgroundColor: AppColorsExtension.light.primary,
      foregroundColor: Colors.white,
      elevation: 0,
    ),

    // Card theme
    cardTheme: CardThemeData(
      color: AppColorsExtension.light.cardColor,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstance.radiusTiny),
        side: BorderSide(
          color: AppColorsExtension.light.borderColor.withValues(alpha: 0.3),
        ),
      ),
    ),

    // Input decoration
    inputDecorationTheme: InputDecorationTheme(
      fillColor: AppColorsExtension.light.surface,
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstance.radiusTiny),
        borderSide: BorderSide(color: AppColorsExtension.light.borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstance.radiusTiny),
        borderSide: BorderSide(
          color: AppColorsExtension.light.borderColor.withValues(alpha: 0.3),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstance.radiusTiny),
        borderSide: BorderSide(color: AppColorsExtension.light.primary),
      ),
    ),

    // Text theme
    textTheme: TextTheme(
      titleLarge: TextStyle(
        color: AppColorsExtension.light.textPrimary,
        fontWeight: FontWeight.bold,
      ),
      titleMedium: TextStyle(
        color: AppColorsExtension.light.textPrimary,
        fontWeight: FontWeight.bold,
      ),
      titleSmall: TextStyle(
        color: AppColorsExtension.light.textPrimary,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: TextStyle(color: AppColorsExtension.light.textPrimary),
      bodyMedium: TextStyle(color: AppColorsExtension.light.textPrimary),
      bodySmall: TextStyle(color: AppColorsExtension.light.textSecondary),
    ),

    // Elevated button theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColorsExtension.light.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstance.radiusTiny),
        ),
        padding: const EdgeInsets.symmetric(
          vertical: AppConstance.vPadding,
          horizontal: 24,
        ),
      ),
    ),

    // Extensions
    extensions: [AppColorsExtension.light],
  );
}

import 'package:flutter/material.dart';
import 'package:new_strucuture/core/utils/app_constants.dart';
import '../../core/design_system/e3rab_design_tokens.dart';
import 'app_colors_extension.dart';

class DarkTheme {
  // Private constructor to prevent instantiation
  DarkTheme._();

  static final ThemeData theme = ThemeData(
    fontFamily: 'Alexandria',
    dividerColor: Colors.transparent, // This removes the dividers
    useMaterial3: true,
    brightness: Brightness.dark,

    // Base colors
    primaryColor: AppColorsExtension.dark.primary,
    colorScheme: ColorScheme.dark(
      primary: AppColorsExtension.dark.primary,
      secondary: AppColorsExtension.dark.secondary,
      surface: AppColorsExtension.dark.surface,

      error: AppColorsExtension.dark.error,
    ),

    // Background colors
    scaffoldBackgroundColor: AppColorsExtension.dark.background,
    cardColor: AppColorsExtension.dark.cardColor,

    // App bar
    appBarTheme: AppBarTheme(
      backgroundColor: AppColorsExtension.dark.background,
      foregroundColor: AppColorsExtension.dark.textPrimary,
      elevation: 0,
      centerTitle: false,
    ),

    // Card theme
    cardTheme: CardThemeData(
      color: AppColorsExtension.dark.cardColor,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(E3rabRadii.medium),
        side: BorderSide(
          color: AppColorsExtension.dark.borderColor.withValues(alpha: 0.3),
        ),
      ),
    ),

    // Input decoration
    inputDecorationTheme: InputDecorationTheme(
      fillColor: AppColorsExtension.dark.surface,
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstance.radiusTiny),
        borderSide: BorderSide(color: AppColorsExtension.dark.borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstance.radiusTiny),
        borderSide: BorderSide(
          color: AppColorsExtension.dark.borderColor.withValues(alpha: 0.3),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstance.radiusTiny),
        borderSide: BorderSide(color: AppColorsExtension.dark.primary),
      ),
    ),

    // Text theme
    textTheme: TextTheme(
      titleLarge: TextStyle(
        color: AppColorsExtension.dark.textPrimary,
        fontWeight: FontWeight.bold,
      ),
      titleMedium: TextStyle(
        color: AppColorsExtension.dark.textPrimary,
        fontWeight: FontWeight.bold,
      ),
      titleSmall: TextStyle(
        color: AppColorsExtension.dark.textPrimary,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: TextStyle(color: AppColorsExtension.dark.textPrimary),
      bodyMedium: TextStyle(color: AppColorsExtension.dark.textPrimary),
      bodySmall: TextStyle(color: AppColorsExtension.dark.textSecondary),
    ),

    // Elevated button theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColorsExtension.dark.primary,
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

    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(48, 52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstance.radiusTiny),
        ),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      height: 72,
      elevation: 3,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.black.withValues(alpha: 0.25),
      backgroundColor: AppColorsExtension.dark.surface,
      indicatorColor: const Color(0xFF24473E),
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: AppColorsExtension.dark.surface,
      indicatorColor: const Color(0xFF24473E),
      indicatorShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(E3rabRadii.medium),
      ),
      selectedIconTheme: IconThemeData(color: AppColorsExtension.dark.primary),
      selectedLabelTextStyle: TextStyle(
        color: AppColorsExtension.dark.primary,
        fontWeight: FontWeight.w700,
      ),
    ),

    // Extensions
    extensions: [AppColorsExtension.dark],
  );
}

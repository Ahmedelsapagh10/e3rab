import 'package:flutter/material.dart';
import 'package:new_strucuture/core/utils/app_constants.dart';
import '../../core/design_system/e3rab_design_tokens.dart';
import 'app_colors_extension.dart';

class LightTheme {
  LightTheme._();

  static final ThemeData theme = ThemeData(
    fontFamily: 'Alexandria',
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
      backgroundColor: AppColorsExtension.light.background,
      foregroundColor: AppColorsExtension.light.textPrimary,
      elevation: 0,
      centerTitle: false,
    ),

    // Card theme
    cardTheme: CardThemeData(
      color: AppColorsExtension.light.cardColor,
      elevation: 1,
      surfaceTintColor: Colors.transparent,
      shadowColor: const Color(0xFF17324D).withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(E3rabRadii.medium),
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
      shadowColor: const Color(0xFF17324D).withValues(alpha: 0.1),
      backgroundColor: AppColorsExtension.light.surface,
      indicatorColor: const Color(0xFFEAF2FF),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          color: states.contains(WidgetState.selected)
              ? AppColorsExtension.light.primary
              : AppColorsExtension.light.textSecondary,
          fontWeight: states.contains(WidgetState.selected)
              ? FontWeight.w700
              : FontWeight.w500,
        ),
      ),
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: AppColorsExtension.light.surface,
      indicatorColor: const Color(0xFFEAF2FF),
      indicatorShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(E3rabRadii.medium),
      ),
      selectedIconTheme: IconThemeData(color: AppColorsExtension.light.primary),
      selectedLabelTextStyle: TextStyle(
        color: AppColorsExtension.light.primary,
        fontWeight: FontWeight.w700,
      ),
    ),

    // Extensions
    extensions: [AppColorsExtension.light],
  );
}

import 'package:flutter/material.dart';
import 'package:new_strucuture/core/utils/app_colors.dart';

/// A custom ThemeExtension to hold app-specific color definitions.
@immutable
class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  const AppColorsExtension({
    required this.lightGray,
    required this.primary,
    required this.secondary,
    required this.background,
    required this.backgroundAppBar,
    required this.background2,
    required this.surface,
    required this.cardColor,
    required this.borderColor,
    required this.textPrimary,
    required this.textSecondary,
    required this.success,
    required this.warning,
    required this.error,
    required this.grey,
    required this.grey85,
    required this.white,
    required this.black,
    required this.lightGrey,
    required this.greyFA,
    required this.greyE8,
    required this.greyE0,
    required this.greyE1,
    required this.greyCF,
    required this.greyA8,
    required this.grey5C,
    required this.grey32,
    required this.grey1F,
    required this.greyE7,
    required this.greyCE,
    required this.greyF3,
    required this.greyF4,
    required this.greyBB,
    required this.primaryBackground,
    required this.onPrimaryBackground,
    required this.fixedPrimary,
    required this.greenStatus,
    required this.greenTextStatus,
    required this.redStatus,
    required this.redTextStatus,
    required this.yellowStatus,
    required this.yellowTextStatus,
    required this.completeStatus,
    required this.completeTextStatus,
    required this.holdStatus,
    required this.holdTextStatus,
    required this.text242,
    required this.text464,
  });

  final Color primary;
  final Color secondary;
  final Color background;
  final Color backgroundAppBar;
  final Color background2;
  final Color surface;
  final Color cardColor;
  final Color borderColor;
  final Color textPrimary;
  final Color textSecondary;
  final Color success;
  final Color warning;
  final Color error;
  final Color grey85;
  final Color white;
  final Color black;
  final Color lightGrey;
  final Color grey;
  final Color greyFA;
  final Color greyE8;
  final Color greyE0;
  final Color greyE1;
  final Color greyCF;
  final Color greyA8;
  final Color grey5C;
  final Color grey32;
  final Color grey1F;
  final Color greyE7;
  final Color greyCE;
  final Color greyF3;
  final Color greyF4;
  final Color greyBB;
  final Color primaryBackground;
  final Color onPrimaryBackground;
  final Color fixedPrimary; // Same in both light and dark mode
  final Color? lightGray;
  final Color text242;
  final Color text464;

  //status colors
  final Color greenStatus;

  final Color redStatus;

  final Color yellowStatus;

  final Color completeStatus;

  final Color holdStatus;

  //text status colors
  final Color greenTextStatus;

  final Color redTextStatus;

  final Color yellowTextStatus;

  final Color completeTextStatus;

  final Color holdTextStatus;

  /// Light theme colors
  static const AppColorsExtension light = AppColorsExtension(
    primary: AppColors.primary,
    secondary: AppColors.secondPrimary, //0xFF98A2B3
    background: Color(0xFFFFFFFF),
    backgroundAppBar: AppColors.primary,
    background2: Color(0xFFF4F5F7),
    surface: Color(0xFFFFFFFF),
    cardColor: Color(0xFFF7FBFA),
    borderColor: Color(0xFF98A2B3),
    textPrimary: AppColors.primary,
    textSecondary: Color(0xFF98A2B3),
    success: Color(0xFF2AC769),
    warning: Color(0xFFF6A609),
    error: Color(0xFFFB4E4E),
    grey85: AppColors.secondPrimary,
    white: Color(0xFFFFFFFF),
    black: Color(0xFF000000),
    grey: Color(0xFF9E9E9E),
    lightGrey: Color(0xFFBBC2CE),
    greyFA: Color(0xFFF9F9FA),
    greyE8: Color(0xFFE8E8E8),
    greyE0: Color(0xFFDCDBE0),
    greyE1: Color(0xFFE1E1E1),
    greyCF: Color(0xFFCCCACF),
    greyA8: Color(0xFFA2A0A8),
    grey5C: Color(0xFF52525C),
    grey32: Color(0xFF211F32),
    grey1F: Color(0xFF15141F),
    greyE7: Color(0xFFE7E7E7),
    greyCE: Color(0xFFBBC2CE),
    greyF3: Color(0xFFEDF1F3),
    greyF4: Color(0xFFF1F2F4),
    greyBB: Color(0xFFACB5BB),
    primaryBackground: AppColors.primary,
    // Same as primary in light mode
    onPrimaryBackground: Color(0xFFFFFFFF),
    // White text on primary background
    fixedPrimary: AppColors.primary,

    // Fixed primary color
    greenStatus: Color(0xFF40DD7F),
    redStatus: Color(0xFFFF6262),
    yellowStatus: Color(0xFFFFB800),
    completeStatus: AppColors.primary,
    holdStatus: Color(0xFFb0c8c2),
    greenTextStatus: Color(0xFF1AB759),
    redTextStatus: Color(0xFFE93C3C),
    yellowTextStatus: Color(0xFFF49A47),
    completeTextStatus: AppColors.primary,
    holdTextStatus: Color(0xFFb0c8c2),
    lightGray: Color(0xFFEFF1F4),
    text242: Color(0xFF404242),
    text464: Color(0xFF616464),
  );

  /// Dark theme colors
  static const AppColorsExtension dark = AppColorsExtension(
    primary: Color(0xFFffffff),
    secondary: Color(0xFFB0BEC5),
    background: Color(0xFF151F30),
    backgroundAppBar: Color(0xFF1B2639),
    background2: Color(0xFF151F30),
    surface: Color(0xFF1B2639),
    cardColor: Color(0xFF1B2639),
    borderColor: Color(0xFF223048),
    textPrimary: Color(0xFFECEFF1),
    textSecondary: Color(0xFFB0BEC5),
    success: Color(0xFF66BB6A),
    warning: Color(0xFFFFB74D),
    error: Color(0xFFE57373),
    grey85: Color(0xFFAAAAAA),
    white: Color(0xFF1B2639),
    // Dark mode interpretation of white
    black: Color(0xFFFFFFFF),
    // Dark mode interpretation of black
    lightGrey: Color(0xFFB0BEC5),
    // Darker version
    grey: Color(0xFF9E9E9E),
    greyFA: Color(0xFF151F30),
    // Darker version
    greyE8: Color(0xFF223048),
    // Darker version
    greyE0: Color(0xFF223048),
    // Darker version
    greyE1: Color(0xFF223048),
    // Darker version
    greyCF: Color(0xFF223048),
    // Darker version
    greyA8: Color(0xFF666666),
    // Darker version
    grey5C: Color(0xFF8A8A8A),
    // Lighter version for dark theme
    grey32: Color(0xFFB0B0B0),
    // Lighter version for dark theme
    grey1F: Color(0xFFC5C5C5),
    // Lighter version for dark theme
    greyE7: Color(0xFF223048),
    // Darker version
    greyCE: Color(0xFFB0BEC5),
    // Darker version
    greyF3: Color(0xFF151F30),
    // Darker version
    greyF4: Color(0xFF151F30),
    // Darker version
    greyBB: Color(0xFFB0BEC5),
    // Darker version
    primaryBackground: Color(0xFF1A2530),
    // Darker version of primary for dark mode
    onPrimaryBackground: Color(0xFFECEFF1),
    // Light text on dark primary background
    fixedPrimary: AppColors.primary,

    // Same fixed primary color in dark mode
    greenStatus: Color(0xFF6DE89F),
    redStatus: Color(0xFFEF9A9A),
    yellowStatus: Color(0xFFFFD54F),
    completeStatus: Color(0xFF9FA8DA),
    holdStatus: Color(0xFFB0BEC5),
    greenTextStatus: Color(0xFF81C784),
    redTextStatus: Color(0xFFFFCDD2),
    yellowTextStatus: Color(0xFFFFE082),
    completeTextStatus: Color(0xFFC5CAE9),
    holdTextStatus: Color(0xFFCFD8DC),
    lightGray: Color(0xFFA9ACB4),
    text242: Color(0x99FFFFFF),
    text464: Color(0x99FFFFFF),
  );

  @override
  AppColorsExtension copyWith({
    Color? primary,
    Color? secondary,
    Color? background,
    Color? backgroundAppBar,
    Color? background2,
    Color? surface,
    Color? cardColor,
    Color? borderColor,
    Color? textPrimary,
    Color? textSecondary,
    Color? success,
    Color? warning,
    Color? error,
    Color? grey85,
    Color? white,
    Color? black,
    Color? lightGrey,
    Color? grey,
    Color? greyFA,
    Color? greyE8,
    Color? greyE0,
    Color? greyE1,
    Color? greyCF,
    Color? greyA8,
    Color? grey5C,
    Color? grey32,
    Color? grey1F,
    Color? greyE7,
    Color? greyCE,
    Color? greyF3,
    Color? greyF4,
    Color? greyBB,
    Color? primaryBackground,
    Color? onPrimaryBackground,
    Color? fixedPrimary,
    Color? lightGray,
    Color? text242,
    Color? text464,
  }) {
    return AppColorsExtension(
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      background: background ?? this.background,
      backgroundAppBar: backgroundAppBar ?? this.backgroundAppBar,
      background2: background2 ?? this.background2,
      surface: surface ?? this.surface,
      cardColor: cardColor ?? this.cardColor,
      borderColor: borderColor ?? this.borderColor,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      error: error ?? this.error,
      grey85: grey85 ?? this.grey85,
      white: white ?? this.white,
      black: black ?? this.black,
      lightGrey: lightGrey ?? this.lightGrey,
      grey: grey ?? this.grey,
      greyFA: greyFA ?? this.greyFA,
      greyE8: greyE8 ?? this.greyE8,
      greyE0: greyE0 ?? this.greyE0,
      greyE1: greyE1 ?? this.greyE1,
      greyCF: greyCF ?? this.greyCF,
      greyA8: greyA8 ?? this.greyA8,
      grey5C: grey5C ?? this.grey5C,
      grey32: grey32 ?? this.grey32,
      grey1F: grey1F ?? this.grey1F,
      greyE7: greyE7 ?? this.greyE7,
      greyCE: greyCE ?? this.greyCE,
      greyF3: greyF3 ?? this.greyF3,
      greyF4: greyF4 ?? this.greyF4,
      greyBB: greyBB ?? this.greyBB,
      primaryBackground: primaryBackground ?? this.primaryBackground,
      onPrimaryBackground: onPrimaryBackground ?? this.onPrimaryBackground,
      fixedPrimary: fixedPrimary ?? this.fixedPrimary,
      greenStatus: greenStatus,
      redStatus: redStatus,
      yellowStatus: yellowStatus,
      completeStatus: completeStatus,
      holdStatus: holdStatus,
      greenTextStatus: greenTextStatus,
      redTextStatus: redTextStatus,
      yellowTextStatus: yellowTextStatus,
      completeTextStatus: completeTextStatus,
      holdTextStatus: holdTextStatus,
      lightGray: lightGray ?? this.lightGray,
      text242: text242 ?? this.text242,
      text464: text464 ?? this.text464,
    );
  }

  @override
  AppColorsExtension lerp(ThemeExtension<AppColorsExtension>? other, double t) {
    if (other is! AppColorsExtension) return this;

    return AppColorsExtension(
      primary: Color.lerp(primary, other.primary, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      background: Color.lerp(background, other.background, t)!,
      backgroundAppBar: Color.lerp(
        backgroundAppBar,
        other.backgroundAppBar,
        t,
      )!,
      background2: Color.lerp(background2, other.background2, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      cardColor: Color.lerp(cardColor, other.cardColor, t)!,
      borderColor: Color.lerp(borderColor, other.borderColor, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      error: Color.lerp(error, other.error, t)!,
      grey85: Color.lerp(grey85, other.grey85, t)!,
      white: Color.lerp(white, other.white, t)!,
      black: Color.lerp(black, other.black, t)!,
      lightGrey: Color.lerp(lightGrey, other.lightGrey, t)!,
      grey: Color.lerp(grey, other.grey, t)!,
      greyFA: Color.lerp(greyFA, other.greyFA, t)!,
      greyE8: Color.lerp(greyE8, other.greyE8, t)!,
      greyE0: Color.lerp(greyE0, other.greyE0, t)!,
      greyE1: Color.lerp(greyE1, other.greyE1, t)!,
      greyCF: Color.lerp(greyCF, other.greyCF, t)!,
      greyA8: Color.lerp(greyA8, other.greyA8, t)!,
      grey5C: Color.lerp(grey5C, other.grey5C, t)!,
      grey32: Color.lerp(grey32, other.grey32, t)!,
      grey1F: Color.lerp(grey1F, other.grey1F, t)!,
      greyE7: Color.lerp(greyE7, other.greyE7, t)!,
      greyCE: Color.lerp(greyCE, other.greyCE, t)!,
      greyF3: Color.lerp(greyF3, other.greyF3, t)!,
      greyF4: Color.lerp(greyF4, other.greyF4, t)!,
      greyBB: Color.lerp(greyBB, other.greyBB, t)!,
      primaryBackground: Color.lerp(
        primaryBackground,
        other.primaryBackground,
        t,
      )!,
      onPrimaryBackground: Color.lerp(
        onPrimaryBackground,
        other.onPrimaryBackground,
        t,
      )!,
      fixedPrimary: Color.lerp(fixedPrimary, other.fixedPrimary, t)!,
      greenStatus: Color.lerp(greenStatus, other.greenStatus, t)!,
      redStatus: Color.lerp(redStatus, other.redStatus, t)!,
      yellowStatus: Color.lerp(yellowStatus, other.yellowStatus, t)!,
      completeStatus: Color.lerp(completeStatus, other.completeStatus, t)!,
      holdStatus: Color.lerp(holdStatus, other.holdStatus, t)!,
      greenTextStatus: Color.lerp(greenTextStatus, other.greenTextStatus, t)!,
      redTextStatus: Color.lerp(redTextStatus, other.redTextStatus, t)!,
      yellowTextStatus: Color.lerp(
        yellowTextStatus,
        other.yellowTextStatus,
        t,
      )!,
      completeTextStatus: Color.lerp(
        completeTextStatus,
        other.completeTextStatus,
        t,
      )!,
      holdTextStatus: Color.lerp(holdTextStatus, other.holdTextStatus, t)!,
      lightGray: Color.lerp(lightGray, other.lightGray, t),
      text242: Color.lerp(text242, other.text242, t)!,
      text464: Color.lerp(text464, other.text464, t)!,
    );
  }

  @override
  String toString() {
    return 'AppColorsExtension('
        'primary: $primary, secondary: $secondary, background: $background, '
        'surface: $surface, cardColor: $cardColor, borderColor: $borderColor, '
        'textPrimary: $textPrimary, textSecondary: $textSecondary, success: $success, '
        'warning: $warning, error: $error, grey85: $grey85, '
        'primaryBackground: $primaryBackground, onPrimaryBackground: $onPrimaryBackground, '
        'fixedPrimary: $fixedPrimary, text242: $text242, text464: $text464)';
  }
}

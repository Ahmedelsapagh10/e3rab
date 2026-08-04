import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'app_colors_extension.dart';
import 'theme_cubit.dart';

/// Helper class to access theme colors easily across the app
class ThemeHelper {
  const ThemeHelper._();

  /// Get app colors extension from the theme
  static AppColorsExtension colorsOf(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorsExtension>();
    if (colors == null) {
      throw Exception(
        'AppColorsExtension not found in ThemeData. '
        'Make sure it is added in ThemeData.extensions.',
      );
    }
    return colors;
  }

  static Color primaryColor(BuildContext context) => colorsOf(context).primary;
  static Color secondaryColor(BuildContext context) =>
      colorsOf(context).secondary;
  static Color backgroundColor(BuildContext context) =>
      colorsOf(context).background;
  static Color background2Color(BuildContext context) =>
      colorsOf(context).background2;
  static Color surfaceColor(BuildContext context) => colorsOf(context).surface;
  static Color cardColor(BuildContext context) => colorsOf(context).cardColor;
  static Color borderColor(BuildContext context) =>
      colorsOf(context).borderColor;
  static Color textPrimaryColor(BuildContext context) =>
      colorsOf(context).textPrimary;
  static Color textSecondaryColor(BuildContext context) =>
      colorsOf(context).textSecondary;
  static Color successColor(BuildContext context) => colorsOf(context).success;
  static Color warningColor(BuildContext context) => colorsOf(context).warning;
  static Color errorColor(BuildContext context) => colorsOf(context).error;
  static Color grey85Color(BuildContext context) => colorsOf(context).grey85;
  static Color text242(BuildContext context) => colorsOf(context).text242;
  static Color text464(BuildContext context) => colorsOf(context).text464;

  static bool isDarkMode(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  /// Toggle between light and dark mode
  static void toggleThemeMode(BuildContext context) {
    BlocProvider.of<ThemeCubit>(context).toggleTheme(context);
  }
}

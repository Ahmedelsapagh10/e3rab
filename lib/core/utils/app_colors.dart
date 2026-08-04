import 'package:flutter/material.dart';

import 'hex_color.dart';

class AppColors {
  static const Color primary = Color(0xFF31538E); //#F5F7FE

  static const Color primary49 = Color(0xFF152949);
  static const Color secondPrimary = Color.fromARGB(255, 19, 198, 198);

  static const Color primary8e = Color(0xFF31538E);
  static const Color success = Color(0xFF31538E);
  static const Color primaryfd = Color(0xFFF4F6FD);
  static const Color grey = Colors.grey;
  static const Color gray = Colors.grey;
  static const Color secondary = Color(0xFFF5F7FE);

  // alerts
  static const Color success69 = Color(0xFF2AC769);
  static const Color success59 = Color(0xFF1AB759);
  static const Color success7f = Color(0xFF40DD7F);
  static const Color success86 = Color(0xFF5DC486);
  static const Color success7b = Color(0xFF05D67B);

  static const Color warning09 = Color(0xFFF6A609);
  static const Color warning06 = Color(0xFFE89806);
  static const Color warning1f = Color(0xFFFFBC1F);
  static const Color red = Color(0xFFFB4E4E);
  static const Color error4e = Color(0xFFFB4E4E);
  static const Color error3c = Color(0xFFE93C3C);
  static const Color error = Color(0xFFE93C3C);
  static const Color error62 = Color(0xFFFF6262);
  static const Color error49 = Color(0xFFF04349);

  // buttons
  static const Color disabledf3 = Color(0xFFACBBF3);
  static const Color disabledfe = Color(0xFFF5F7FE);
  // static Color get disabledfe => ThemeNotifier.isDarkMode ? const Color(0xFF0E182A) : const Color(0xFFF5F7FE);

  // text #
  static const Color textField = Color(0xFFF9F9FA);
  static const Color text = Color(0xFF152949);
  static const Color hint = Color(0xFFA2A0A8);
  static const Color black = Color(0xFF15141F);
  static const Color greye8 = Color(0xFFE8E8E8);
  static const Color greyfa = Color(0xFFF9F9FA);
  static const Color greya8 = Color(0xFFA2A0A8);
  // static Color get greya8 => ThemeNotifier.isDarkMode ? const Color(0xFF0E182A) : const Color(0xFFA2A0A8);

  static const Color greya9f = Color(0xFF9F9F9F);
  static const Color greyaf3 = Color(0xFFF2F2F3);
  static Color grey91 = const Color(0xFF6E7591);
  static Color greyf7 = const Color(0xFFECF1F7);
  static Color greyf8 = const Color(0xFFF5F4F8);
  static Color greya2 = const Color(0xFF8B97A2);
  static Color greyA8 = const Color(0xFFA2A0A8);
  static Color greyfe = const Color(0xFfF5F7FE);
  static Color greyea = const Color(0xFfE6E7EA);
  static Color greyec = const Color(0xFfFDECEC);
  static Color grey2a = const Color(0xFf28292A);
  static Color greyfd = const Color(0xFfFCEDFD);
  static Color greyfd2 = const Color(0xFff4f6fd);
  static Color bluefa = const Color(0xFfd8e1fa);

  // white
  static Color white = const Color(0xFFFFFFFF);
  // other

  static const Color bgLigth = Color(0xFFFFFFFF);
  static const Color bgDark = Color(0xFF0E182A);

  static const Color textLight = Color(0xFF152949);
  static const Color textDark = Color(0xFFFFFFFF);

  static const Color text2Light = Color(0xFF31538D);
  static const Color text2Dark = Color(0xFFFFFFFF);

  static Color greyLight = const Color(0xFF8993A3);
  static Color greyDark = const Color(0xFF8993A3);

  static Color grey2Light = const Color(0xFFF3F2F6);
  static Color grey2Dark = const Color(0xFF222032);
  static Color grey3Dark = const Color(0xFF353d4c);
  static Color bottomNavBarDark = const Color(0xFF1b2639);

  Color darken(Color color, [double amount = .1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));

    return hslDark.toColor();
  }

  Color lightens(String color, [double amount = .1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(HexColor(color));
    final hslLight =
        hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));

    return hslLight.toColor();
  }
}

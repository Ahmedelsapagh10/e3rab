import 'package:flutter/material.dart';

abstract final class E3rabBrandColors {
  static const navy = Color(0xFF173B34);
  static const primaryBlue = Color(0xFF0F5C4D);
  static const sky = Color(0xFFE7F0EB);
  static const gold = Color(0xFFC9973E);
  static const background = Color(0xFFFAF7F0);
  static const surface = Color(0xFFFFFFFF);
  static const ink = Color(0xFF1F2926);
  static const muted = Color(0xFF66736E);
  static const success = Color(0xFF2E7D5B);
  static const warning = Color(0xFFA56A1E);
  static const error = Color(0xFFB4453F);
  static const darkBackground = Color(0xFF101B18);
  static const darkSurface = Color(0xFF182824);

  // Transitional aliases for feature widgets that still use the old names.
  static const primaryOrange = primaryBlue;
  static const supportingYellow = gold;
  static const darkInk = ink;
  static const warmBackground = background;
  static const warmSurface = surface;
  static const softOrange = sky;
  static const softYellow = Color(0xFFF5EBD7);
  static const warmDarkBackground = darkBackground;
  static const warmDarkSurface = darkSurface;
}

abstract final class E3rabBreakpoints {
  static const compact = 600.0;
  static const expanded = 1024.0;

  static bool isCompact(double width) => width < compact;
  static bool isExpanded(double width) => width >= expanded;
}

abstract final class E3rabSpacing {
  static const xSmall = 4.0;
  static const small = 8.0;
  static const medium = 16.0;
  static const large = 24.0;
  static const xLarge = 32.0;
  static const xxLarge = 48.0;
}

abstract final class E3rabRadii {
  static const small = 10.0;
  static const medium = 16.0;
  static const large = 24.0;
}

abstract final class E3rabReadingMetrics {
  static const maxContentWidth = 720.0;
  static const paragraphHeight = 1.8;
  static const exampleHeight = 2.0;
  static const minimumTapTarget = 48.0;
}

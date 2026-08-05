import 'package:flutter/material.dart';

abstract final class E3rabBrandColors {
  static const navy = Color(0xFF17324D);
  static const primaryBlue = Color(0xFF2F6FED);
  static const sky = Color(0xFFEAF2FF);
  static const background = Color(0xFFF7F9FC);
  static const surface = Color(0xFFFFFFFF);
  static const ink = Color(0xFF17212B);
  static const muted = Color(0xFF667085);
  static const success = Color(0xFF15803D);
  static const warning = Color(0xFFB7791F);
  static const error = Color(0xFFC2413B);
  static const darkBackground = Color(0xFF0E1724);
  static const darkSurface = Color(0xFF172338);

  // Transitional aliases for feature widgets that still use the old names.
  static const primaryOrange = primaryBlue;
  static const supportingYellow = Color(0xFF8BB8FF);
  static const darkInk = ink;
  static const warmBackground = background;
  static const warmSurface = surface;
  static const softOrange = sky;
  static const softYellow = Color(0xFFDCE9FF);
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
  static const maxContentWidth = 760.0;
  static const paragraphHeight = 1.8;
  static const exampleHeight = 2.0;
  static const minimumTapTarget = 48.0;
}

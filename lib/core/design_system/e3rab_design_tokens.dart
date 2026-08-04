import 'package:flutter/material.dart';

abstract final class E3rabBrandColors {
  static const primaryOrange = Color(0xFFE77813);
  static const supportingYellow = Color(0xFFF6C100);
  static const darkInk = Color(0xFF1F1A17);
  static const warmBackground = Color(0xFFFFF9F2);
  static const warmSurface = Color(0xFFFFFCF8);
  static const softOrange = Color(0xFFFFE8D2);
  static const softYellow = Color(0xFFFFF4C2);
  static const warmDarkBackground = Color(0xFF1F1A17);
  static const warmDarkSurface = Color(0xFF2B2521);
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

abstract final class E3rabReadingMetrics {
  static const maxContentWidth = 760.0;
  static const paragraphHeight = 1.8;
  static const exampleHeight = 2.0;
  static const minimumTapTarget = 48.0;
}

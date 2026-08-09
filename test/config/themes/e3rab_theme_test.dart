import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_strucuture/config/themes/app_colors_extension.dart';
import 'package:new_strucuture/config/themes/dark_theme.dart';
import 'package:new_strucuture/config/themes/light_theme.dart';
import 'package:new_strucuture/core/design_system/e3rab_design_tokens.dart';

void main() {
  test('light theme uses the approved E3rab palette', () {
    final colors = LightTheme.theme.extension<AppColorsExtension>()!;

    expect(colors.background, E3rabBrandColors.background);
    expect(colors.primary, E3rabBrandColors.primary);
    expect(colors.secondary, E3rabBrandColors.gold);
    expect(colors.textPrimary, E3rabBrandColors.ink);
    expect(colors.textSecondary, E3rabBrandColors.muted);
    expect(colors.success, E3rabBrandColors.success);
    expect(colors.warning, E3rabBrandColors.warning);
    expect(colors.error, E3rabBrandColors.error);
  });

  test('primary text meets WCAG AA contrast in both themes', () {
    final light = LightTheme.theme.extension<AppColorsExtension>()!;
    final dark = DarkTheme.theme.extension<AppColorsExtension>()!;

    expect(_contrast(light.textPrimary, light.background), greaterThan(4.5));
    expect(_contrast(light.textPrimary, light.surface), greaterThan(4.5));
    expect(_contrast(dark.textPrimary, dark.background), greaterThan(4.5));
    expect(_contrast(dark.textPrimary, dark.surface), greaterThan(4.5));
  });

  test('learning containers keep readable contrast in both themes', () {
    final light = LightTheme.theme.colorScheme;
    final dark = DarkTheme.theme.colorScheme;

    expect(
      _contrast(light.onPrimaryContainer, light.primaryContainer),
      greaterThan(4.5),
    );
    expect(
      _contrast(dark.onPrimaryContainer, dark.primaryContainer),
      greaterThan(4.5),
    );
  });

  test('reading and interaction tokens stay accessible', () {
    expect(E3rabReadingMetrics.maxContentWidth, inInclusiveRange(680, 720));
    expect(E3rabReadingMetrics.minimumTapTarget, greaterThanOrEqualTo(48));
    expect(LightTheme.theme.textTheme.bodyLarge?.fontFamily, 'Alexandria');
    expect(DarkTheme.theme.textTheme.bodyLarge?.fontFamily, 'Alexandria');
  });
}

double _contrast(Color first, Color second) {
  final lighter = math.max(first.computeLuminance(), second.computeLuminance());
  final darker = math.min(first.computeLuminance(), second.computeLuminance());
  return (lighter + 0.05) / (darker + 0.05);
}

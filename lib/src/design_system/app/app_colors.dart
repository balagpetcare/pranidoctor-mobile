import 'package:flutter/material.dart';

import '../prani_tokens.dart';

/// P01 brand palette — single source of truth is [PraniColors]; use this name in new code.
///
/// Prefer [ColorScheme] from `Theme.of(context).colorScheme` for surfaces and text;
/// use these for brand accents and legacy literals.
abstract final class AppColors {
  static const Color primary = PraniColors.primary;
  static const Color primaryDark = PraniColors.primaryDark;
  static const Color primaryLight = PraniColors.primaryLight;
  static const Color secondary = PraniColors.secondary;
  static const Color accent = PraniColors.accent;
  static const Color white = PraniColors.white;
  static const Color background = PraniColors.background;
  static const Color surface = PraniColors.surface;
  static const Color surfaceAlt = PraniColors.surfaceAlt;
  static const Color textPrimary = PraniColors.textPrimary;
  static const Color textSecondary = PraniColors.textSecondary;
  static const Color textDark = PraniColors.textDark;
  static const Color textMuted = PraniColors.textMuted;
  static const Color outlineSoft = PraniColors.outlineSoft;
  static const Color border = PraniColors.border;
  static const Color divider = PraniColors.divider;
  static const Color disabled = PraniColors.disabled;
  static const Color success = PraniColors.success;
  static const Color warning = PraniColors.warning;
  static const Color danger = PraniColors.danger;
  static const Color info = PraniColors.info;
  static const Color shadow = PraniColors.shadow;
  static const Color darkScaffold = PraniColors.darkScaffold;
}

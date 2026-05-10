import 'package:flutter/material.dart';

import '../prani_tokens.dart';

/// P01 semantic accents (success / warning) that stay readable on [ColorScheme.surface].
///
/// **Danger:** use [ColorScheme.error] from theme (mapped from [PraniColors.danger] in light).
abstract final class AppSemanticColors {
  static Color success(ColorScheme scheme) =>
      scheme.brightness == Brightness.dark
      ? PraniColors.successBright
      : PraniColors.success;

  static Color onSuccess(ColorScheme scheme) =>
      scheme.brightness == Brightness.dark
      ? const Color(0xFF052E1A)
      : PraniColors.white;

  static Color warningForeground(ColorScheme scheme) =>
      scheme.brightness == Brightness.dark
      ? PraniColors.warningBright
      : PraniColors.warning;

  static Color warningBackground(ColorScheme scheme) =>
      scheme.brightness == Brightness.dark
      ? const Color(0xFF3D3510)
      : const Color(0xFFFFF7E8);
}

import 'package:flutter/material.dart';

/// P01 semantic accents (success / warning) that stay readable on [ColorScheme.surface].
///
/// **Danger:** use [ColorScheme.error] and [ColorScheme.errorContainer] from theme.
abstract final class AppSemanticColors {
  static Color success(ColorScheme scheme) =>
      scheme.brightness == Brightness.dark
      ? const Color(0xFF34D399)
      : const Color(0xFF059669);

  static Color onSuccess(ColorScheme scheme) =>
      scheme.brightness == Brightness.dark
      ? const Color(0xFF052E1A)
      : Colors.white;

  static Color warningForeground(ColorScheme scheme) =>
      scheme.brightness == Brightness.dark
      ? const Color(0xFFFBBF24)
      : const Color(0xFFB45309);

  static Color warningBackground(ColorScheme scheme) =>
      scheme.brightness == Brightness.dark
      ? const Color(0xFF3D3510)
      : const Color(0xFFFFF7E8);
}

import 'package:flutter/material.dart';

/// P01 text helpers — Bengali-friendly line heights; colors always from [ColorScheme].
abstract final class AppTextStyles {
  static TextStyle screenTitle(TextTheme t, ColorScheme scheme) =>
      (t.titleLarge ?? const TextStyle()).copyWith(
        fontWeight: FontWeight.w700,
        height: 1.3,
        letterSpacing: -0.2,
        color: scheme.onSurface,
      );

  static TextStyle sectionTitle(TextTheme t, ColorScheme scheme) =>
      (t.titleMedium ?? const TextStyle()).copyWith(
        fontWeight: FontWeight.w700,
        height: 1.25,
        color: scheme.onSurface,
      );

  static TextStyle body(TextTheme t, ColorScheme scheme) =>
      (t.bodyLarge ?? const TextStyle()).copyWith(
        height: 1.45,
        color: scheme.onSurface,
      );

  static TextStyle bodyMuted(TextTheme t, ColorScheme scheme) =>
      (t.bodyMedium ?? const TextStyle()).copyWith(
        height: 1.45,
        color: scheme.onSurfaceVariant,
      );

  static TextStyle caption(TextTheme t, ColorScheme scheme) =>
      (t.bodySmall ?? const TextStyle()).copyWith(
        height: 1.4,
        color: scheme.onSurfaceVariant,
      );
}

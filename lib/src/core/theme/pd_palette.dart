import 'package:flutter/material.dart';

/// Brand palette — veterinary teal/green identity (Bangladesh-first).
/// Prefer [ColorScheme] roles in UI; use these for explicit accents / semantics.
abstract final class PdPalette {
  /// Seed / primary brand green (deep teal).
  static const Color primaryGreen = Color(0xFF0F766E);

  /// Dark green — pressed states, emphasis borders.
  static const Color darkGreen = Color(0xFF0D5E58);

  /// Light green tint — chips, highlights, soft fills.
  static const Color lightGreen = Color(0xFFCCFBF1);

  /// Clinic-style light background (medical white / mint).
  static const Color medicalWhite = Color(0xFFF5FAF9);

  /// Dark scaffold (not pure black).
  static const Color darkScaffold = Color(0xFF0C1211);

  /// Semantic — success (healthy / confirmed).
  static const Color success = Color(0xFF059669);

  /// Semantic — warning.
  static const Color warning = Color(0xFFD97706);

  /// Semantic — info (reuse seed-adjacent teal if needed).
  static const Color info = Color(0xFF0E7490);

  /// Explicit error red (also align with [ColorScheme.error] when possible).
  static const Color errorStrong = Color(0xFFDC2626);
}

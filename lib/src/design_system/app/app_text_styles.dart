import 'package:flutter/material.dart';

import '../prani_tokens.dart';

/// P01 text helpers — delegate to [PraniTextStyles] for Bengali-friendly line heights.
abstract final class AppTextStyles {
  static TextStyle screenTitle(TextTheme t, ColorScheme scheme) =>
      PraniTextStyles.title(scheme, t);

  static TextStyle sectionTitle(TextTheme t, ColorScheme scheme) =>
      PraniTextStyles.heading(scheme, t);

  static TextStyle body(TextTheme t, ColorScheme scheme) =>
      PraniTextStyles.body(scheme, t);

  static TextStyle bodyMuted(TextTheme t, ColorScheme scheme) =>
      PraniTextStyles.bodyMuted(scheme, t);

  static TextStyle caption(TextTheme t, ColorScheme scheme) =>
      PraniTextStyles.caption(scheme, t);
}

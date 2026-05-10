import 'package:flutter/material.dart';

import 'prani_tokens.dart';

/// Semantic surfaces for elevated content (cards, sheets) — safe in light and dark.
extension PraniColorSchemeX on ColorScheme {
  Color get praniElevatedCard =>
      brightness == Brightness.dark ? surfaceContainerHigh : surface;

  Color get praniOnElevatedCard => onSurface;

  Color get praniCanvas => brightness == Brightness.dark
      ? PraniColors.darkScaffold
      : PraniColors.background;

  // —— P01 naming (same semantics as prani* getters) ——
  Color get elevatedSurface => praniElevatedCard;
  Color get onElevatedSurface => praniOnElevatedCard;
  Color get canvasBackground => praniCanvas;
}

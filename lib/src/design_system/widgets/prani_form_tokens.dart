import 'package:flutter/material.dart';

/// Shared spacing/sizing for forms (Bengali-first legibility).
abstract final class PraniFormTokens {
  static const double cardPadding = 20;
  static const double fieldGap = 14;
  static const double sectionGap = 22;
  static const double inputMinTouchHeight = 56;
  static const EdgeInsets inputContentPadding = EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 18,
  );

  /// Extra scroll padding so focused fields clear keyboard + sticky bars.
  static double scrollBottomInset(BuildContext context) {
    final kb = MediaQuery.viewInsetsOf(context).bottom;
    return kb + 120;
  }
}

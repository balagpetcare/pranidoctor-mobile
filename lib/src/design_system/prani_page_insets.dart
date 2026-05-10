import 'package:flutter/material.dart';

/// Page gutters and bottom inset for the customer shell [NavigationBar].
///
/// Keep in sync with [NavigationBarThemeData.height] in `app/theme.dart` (72).
abstract final class PraniPageInsets {
  static const double navigationBarHeight = 72;

  /// Horizontal padding: consistent across Home and Profile (avoids %-based drift).
  static double horizontalPadding(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    if (w < 360) return 15;
    if (w <= 600) return 16;
    return 20;
  }

  /// Space below scrollable content so it clears the bottom nav + home indicator.
  static double bottomNavContentPadding(
    BuildContext context, {
    double comfortGap = 24,
  }) {
    return MediaQuery.paddingOf(context).bottom +
        navigationBarHeight +
        comfortGap;
  }
}

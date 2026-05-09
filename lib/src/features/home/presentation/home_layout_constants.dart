import 'package:flutter/material.dart';

/// Shared layout numbers for the customer Home tab (single source of truth).
abstract final class HomeLayout {
  /// Side inset for home content (phones: ~14–18dp; avoids overly wide gutters).
  static double horizontalPadding(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    if (w < 360) return 14;
    if (w <= 420) return 16;
    return 18;
  }

  /// Material 3 [NavigationBar] height — match [AppTheme.navigationBarTheme].
  static const double navigationBarHeight = 72;

  /// Extra scroll padding: safe area + nav bar + comfort gap.
  static double scrollBottomPadding(BuildContext context) {
    return MediaQuery.paddingOf(context).bottom + navigationBarHeight + 28;
  }

  /// Section rhythm: alert → hero → search → services block.
  static const double gapAfterAlert = 18;
  static const double gapHeroToSearch = 18;
  static const double gapSearchToServicesHeader = 22;

  /// Between major blocks (services grid ↔ nearby ↔ emergency ↔ promo).
  static const double gapSection = 22;

  /// Home cards (hero, search, services): ~20–22dp corners.
  static const double cardRadius = 22;

  /// Service tiles in the 2×2 grid.
  static const double serviceCardRadius = 22;
}

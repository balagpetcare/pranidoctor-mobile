import 'package:flutter/material.dart';

import 'package:pranidoctor_mobile/src/design_system/prani_page_insets.dart';
import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';

/// Shared layout numbers for the customer Home tab (single source of truth).
abstract final class HomeLayout {
  /// Side inset — delegates to [PraniPageInsets] for parity with Profile.
  static double horizontalPadding(BuildContext context) {
    return PraniPageInsets.horizontalPadding(context);
  }

  /// Material 3 [NavigationBar] height — match [AppTheme.navigationBarTheme].
  static const double navigationBarHeight = PraniPageInsets.navigationBarHeight;

  /// Extra scroll padding: safe area + nav bar + comfort gap.
  static double scrollBottomPadding(BuildContext context) {
    return PraniPageInsets.bottomNavContentPadding(context, comfortGap: 28);
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
  static const double serviceCardRadius = PraniRadii.homeServiceTile;
}

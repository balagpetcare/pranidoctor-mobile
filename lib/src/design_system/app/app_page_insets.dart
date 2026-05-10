import 'package:flutter/material.dart';

import '../prani_page_insets.dart';

/// P01 page gutters + bottom inset for shell [NavigationBar] — delegates to [PraniPageInsets].
abstract final class AppPageInsets {
  static const double navigationBarHeight = PraniPageInsets.navigationBarHeight;

  static double horizontalPadding(BuildContext context) =>
      PraniPageInsets.horizontalPadding(context);

  static double bottomNavContentPadding(
    BuildContext context, {
    double comfortGap = 24,
  }) =>
      PraniPageInsets.bottomNavContentPadding(context, comfortGap: comfortGap);
}

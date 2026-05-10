import 'package:flutter/material.dart';

import '../prani_page_insets.dart';

/// Tab-body wrapper: top [SafeArea], no bottom safe area (shell nav owns inset).
///
/// Use with [PraniBottomNavContentPadding] (or [PraniPageInsets.bottomNavContentPadding])
/// on scroll content above the shell [NavigationBar].
class PraniSafePage extends StatelessWidget {
  const PraniSafePage({
    super.key,
    required this.child,
    this.topSafeArea = true,
  });

  final Widget child;
  final bool topSafeArea;

  @override
  Widget build(BuildContext context) {
    return SafeArea(top: topSafeArea, bottom: false, child: child);
  }
}

/// Pads only the bottom so list/grid content is not covered by the shell nav bar.
class PraniBottomNavContentPadding extends StatelessWidget {
  const PraniBottomNavContentPadding({
    super.key,
    this.comfortGap = 24,
    this.child,
  });

  final double comfortGap;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final h = PraniPageInsets.bottomNavContentPadding(
      context,
      comfortGap: comfortGap,
    );
    return Padding(
      padding: EdgeInsets.only(bottom: h),
      child: child,
    );
  }
}

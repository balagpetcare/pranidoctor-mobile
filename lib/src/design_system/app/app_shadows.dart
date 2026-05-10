import 'package:flutter/material.dart';

import '../prani_tokens.dart';

/// P01 elevation shadows — delegates to [PraniShadows].
abstract final class AppShadows {
  static List<BoxShadow> get cardLight => PraniShadows.cardLight;
  static List<BoxShadow> get homeCardSoft => PraniShadows.homeCardSoft;
  static List<BoxShadow> get cardDark => PraniShadows.cardDark;

  static List<BoxShadow> elevatedCard(Brightness brightness) =>
      PraniShadows.elevatedCardShadow(brightness);
}

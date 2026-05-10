import 'package:flutter/material.dart';

/// Prani Doctor brand palette and layout tokens (Bengali-first UI; reuse on every screen).
///
/// [AppTheme] maps these into [ColorScheme] / component themes; screens should prefer
/// `Theme.of(context).colorScheme` for semantic colors and these constants for spacing,
/// radii, and shadows instead of duplicating literals.
abstract final class PraniColors {
  static const Color primary = Color(0xFF08A88F);
  static const Color secondary = Color(0xFF38BDF8);
  static const Color accent = Color(0xFFFF9D3D);
  static const Color white = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF3F5F7);
  static const Color textDark = Color(0xFF1F2937);
  static const Color textMuted = Color(0xFF6B7280);
  static const Color outlineSoft = Color(0xFFE5E7EB);

  /// Dark shell background (not in marketing spec; kept readable with seed tones).
  static const Color darkScaffold = Color(0xFF0F1715);
}

/// Spacing scale (4-based where possible) for padding and gaps.
abstract final class PraniSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 10;
  static const double md = 12;
  static const double lg = 14;
  static const double xl = 16;
  static const double xxl = 18;
  static const double xxxl = 22;
  static const double section = 32;
}

/// Corner radii: cards and heroes use larger rounding per brand direction.
abstract final class PraniRadii {
  static const double sm = 10;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;

  /// Home 2×2 service tiles (matches [HomeLayout.serviceCardRadius]).
  static const double homeServiceTile = 22;
}

/// Soft elevation shadows (cards, floating surfaces).
abstract final class PraniShadows {
  static const Color _umbra = Color(0x1A1F2937);

  static List<BoxShadow> cardLight = const [
    BoxShadow(
      color: _umbra,
      offset: Offset(0, 4),
      blurRadius: 14,
      spreadRadius: -2,
    ),
    BoxShadow(
      color: Color(0x0D1F2937),
      offset: Offset(0, 2),
      blurRadius: 6,
      spreadRadius: -1,
    ),
  ];

  /// Softer elevation for dense home grids (Pixel-friendly).
  static List<BoxShadow> homeCardSoft = const [
    BoxShadow(
      color: Color(0x081F2937),
      offset: Offset(0, 3),
      blurRadius: 12,
      spreadRadius: -2,
    ),
    BoxShadow(
      color: Color(0x061F2937),
      offset: Offset(0, 1),
      blurRadius: 5,
      spreadRadius: -1,
    ),
  ];

  static List<BoxShadow> cardDark = const [
    BoxShadow(
      color: Color(0x66000000),
      offset: Offset(0, 4),
      blurRadius: 12,
      spreadRadius: -2,
    ),
  ];

  /// Cards sitting on scaffold canvas (theme-aware shadow).
  static List<BoxShadow> elevatedCardShadow(Brightness brightness) {
    return brightness == Brightness.dark ? cardDark : homeCardSoft;
  }
}

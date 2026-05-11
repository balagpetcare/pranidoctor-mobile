import 'package:flutter/material.dart';

/// Prani Doctor brand and layout tokens (Bengali-first UI).
///
/// **Canonical sources:** [PraniColors], [PraniSpacing], [PraniRadius], [PraniTextStyles].
/// [AppTheme] maps colors into [ColorScheme]; prefer `Theme.of(context).colorScheme` in widgets.
///
/// [PraniRadii] remains as a backward-compatible alias for older imports.
abstract final class PraniColors {
  // —— Brand ——
  static const Color primary = Color(0xFF08A88F);
  static const Color primaryDark = Color(0xFF067A68);
  static const Color primaryLight = Color(0xFFBFE8E0);
  static const Color secondary = Color(0xFF38BDF8);
  static const Color accent = Color(0xFFFF9D3D);

  // —— Semantic feedback ——
  static const Color success = Color(0xFF059669);
  static const Color successBright = Color(0xFF34D399);
  static const Color warning = Color(0xFFB45309);
  static const Color warningBright = Color(0xFFFBBF24);
  static const Color danger = Color(0xFFDC2626);
  static const Color info = Color(0xFF0284C7);

  // —— Neutrals / surfaces ——
  static const Color white = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF3F5F7);
  static const Color surface = white;
  static const Color surfaceAlt = Color(0xFFF7F8FA);

  // —— Text ——
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF374151);
  static const Color textMuted = Color(0xFF6B7280);

  /// Legacy name (same as [textPrimary]) — kept for existing references.
  static const Color textDark = textPrimary;

  // —— Lines / states ——
  static const Color border = Color(0xFFE5E7EB);
  static const Color divider = Color(0xFFE8EAED);

  /// Legacy name (same as [border]) — kept for existing references.
  static const Color outlineSoft = border;

  static const Color disabled = Color(0xFF9CA3AF);
  static const Color shadow = Color(0xFF1F2937);

  /// Dark scaffold canvas (dark theme).
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

  /// Default horizontal page gutter when not using responsive [PraniPageInsets].
  static const double pageHorizontal = 16;

  /// Default vertical spacing between major blocks on a page.
  static const double pageVertical = 16;
}

/// Corner radii — canonical token class (prefer this name in new code).
abstract final class PraniRadius {
  static const double sm = 10;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;

  /// Full pill / chip-like rounding (large clamp).
  static const double pill = 999;

  /// Default elevated cards / sheets (matches prior card rounding).
  static const double card = lg;

  /// Home 2×2 service tiles — matches [HomeLayout.serviceCardRadius].
  static const double homeServiceTile = 22;
}

/// Legacy alias — delegates to [PraniRadius] so existing imports keep working.
abstract final class PraniRadii {
  static const double sm = PraniRadius.sm;
  static const double md = PraniRadius.md;
  static const double lg = PraniRadius.lg;
  static const double xl = PraniRadius.xl;
  static const double homeServiceTile = PraniRadius.homeServiceTile;
}

/// Bengali-friendly typography helpers + Material 2021 merge.
///
/// **Fonts:** No bundled font in [pubspec.yaml]; device/system fonts are used with
/// [kFontFallback] so Bengali glyphs resolve when available (e.g. Noto on many Android builds).
abstract final class PraniTextStyles {
  static const List<String> kFontFallback = <String>[
    'Noto Sans Bengali',
    'Noto Sans',
    'sans-serif',
  ];

  /// Large marketing / hero headline.
  static TextStyle display(ColorScheme scheme, TextTheme t) =>
      (t.headlineMedium ?? const TextStyle()).copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        height: 1.28,
        color: scheme.onSurface,
        fontFamilyFallback: kFontFallback,
      );

  /// Screen titles (AppBar-style emphasis).
  static TextStyle title(ColorScheme scheme, TextTheme t) =>
      (t.titleLarge ?? const TextStyle()).copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        height: 1.35,
        color: scheme.onSurface,
        fontFamilyFallback: kFontFallback,
      );

  /// Hero / marketing titles on landing screens (~24–26 logical px).
  static TextStyle pageTitleProminent(ColorScheme scheme, TextTheme t) => title(
    scheme,
    t,
  ).copyWith(fontSize: 24, fontWeight: FontWeight.w700, height: 1.3);

  /// Section headers.
  static TextStyle heading(ColorScheme scheme, TextTheme t) =>
      (t.titleMedium ?? const TextStyle()).copyWith(
        fontWeight: FontWeight.w700,
        height: 1.25,
        color: scheme.onSurface,
        fontFamilyFallback: kFontFallback,
      );

  /// Primary section title on scroll pages (~18–20 px).
  static TextStyle sectionTitleProminent(ColorScheme scheme, TextTheme t) =>
      heading(scheme, t).copyWith(fontSize: 19, height: 1.28);

  /// Card titles inside [PraniFormCard] / lists (~16–17 px).
  static TextStyle cardTitleProminent(ColorScheme scheme, TextTheme t) =>
      subheading(
        scheme,
        t,
      ).copyWith(fontSize: 17, fontWeight: FontWeight.w700, height: 1.28);

  static TextStyle subheading(ColorScheme scheme, TextTheme t) =>
      (t.titleSmall ?? const TextStyle()).copyWith(
        fontWeight: FontWeight.w600,
        height: 1.3,
        color: scheme.onSurface,
        fontFamilyFallback: kFontFallback,
      );

  /// Primary reading text (minimum 16 logical px for legibility).
  static TextStyle body(ColorScheme scheme, TextTheme t) =>
      (t.bodyLarge ?? const TextStyle()).copyWith(
        height: 1.45,
        fontSize: 16,
        color: scheme.onSurface,
        fontFamilyFallback: kFontFallback,
      );

  static TextStyle bodySmall(ColorScheme scheme, TextTheme t) =>
      (t.bodySmall ?? const TextStyle()).copyWith(
        height: 1.4,
        fontSize: 14,
        color: scheme.onSurface,
        fontFamilyFallback: kFontFallback,
      );

  static TextStyle bodyMuted(ColorScheme scheme, TextTheme t) =>
      (t.bodyMedium ?? const TextStyle()).copyWith(
        height: 1.45,
        fontSize: 15,
        color: scheme.onSurfaceVariant,
        fontFamilyFallback: kFontFallback,
      );

  static TextStyle label(ColorScheme scheme, TextTheme t) =>
      (t.labelLarge ?? const TextStyle()).copyWith(
        fontWeight: FontWeight.w500,
        height: 1.35,
        fontSize: 14,
        color: scheme.onSurface,
        fontFamilyFallback: kFontFallback,
      );

  /// Auxiliary only — avoid for long Bengali paragraphs.
  static TextStyle caption(ColorScheme scheme, TextTheme t) =>
      (t.bodySmall ?? const TextStyle()).copyWith(
        height: 1.38,
        fontSize: 13,
        color: scheme.onSurfaceVariant,
        fontFamilyFallback: kFontFallback,
      );

  static TextStyle button(ColorScheme scheme, TextTheme t) =>
      (t.labelLarge ?? const TextStyle()).copyWith(
        fontWeight: FontWeight.w600,
        height: 1.2,
        fontSize: 15,
        letterSpacing: 0.15,
        fontFamilyFallback: kFontFallback,
      );

  static TextStyle input(ColorScheme scheme, TextTheme t) =>
      (t.bodyLarge ?? const TextStyle()).copyWith(
        height: 1.45,
        fontSize: 16,
        color: scheme.onSurface,
        fontFamilyFallback: kFontFallback,
      );

  /// Outlined field floating labels — BN-friendly size.
  static TextStyle formLabel(ColorScheme scheme, TextTheme t) =>
      label(scheme, t).copyWith(fontSize: 15, height: 1.38);

  /// Helper / secondary lines under labels (not [caption] — avoids tiny BN).
  static TextStyle formHelper(ColorScheme scheme, TextTheme t) =>
      bodySmall(scheme, t).copyWith(
        fontSize: 13.5,
        height: 1.42,
        color: scheme.onSurfaceVariant,
        fontFamilyFallback: kFontFallback,
      );

  /// Central [TextTheme] — Material 2021 base + Bengali-safe line heights (matches legacy app tuning).
  static TextTheme mergeMaterial2021(
    ColorScheme scheme,
    Brightness brightness,
  ) {
    final material = Typography.material2021(platform: TargetPlatform.android);
    final raw = brightness == Brightness.dark ? material.white : material.black;
    final base = raw.apply(
      bodyColor: scheme.onSurface,
      displayColor: scheme.onSurface,
      fontFamilyFallback: kFontFallback,
    );
    return base.copyWith(
      bodyLarge: base.bodyLarge?.copyWith(
        height: 1.45,
        fontFamilyFallback: kFontFallback,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        height: 1.45,
        fontFamilyFallback: kFontFallback,
      ),
      bodySmall: base.bodySmall?.copyWith(
        height: 1.4,
        fontFamilyFallback: kFontFallback,
      ),
      titleLarge: title(scheme, base),
      titleMedium: base.titleMedium?.copyWith(
        height: 1.35,
        fontFamilyFallback: kFontFallback,
      ),
      headlineSmall: base.headlineSmall?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
        height: 1.28,
        fontFamilyFallback: kFontFallback,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        height: 1.2,
        fontFamilyFallback: kFontFallback,
      ),
    );
  }
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

/// Standard animation durations (optional — use in transitions).
abstract final class PraniDurations {
  static const Duration short = Duration(milliseconds: 200);
  static const Duration medium = Duration(milliseconds: 300);
  static const Duration long = Duration(milliseconds: 450);
}

import 'package:flutter/material.dart';

/// Bengali-first readable typography built on Material 2021.
/// Use [TextTheme] from [Theme.of(context).textTheme] — this file documents roles.
abstract final class PdTypography {
  static TextTheme textTheme(ColorScheme scheme, Brightness brightness) {
    final material = Typography.material2021(platform: TargetPlatform.android);
    final raw = brightness == Brightness.dark ? material.white : material.black;
    final base = raw.apply(
      bodyColor: scheme.onSurface,
      displayColor: scheme.onSurface,
      fontFamilyFallback: const [
        'Noto Sans Bengali',
        'Noto Sans',
        'sans-serif',
      ],
    );
    return base.copyWith(
      bodyLarge: base.bodyLarge?.copyWith(height: 1.45),
      bodyMedium: base.bodyMedium?.copyWith(height: 1.45),
      bodySmall: base.bodySmall?.copyWith(height: 1.4),
      titleLarge: base.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        height: 1.35,
      ),
      titleMedium: base.titleMedium?.copyWith(height: 1.35),
      titleSmall: base.titleSmall?.copyWith(height: 1.35),
      labelLarge: base.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
        height: 1.25,
      ),
      labelMedium: base.labelMedium?.copyWith(height: 1.25),
      labelSmall: base.labelSmall?.copyWith(height: 1.2),
      headlineSmall: base.headlineSmall?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
        height: 1.28,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        height: 1.2,
      ),
    );
  }

  /// Page / hero heading — maps to `headlineMedium` / `headlineSmall`.
  static TextStyle? heading(TextTheme t) => t.headlineSmall;

  /// Section titles — `titleLarge`.
  static TextStyle? title(TextTheme t) => t.titleLarge;

  /// Card row titles — `titleMedium`.
  static TextStyle? subtitle(TextTheme t) => t.titleMedium;

  /// Primary reading — `bodyLarge` / `bodyMedium`.
  static TextStyle? body(TextTheme t) => t.bodyLarge;

  /// Meta, captions — `bodySmall`.
  static TextStyle? caption(TextTheme t) => t.bodySmall;

  /// Buttons — `labelLarge`.
  static TextStyle? button(TextTheme t) => t.labelLarge;
}

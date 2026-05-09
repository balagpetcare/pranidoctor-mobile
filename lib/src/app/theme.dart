import 'package:flutter/material.dart';

import '../design_system/prani_tokens.dart';

/// Prani Doctor — brand teal / sky / soft orange (farm & animal health, Bengali-first).
/// Prefer `Theme.of(context).colorScheme` in widgets; spacing and radii use [PraniSpacing] / [PraniRadii].
abstract final class AppTheme {
  static ColorScheme _lightScheme() {
    final base = ColorScheme.fromSeed(
      seedColor: PraniColors.primary,
      brightness: Brightness.light,
    );
    return base.copyWith(
      primary: PraniColors.primary,
      onPrimary: PraniColors.white,
      primaryContainer: const Color(0xFFBFE8E0),
      onPrimaryContainer: PraniColors.textDark,
      secondary: PraniColors.secondary,
      onSecondary: PraniColors.white,
      secondaryContainer: const Color(0xFFD3EEFC),
      onSecondaryContainer: PraniColors.textDark,
      tertiary: PraniColors.accent,
      onTertiary: PraniColors.textDark,
      tertiaryContainer: const Color(0xFFFFE8CC),
      onTertiaryContainer: PraniColors.textDark,
      surface: PraniColors.white,
      onSurface: PraniColors.textDark,
      onSurfaceVariant: PraniColors.textMuted,
      surfaceContainerLowest: PraniColors.white,
      surfaceContainerLow: const Color(0xFFF7F8FA),
      surfaceContainerHighest: const Color(0xFFE8EAED),
      error: base.error,
      onError: base.onError,
      outline: PraniColors.outlineSoft,
      outlineVariant: const Color(0xFFE5E7EB),
    );
  }

  static ColorScheme _darkScheme() {
    final base = ColorScheme.fromSeed(
      seedColor: PraniColors.primary,
      brightness: Brightness.dark,
    );
    return base.copyWith(
      primary: const Color(0xFF4ECDB5),
      onPrimary: const Color(0xFF052822),
      primaryContainer: const Color(0xFF065F52),
      onPrimaryContainer: const Color(0xFFE8FBF7),
      secondary: PraniColors.secondary,
      onSecondary: PraniColors.textDark,
      tertiary: PraniColors.accent,
      onTertiary: PraniColors.textDark,
      surface: const Color(0xFF1A2220),
      onSurface: const Color(0xFFF3F5F7),
      onSurfaceVariant: const Color(0xFF9CA3AF),
      surfaceContainerLowest: const Color(0xFF131A18),
      surfaceContainerHigh: const Color(0xFF242E2C),
      surfaceContainerHighest: const Color(0xFF2F3D3A),
      outline: const Color(0xFF3D4A47),
      outlineVariant: const Color(0xFF374140),
    );
  }

  static ThemeData get light {
    final scheme = _lightScheme();
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: PraniColors.background,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: scheme.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shadowColor: const Color(0x141F2937),
        surfaceTintColor: Colors.transparent,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PraniRadii.lg),
        ),
        color: scheme.surface,
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerLow,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: PraniSpacing.xl,
          vertical: PraniSpacing.lg,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(PraniRadii.md),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(PraniRadii.md),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(PraniRadii.md),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(
            horizontal: PraniSpacing.xl + 4,
            vertical: PraniSpacing.lg,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(PraniRadii.md),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(
            horizontal: PraniSpacing.xl,
            vertical: PraniSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(PraniRadii.md),
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        backgroundColor: scheme.surface,
        indicatorColor: scheme.primaryContainer,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: scheme.primary, size: 24);
          }
          return IconThemeData(color: scheme.onSurfaceVariant, size: 24);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
              height: 1.2,
              color: scheme.primary,
            );
          }
          return TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 12,
            height: 1.2,
            color: scheme.onSurfaceVariant,
          );
        }),
      ),
      textTheme: _textTheme(scheme, Brightness.light),
    );
  }

  static ThemeData get dark {
    final scheme = _darkScheme();
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: PraniColors.darkScaffold,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: scheme.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 3,
        shadowColor: const Color(0x66000000),
        surfaceTintColor: Colors.transparent,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PraniRadii.lg),
        ),
        color: scheme.surfaceContainerHigh,
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: PraniSpacing.xl,
          vertical: PraniSpacing.lg,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(PraniRadii.md),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(PraniRadii.md),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(PraniRadii.md),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(
            horizontal: PraniSpacing.xl + 4,
            vertical: PraniSpacing.lg,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(PraniRadii.md),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(
            horizontal: PraniSpacing.xl,
            vertical: PraniSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(PraniRadii.md),
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        backgroundColor: scheme.surface,
        indicatorColor: scheme.primaryContainer,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: scheme.primary, size: 24);
          }
          return IconThemeData(color: scheme.onSurfaceVariant, size: 24);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
              height: 1.2,
              color: scheme.primary,
            );
          }
          return TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 12,
            height: 1.2,
            color: scheme.onSurfaceVariant,
          );
        }),
      ),
      textTheme: _textTheme(scheme, Brightness.dark),
    );
  }

  static TextTheme _textTheme(ColorScheme scheme, Brightness brightness) {
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
}

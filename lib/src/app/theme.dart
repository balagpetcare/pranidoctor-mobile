import 'package:flutter/material.dart';

import '../design_system/prani_tokens.dart';

/// Prani Doctor — brand teal / sky / soft orange (farm & animal health, Bengali-first).
///
/// Spacing/radii use [PraniSpacing] / [PraniRadius]; typography merges via
/// [PraniTextStyles.mergeMaterial2021]. Component defaults prefer theme-wide styling.
abstract final class AppTheme {
  static ColorScheme _lightScheme() {
    final base = ColorScheme.fromSeed(
      seedColor: PraniColors.primary,
      brightness: Brightness.light,
    );
    return base.copyWith(
      primary: PraniColors.primary,
      onPrimary: PraniColors.white,
      primaryContainer: PraniColors.primaryLight,
      onPrimaryContainer: PraniColors.textPrimary,
      secondary: PraniColors.secondary,
      onSecondary: PraniColors.white,
      secondaryContainer: const Color(0xFFD3EEFC),
      onSecondaryContainer: PraniColors.textPrimary,
      tertiary: PraniColors.accent,
      onTertiary: PraniColors.textPrimary,
      tertiaryContainer: const Color(0xFFFFE8CC),
      onTertiaryContainer: PraniColors.textPrimary,
      surface: PraniColors.surface,
      onSurface: PraniColors.textPrimary,
      onSurfaceVariant: PraniColors.textMuted,
      surfaceContainerLowest: PraniColors.white,
      surfaceContainerLow: PraniColors.surfaceAlt,
      surfaceContainerHighest: const Color(0xFFE8EAED),
      error: PraniColors.danger,
      onError: PraniColors.white,
      outline: PraniColors.border,
      outlineVariant: PraniColors.divider,
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
      onSecondary: PraniColors.textPrimary,
      tertiary: PraniColors.accent,
      onTertiary: PraniColors.textPrimary,
      surface: const Color(0xFF1A2220),
      onSurface: const Color(0xFFF3F5F7),
      onSurfaceVariant: const Color(0xFFB4BDC6),
      surfaceContainerLowest: const Color(0xFF131A18),
      surfaceContainerHigh: const Color(0xFF242E2C),
      surfaceContainerHighest: const Color(0xFF2F3D3A),
      error: const Color(0xFFF87171),
      onError: const Color(0xFF450A0A),
      outline: const Color(0xFF3D4A47),
      outlineVariant: const Color(0xFF374140),
    );
  }

  static ThemeData get light {
    final scheme = _lightScheme();
    final textTheme = PraniTextStyles.mergeMaterial2021(
      scheme,
      Brightness.light,
    );
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
        titleTextStyle: PraniTextStyles.title(scheme, textTheme),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shadowColor: PraniColors.shadow.withValues(alpha: 0.08),
        surfaceTintColor: Colors.transparent,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PraniRadius.lg),
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
          borderRadius: BorderRadius.circular(PraniRadius.md),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(PraniRadius.md),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(PraniRadius.md),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
        labelStyle: PraniTextStyles.label(scheme, textTheme),
        hintStyle: PraniTextStyles.bodyMuted(scheme, textTheme),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          shadowColor: PraniColors.shadow.withValues(alpha: 0.2),
          foregroundColor: scheme.onPrimary,
          backgroundColor: scheme.primary,
          disabledForegroundColor: scheme.onSurface.withValues(alpha: 0.38),
          disabledBackgroundColor: scheme.onSurface.withValues(alpha: 0.12),
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(
            horizontal: PraniSpacing.xl + 4,
            vertical: PraniSpacing.lg,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(PraniRadius.md),
          ),
          textStyle: PraniTextStyles.button(scheme, textTheme),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          foregroundColor: scheme.onPrimary,
          backgroundColor: scheme.primary,
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(
            horizontal: PraniSpacing.xl + 4,
            vertical: PraniSpacing.lg,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(PraniRadius.md),
          ),
          textStyle: PraniTextStyles.button(scheme, textTheme),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.primary,
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(
            horizontal: PraniSpacing.xl,
            vertical: PraniSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(PraniRadius.md),
          ),
          side: BorderSide(color: scheme.outline),
          textStyle: PraniTextStyles.button(scheme, textTheme),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.primary,
          minimumSize: const Size(48, 44),
          padding: const EdgeInsets.symmetric(
            horizontal: PraniSpacing.md,
            vertical: PraniSpacing.sm,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(PraniRadius.md),
          ),
          textStyle: PraniTextStyles.button(scheme, textTheme),
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
              height: 1.35,
              color: scheme.primary,
              fontFamilyFallback: PraniTextStyles.kFontFallback,
            );
          }
          return TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 12,
            height: 1.35,
            color: scheme.onSurfaceVariant,
            fontFamilyFallback: PraniTextStyles.kFontFallback,
          );
        }),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant.withValues(alpha: 0.45),
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        elevation: 4,
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: PraniTextStyles.body(
          scheme,
          textTheme,
        ).copyWith(color: scheme.onInverseSurface),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PraniRadius.md),
        ),
      ),
      dialogTheme: DialogThemeData(
        elevation: 3,
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PraniRadius.lg),
        ),
        titleTextStyle: PraniTextStyles.title(scheme, textTheme),
        contentTextStyle: PraniTextStyles.body(scheme, textTheme),
      ),
      textTheme: textTheme,
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PraniRadius.xl),
        ),
        side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.45)),
        backgroundColor: scheme.surfaceContainerHigh,
        disabledColor: scheme.surfaceContainerLow,
        selectedColor: scheme.primaryContainer,
        secondarySelectedColor: scheme.primaryContainer,
        labelStyle: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 13,
          height: 1.25,
          color: scheme.onSurface,
          fontFamilyFallback: PraniTextStyles.kFontFallback,
        ),
        secondaryLabelStyle: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 13,
          color: scheme.onSurfaceVariant,
          fontFamilyFallback: PraniTextStyles.kFontFallback,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      ),
    );
  }

  static ThemeData get dark {
    final scheme = _darkScheme();
    final textTheme = PraniTextStyles.mergeMaterial2021(
      scheme,
      Brightness.dark,
    );
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
        titleTextStyle: PraniTextStyles.title(scheme, textTheme),
      ),
      cardTheme: CardThemeData(
        elevation: 3,
        shadowColor: const Color(0x66000000),
        surfaceTintColor: Colors.transparent,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PraniRadius.lg),
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
          borderRadius: BorderRadius.circular(PraniRadius.md),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(PraniRadius.md),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(PraniRadius.md),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
        labelStyle: PraniTextStyles.label(scheme, textTheme),
        hintStyle: PraniTextStyles.bodyMuted(scheme, textTheme),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          shadowColor: Colors.black54,
          foregroundColor: scheme.onPrimary,
          backgroundColor: scheme.primary,
          disabledForegroundColor: scheme.onSurface.withValues(alpha: 0.38),
          disabledBackgroundColor: scheme.onSurface.withValues(alpha: 0.12),
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(
            horizontal: PraniSpacing.xl + 4,
            vertical: PraniSpacing.lg,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(PraniRadius.md),
          ),
          textStyle: PraniTextStyles.button(scheme, textTheme),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          foregroundColor: scheme.onPrimary,
          backgroundColor: scheme.primary,
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(
            horizontal: PraniSpacing.xl + 4,
            vertical: PraniSpacing.lg,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(PraniRadius.md),
          ),
          textStyle: PraniTextStyles.button(scheme, textTheme),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.primary,
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(
            horizontal: PraniSpacing.xl,
            vertical: PraniSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(PraniRadius.md),
          ),
          side: BorderSide(color: scheme.outline),
          textStyle: PraniTextStyles.button(scheme, textTheme),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.primary,
          minimumSize: const Size(48, 44),
          padding: const EdgeInsets.symmetric(
            horizontal: PraniSpacing.md,
            vertical: PraniSpacing.sm,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(PraniRadius.md),
          ),
          textStyle: PraniTextStyles.button(scheme, textTheme),
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
              height: 1.35,
              color: scheme.primary,
              fontFamilyFallback: PraniTextStyles.kFontFallback,
            );
          }
          return TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 12,
            height: 1.35,
            color: scheme.onSurfaceVariant,
            fontFamilyFallback: PraniTextStyles.kFontFallback,
          );
        }),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant.withValues(alpha: 0.5),
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        elevation: 4,
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: PraniTextStyles.body(
          scheme,
          textTheme,
        ).copyWith(color: scheme.onInverseSurface),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PraniRadius.md),
        ),
      ),
      dialogTheme: DialogThemeData(
        elevation: 3,
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PraniRadius.lg),
        ),
        titleTextStyle: PraniTextStyles.title(scheme, textTheme),
        contentTextStyle: PraniTextStyles.body(scheme, textTheme),
      ),
      textTheme: textTheme,
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PraniRadius.xl),
        ),
        side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.55)),
        backgroundColor: scheme.surfaceContainerHighest,
        disabledColor: scheme.surfaceContainerLow,
        selectedColor: scheme.primaryContainer,
        secondarySelectedColor: scheme.primaryContainer,
        labelStyle: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 13,
          height: 1.25,
          color: scheme.onSurface,
          fontFamilyFallback: PraniTextStyles.kFontFallback,
        ),
        secondaryLabelStyle: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 13,
          color: scheme.onSurfaceVariant,
          fontFamilyFallback: PraniTextStyles.kFontFallback,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../core/constants/pd_radii.dart';
import '../core/constants/pd_spacing.dart';
import '../core/theme/pd_palette.dart';
import '../core/theme/pd_semantic_colors.dart';
import '../core/theme/pd_typography.dart';

/// Prani Doctor — teal–emerald veterinary palette, Bengali-first typography.
abstract final class AppTheme {
  static ThemeData get light => _build(Brightness.light);

  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: PdPalette.primaryGreen,
      brightness: brightness,
    );
    final semantic = brightness == Brightness.light
        ? PdSemanticColors.light(scheme)
        : PdSemanticColors.dark(scheme);

    final scaffoldBg = brightness == Brightness.light
        ? semantic.medicalSurface
        : PdPalette.darkScaffold;

    final textTheme = PdTypography.textTheme(scheme, brightness);

    final borderRadius = BorderRadius.circular(PdRadii.input);
    final buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(PdRadii.button),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scaffoldBg,
      extensions: <ThemeExtension<dynamic>>[semantic],
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: scheme.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PdRadii.card),
        ),
        color: brightness == Brightness.light
            ? scheme.surfaceContainerLowest
            : scheme.surfaceContainerHigh,
        margin: EdgeInsets.zero,
        shadowColor: scheme.shadow,
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: PdSpacing.md,
          vertical: PdSpacing.sm + 2,
        ),
        border: OutlineInputBorder(borderRadius: borderRadius),
        enabledBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: scheme.error),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(PdSpacing.minTapHeight),
          padding: const EdgeInsets.symmetric(
            horizontal: PdSpacing.lg,
            vertical: PdSpacing.sm + 2,
          ),
          shape: buttonShape,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(PdSpacing.minTapHeight),
          padding: const EdgeInsets.symmetric(
            horizontal: PdSpacing.lg,
            vertical: PdSpacing.sm + 2,
          ),
          elevation: 0,
          shape: buttonShape,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(PdSpacing.minTapHeight),
          padding: const EdgeInsets.symmetric(
            horizontal: PdSpacing.md,
            vertical: PdSpacing.sm,
          ),
          shape: buttonShape,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size.fromHeight(44),
          padding: const EdgeInsets.symmetric(
            horizontal: PdSpacing.md,
            vertical: PdSpacing.sm,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(PdRadii.button),
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        backgroundColor: scheme.surface,
        indicatorColor: scheme.primaryContainer,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(fontWeight: FontWeight.w600, fontSize: 12);
          }
          return const TextStyle(fontWeight: FontWeight.w500, fontSize: 12);
        }),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: scheme.surface,
        selectedItemColor: scheme.primary,
        unselectedItemColor: scheme.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PdRadii.sm),
        ),
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: TextStyle(color: scheme.onInverseSurface),
      ),
      textTheme: textTheme,
    );
  }
}

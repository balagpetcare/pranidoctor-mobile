import 'package:flutter/material.dart';

import 'pd_palette.dart';

/// App-specific colors accessible via [ThemeData.extensions].
/// Falls back sensibly when extension is missing (tests / partial themes).
@immutable
class PdSemanticColors extends ThemeExtension<PdSemanticColors> {
  const PdSemanticColors({
    required this.primaryGreen,
    required this.darkGreen,
    required this.lightGreen,
    required this.medicalSurface,
    required this.textPrimary,
    required this.textSecondary,
    required this.borderDefault,
    required this.success,
    required this.warning,
    required this.error,
    required this.info,
  });

  final Color primaryGreen;
  final Color darkGreen;
  final Color lightGreen;
  final Color medicalSurface;
  final Color textPrimary;
  final Color textSecondary;
  final Color borderDefault;
  final Color success;
  final Color warning;
  final Color error;
  final Color info;

  static PdSemanticColors light(ColorScheme scheme) {
    return PdSemanticColors(
      primaryGreen: scheme.primary,
      darkGreen: PdPalette.darkGreen,
      lightGreen: PdPalette.lightGreen,
      medicalSurface: PdPalette.medicalWhite,
      textPrimary: scheme.onSurface,
      textSecondary: scheme.onSurfaceVariant,
      borderDefault: scheme.outlineVariant,
      success: PdPalette.success,
      warning: PdPalette.warning,
      error: scheme.error,
      info: PdPalette.info,
    );
  }

  static PdSemanticColors dark(ColorScheme scheme) {
    return PdSemanticColors(
      primaryGreen: scheme.primary,
      darkGreen: const Color(0xFF14B8A6),
      lightGreen: const Color(0xFF134E4A),
      medicalSurface: PdPalette.darkScaffold,
      textPrimary: scheme.onSurface,
      textSecondary: scheme.onSurfaceVariant,
      borderDefault: scheme.outlineVariant,
      success: const Color(0xFF34D399),
      warning: const Color(0xFFFBBF24),
      error: scheme.error,
      info: const Color(0xFF22D3EE),
    );
  }

  static PdSemanticColors fallback(ColorScheme scheme) => light(scheme);

  @override
  PdSemanticColors copyWith({
    Color? primaryGreen,
    Color? darkGreen,
    Color? lightGreen,
    Color? medicalSurface,
    Color? textPrimary,
    Color? textSecondary,
    Color? borderDefault,
    Color? success,
    Color? warning,
    Color? error,
    Color? info,
  }) {
    return PdSemanticColors(
      primaryGreen: primaryGreen ?? this.primaryGreen,
      darkGreen: darkGreen ?? this.darkGreen,
      lightGreen: lightGreen ?? this.lightGreen,
      medicalSurface: medicalSurface ?? this.medicalSurface,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      borderDefault: borderDefault ?? this.borderDefault,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      error: error ?? this.error,
      info: info ?? this.info,
    );
  }

  @override
  PdSemanticColors lerp(ThemeExtension<PdSemanticColors>? other, double t) {
    if (other is! PdSemanticColors) return this;
    return PdSemanticColors(
      primaryGreen: Color.lerp(primaryGreen, other.primaryGreen, t)!,
      darkGreen: Color.lerp(darkGreen, other.darkGreen, t)!,
      lightGreen: Color.lerp(lightGreen, other.lightGreen, t)!,
      medicalSurface: Color.lerp(medicalSurface, other.medicalSurface, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      borderDefault: Color.lerp(borderDefault, other.borderDefault, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      error: Color.lerp(error, other.error, t)!,
      info: Color.lerp(info, other.info, t)!,
    );
  }
}

extension PdSemanticColorsContext on BuildContext {
  PdSemanticColors get pdSemanticColors {
    return Theme.of(this).extension<PdSemanticColors>() ??
        PdSemanticColors.fallback(Theme.of(this).colorScheme);
  }
}

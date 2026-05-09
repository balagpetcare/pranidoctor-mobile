import 'package:flutter/material.dart';

/// Soft elevation for cards (Material 3 mostly flat; subtle shadow for depth).
abstract final class PdShadows {
  static List<BoxShadow> softCard(ColorScheme scheme) {
    return [
      BoxShadow(
        color: scheme.shadow.withValues(alpha: 0.07),
        blurRadius: 10,
        offset: const Offset(0, 3),
      ),
      BoxShadow(
        color: scheme.shadow.withValues(alpha: 0.04),
        blurRadius: 4,
        offset: const Offset(0, 1),
      ),
    ];
  }
}

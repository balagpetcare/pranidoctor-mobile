import 'package:flutter/material.dart';

import '../app_radius.dart';

/// P01 compact icon in a themed container (lists, settings rows, chips).
class AppIconBadge extends StatelessWidget {
  const AppIconBadge({
    super.key,
    required this.icon,
    this.size = 44,
    this.borderRadius,
    this.backgroundColor,
    this.iconColor,
  });

  final IconData icon;
  final double size;
  final double? borderRadius;
  final Color? backgroundColor;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final r = borderRadius ?? AppRadius.md;
    final bg = backgroundColor ?? scheme.primaryContainer;
    final fg = iconColor ?? scheme.onPrimaryContainer;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(r),
      ),
      child: SizedBox(
        width: size,
        height: size,
        child: Center(
          child: Icon(icon, size: size * 0.45, color: fg),
        ),
      ),
    );
  }
}

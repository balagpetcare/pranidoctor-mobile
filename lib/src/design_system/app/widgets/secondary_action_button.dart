import 'package:flutter/material.dart';

import '../app_radius.dart';
import '../app_spacing.dart';

/// P01 full-width secondary action — uses theme [OutlinedButtonTheme].
class SecondaryActionButton extends StatelessWidget {
  const SecondaryActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final child = Text(label);
    final style = OutlinedButton.styleFrom(
      minimumSize: const Size(double.infinity, 50),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.md,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
    );

    if (icon != null) {
      return OutlinedButton.icon(
        style: style,
        onPressed: onPressed,
        icon: Icon(icon, size: 22),
        label: child,
      );
    }
    return OutlinedButton(style: style, onPressed: onPressed, child: child);
  }
}

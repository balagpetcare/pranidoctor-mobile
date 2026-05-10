import 'package:flutter/material.dart';

import '../prani_tokens.dart';

/// Primary call-to-action — full-width friendly, 48dp touch height.
class PraniPrimaryCtaButton extends StatelessWidget {
  const PraniPrimaryCtaButton({
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
    final style = FilledButton.styleFrom(
      minimumSize: const Size(double.infinity, 50),
      padding: const EdgeInsets.symmetric(
        horizontal: PraniSpacing.xl,
        vertical: PraniSpacing.md,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(PraniRadii.md),
      ),
    );

    if (icon != null) {
      return FilledButton.icon(
        style: style,
        onPressed: onPressed,
        icon: Icon(icon, size: 22),
        label: child,
      );
    }
    return FilledButton(style: style, onPressed: onPressed, child: child);
  }
}

import 'package:flutter/material.dart';

import '../prani_tokens.dart';

/// Primary filled CTA — uses [ThemeData.filledButtonTheme]; supports loading state.
class PraniPrimaryButton extends StatelessWidget {
  const PraniPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.fullWidth = true,
    this.minimumHeight = 48,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final bool fullWidth;
  final double minimumHeight;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final busy = isLoading;
    final effective = busy ? null : onPressed;

    final style = FilledButton.styleFrom(
      minimumSize: Size(fullWidth ? double.infinity : 48, minimumHeight),
      padding: const EdgeInsets.symmetric(
        horizontal: PraniSpacing.xl,
        vertical: PraniSpacing.md,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(PraniRadius.md),
      ),
    );

    Widget indicate(Widget child) {
      if (!busy) return child;
      return Stack(
        alignment: Alignment.center,
        children: [
          Opacity(opacity: 0.01, child: child),
          SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: scheme.onPrimary,
            ),
          ),
        ],
      );
    }

    final labelWidget = Text(label, textAlign: TextAlign.center);

    if (icon != null) {
      return indicate(
        FilledButton.icon(
          style: style,
          onPressed: effective,
          icon: Icon(icon, size: 22),
          label: labelWidget,
        ),
      );
    }

    return indicate(
      FilledButton(style: style, onPressed: effective, child: labelWidget),
    );
  }
}

/// Secondary actions — outline (default) or text (“ghost”).
enum PraniSecondaryStyle { outlined, text }

class PraniSecondaryButton extends StatelessWidget {
  const PraniSecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.fullWidth = false,
    this.style = PraniSecondaryStyle.outlined,
    this.minimumHeight = 48,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final bool fullWidth;
  final PraniSecondaryStyle style;
  final double minimumHeight;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final busy = isLoading;
    final effective = busy ? null : onPressed;

    final baseShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(PraniRadius.md),
    );

    Widget indicate(Widget child) {
      if (!busy) return child;
      return Stack(
        alignment: Alignment.center,
        children: [
          Opacity(opacity: 0.02, child: child),
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: scheme.primary,
            ),
          ),
        ],
      );
    }

    final labelWidget = Text(label);

    switch (style) {
      case PraniSecondaryStyle.outlined:
        final os = OutlinedButton.styleFrom(
          minimumSize: Size(fullWidth ? double.infinity : 48, minimumHeight),
          padding: const EdgeInsets.symmetric(
            horizontal: PraniSpacing.lg,
            vertical: PraniSpacing.sm,
          ),
          shape: baseShape,
        );
        if (icon != null) {
          return indicate(
            OutlinedButton.icon(
              style: os,
              onPressed: effective,
              icon: Icon(icon, size: 20),
              label: labelWidget,
            ),
          );
        }
        return indicate(
          OutlinedButton(style: os, onPressed: effective, child: labelWidget),
        );
      case PraniSecondaryStyle.text:
        final ts = TextButton.styleFrom(
          minimumSize: Size(fullWidth ? double.infinity : 48, minimumHeight),
          padding: const EdgeInsets.symmetric(
            horizontal: PraniSpacing.md,
            vertical: PraniSpacing.sm,
          ),
          shape: baseShape,
        );
        if (icon != null) {
          return indicate(
            TextButton.icon(
              style: ts,
              onPressed: effective,
              icon: Icon(icon, size: 20),
              label: labelWidget,
            ),
          );
        }
        return indicate(
          TextButton(style: ts, onPressed: effective, child: labelWidget),
        );
    }
  }
}

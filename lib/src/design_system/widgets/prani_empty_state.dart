import 'package:flutter/material.dart';

import '../prani_tokens.dart';
import 'prani_buttons.dart';

/// Generic empty / zero-result UI (friendly Bengali-first defaults).
class PraniEmptyState extends StatelessWidget {
  const PraniEmptyState({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.iconColor,
    this.actionLabel,
    this.onAction,
    this.customAction,
    this.boxed = false,
    this.maxContentWidth = 520,
  });

  final String title;
  final String message;
  final IconData icon;
  final Color? iconColor;
  final String? actionLabel;
  final VoidCallback? onAction;

  /// Optional custom action row (overrides [actionLabel]/[onAction] when set).
  final Widget? customAction;

  /// When true, draws the elevated surface used in list strips.
  final bool boxed;
  final double maxContentWidth;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final inner = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 46, color: iconColor ?? scheme.primary),
        const SizedBox(height: PraniSpacing.md),
        Text(
          title,
          textAlign: TextAlign.center,
          style: PraniTextStyles.heading(scheme, textTheme),
        ),
        const SizedBox(height: PraniSpacing.xs),
        Text(
          message,
          textAlign: TextAlign.center,
          style: PraniTextStyles.bodyMuted(
            scheme,
            textTheme,
          ).copyWith(height: 1.45),
        ),
        if (customAction != null) ...[
          const SizedBox(height: PraniSpacing.lg),
          customAction!,
        ] else if (actionLabel != null && onAction != null) ...[
          const SizedBox(height: PraniSpacing.lg),
          PraniPrimaryButton(
            label: actionLabel!,
            onPressed: onAction,
            fullWidth: false,
            icon: Icons.refresh_rounded,
          ),
        ],
      ],
    );

    final padded = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: PraniSpacing.xl,
        vertical: PraniSpacing.lg,
      ),
      child: inner,
    );

    if (!boxed) {
      return ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxContentWidth),
        child: padded,
      );
    }

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxContentWidth),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(PraniRadius.lg),
          border: Border.all(
            color: scheme.outlineVariant.withValues(alpha: 0.35),
          ),
          boxShadow: PraniShadows.elevatedCardShadow(scheme.brightness),
        ),
        child: padded,
      ),
    );
  }
}

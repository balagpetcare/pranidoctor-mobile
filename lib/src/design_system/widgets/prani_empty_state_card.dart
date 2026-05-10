import 'package:flutter/material.dart';

import '../prani_color_scheme_ext.dart';
import '../prani_tokens.dart';

/// Generic empty / zero-result state (lists, tabs, secondary surfaces).
class PraniEmptyStateCard extends StatelessWidget {
  const PraniEmptyStateCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon = Icons.inbox_outlined,
    this.action,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.praniElevatedCard,
        borderRadius: BorderRadius.circular(PraniRadii.lg),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.38),
        ),
        boxShadow: PraniShadows.elevatedCardShadow(scheme.brightness),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          PraniSpacing.xl,
          PraniSpacing.xl,
          PraniSpacing.xl,
          PraniSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 46, color: scheme.primary),
            const SizedBox(height: PraniSpacing.md),
            Text(
              title,
              textAlign: TextAlign.center,
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: scheme.praniOnElevatedCard,
                height: 1.3,
              ),
            ),
            const SizedBox(height: PraniSpacing.xs),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
                height: 1.45,
              ),
            ),
            if (action != null) ...[
              const SizedBox(height: PraniSpacing.lg),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

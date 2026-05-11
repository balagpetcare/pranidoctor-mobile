import 'package:flutter/material.dart';

import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';
import 'package:pranidoctor_mobile/src/features/workspace/domain/workspace_entry.dart';

class WorkspaceBadge extends StatelessWidget {
  const WorkspaceBadge({super.key, required this.badge});

  final WorkspaceBadgeInfo badge;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colors = _colorsForTone(badge.tone, scheme);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(PraniRadii.md),
        border: Border.all(color: colors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Text(
          badge.label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: colors.foreground,
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
    );
  }

  _WorkspaceBadgeColors _colorsForTone(
    WorkspaceBadgeTone tone,
    ColorScheme scheme,
  ) {
    switch (tone) {
      case WorkspaceBadgeTone.success:
        return _WorkspaceBadgeColors(
          background: scheme.primaryContainer.withValues(alpha: 0.72),
          border: scheme.primary.withValues(alpha: 0.35),
          foreground: scheme.primary,
        );
      case WorkspaceBadgeTone.warning:
        return _WorkspaceBadgeColors(
          background: scheme.tertiaryContainer.withValues(alpha: 0.72),
          border: scheme.tertiary.withValues(alpha: 0.4),
          foreground: scheme.tertiary,
        );
      case WorkspaceBadgeTone.danger:
        return _WorkspaceBadgeColors(
          background: scheme.errorContainer.withValues(alpha: 0.72),
          border: scheme.error.withValues(alpha: 0.4),
          foreground: scheme.error,
        );
      case WorkspaceBadgeTone.neutral:
        return _WorkspaceBadgeColors(
          background: scheme.surfaceContainerHighest.withValues(alpha: 0.7),
          border: scheme.outlineVariant.withValues(alpha: 0.55),
          foreground: scheme.onSurfaceVariant,
        );
    }
  }
}

class _WorkspaceBadgeColors {
  const _WorkspaceBadgeColors({
    required this.background,
    required this.border,
    required this.foreground,
  });

  final Color background;
  final Color border;
  final Color foreground;
}


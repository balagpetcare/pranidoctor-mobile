import 'package:flutter/material.dart';

import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_premium_card.dart';

/// Compact status badge for professional dashboard tiles.
class ProfessionalStatusBadge extends StatelessWidget {
  const ProfessionalStatusBadge({
    super.key,
    required this.label,
    required this.tone,
  });

  final String label;
  final ProfessionalStatusBadgeTone tone;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final background = switch (tone) {
      ProfessionalStatusBadgeTone.success => scheme.primaryContainer,
      ProfessionalStatusBadgeTone.warning => scheme.tertiaryContainer,
      ProfessionalStatusBadgeTone.info => scheme.secondaryContainer,
      ProfessionalStatusBadgeTone.danger => scheme.errorContainer,
    };
    final foreground = switch (tone) {
      ProfessionalStatusBadgeTone.danger => scheme.onErrorContainer,
      _ => scheme.onSecondaryContainer,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
      ),
    );
  }
}

enum ProfessionalStatusBadgeTone { success, warning, info, danger }

/// Compact professional dashboard card — lightweight, secondary to customer profile.
class ProfessionalDashboardCardLayout extends StatelessWidget {
  const ProfessionalDashboardCardLayout({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.statusBadge,
    this.helper,
    this.actions = const [],
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? statusBadge;
  final Widget? helper;
  final List<Widget> actions;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Semantics(
      container: true,
      label: 'Professional dashboard',
      child: PraniPremiumCard(
        padding: const EdgeInsets.symmetric(
          horizontal: PraniSpacing.md,
          vertical: PraniSpacing.sm,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: scheme.primaryContainer.withValues(alpha: 0.7),
              ),
              child: Icon(icon, color: scheme.primary, size: 20),
            ),
            const SizedBox(width: PraniSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (statusBadge != null) ...[
                        const SizedBox(width: PraniSpacing.xs),
                        statusBadge!,
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontSize: 12,
                      height: 1.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (helper != null) ...[
                    const SizedBox(height: PraniSpacing.xs),
                    helper!,
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: PraniSpacing.xs),
              trailing!,
            ] else if (actions.isNotEmpty) ...[
              const SizedBox(width: PraniSpacing.xs),
              ...actions.map((a) => Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: a,
                  )),
            ],
          ],
        ),
      ),
    );
  }
}

/// Compact inline CTA button for professional dashboard tiles.
class CompactDashboardButton extends StatelessWidget {
  const CompactDashboardButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.filled = false,
    this.disabled = false,
  });

  final String label;
  final VoidCallback onPressed;
  final bool filled;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (filled) {
      return Material(
        color: disabled
            ? scheme.primary.withValues(alpha: 0.4)
            : scheme.primary,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: disabled ? null : onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text(
              label,
              style: textTheme.labelSmall?.copyWith(
                color: scheme.onPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ),
      );
    }

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: disabled ? null : onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            border: Border.all(
              color: disabled
                  ? scheme.outline.withValues(alpha: 0.4)
                  : scheme.outline,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: textTheme.labelSmall?.copyWith(
              color: disabled
                  ? scheme.onSurface.withValues(alpha: 0.5)
                  : scheme.primary,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}

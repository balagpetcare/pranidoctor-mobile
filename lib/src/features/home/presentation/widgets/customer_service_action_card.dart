import 'package:flutter/material.dart';

import '../../../../core/constants/pd_spacing.dart';
import '../../../../core/widgets/pd_app_card.dart';

/// Rounded service discovery tile (home visit, AI tech, etc.).
class CustomerServiceActionCard extends StatelessWidget {
  const CustomerServiceActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.trailingIcon = Icons.chevron_right_rounded,
    this.muted = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final IconData trailingIcon;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final effectiveOnTap = onTap;

    return PdAppCard(
      useShadow: false,
      onTap: effectiveOnTap,
      padding: const EdgeInsets.symmetric(
        horizontal: PdSpacing.md,
        vertical: PdSpacing.sm + 2,
      ),
      child: Row(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: muted
                  ? scheme.surfaceContainerHighest
                  : scheme.primaryContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Padding(
              padding: const EdgeInsets.all(PdSpacing.sm),
              child: Icon(
                icon,
                color: muted ? scheme.onSurfaceVariant : scheme.primary,
                size: 26,
              ),
            ),
          ),
          const SizedBox(width: PdSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: muted ? scheme.onSurfaceVariant : null,
                  ),
                ),
                const SizedBox(height: PdSpacing.xxs),
                Text(
                  subtitle,
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Icon(trailingIcon, color: scheme.outline),
        ],
      ),
    );
  }
}

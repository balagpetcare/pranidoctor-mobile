import 'package:flutter/material.dart';

import '../../../../core/constants/pd_spacing.dart';
import '../../../../core/widgets/pd_app_card.dart';

/// Compact shortcut row (আমার পশু, নলেজ হাব, …).
class CustomerShortcutCard extends StatelessWidget {
  const CustomerShortcutCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return PdAppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(
        horizontal: PdSpacing.md,
        vertical: PdSpacing.sm + 2,
      ),
      child: Row(
        children: [
          Icon(icon, color: scheme.primary, size: 26),
          const SizedBox(width: PdSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: scheme.outline),
        ],
      ),
    );
  }
}

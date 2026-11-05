import 'package:flutter/material.dart';

import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';

/// Compact card for static preparation / workflow guidance (BN copy).
class PreparationGuideCard extends StatelessWidget {
  const PreparationGuideCard({
    super.key,
    required this.title,
    required this.body,
    this.icon = Icons.menu_book_outlined,
    this.onFutureOffline,
  });

  final String title;
  final String body;
  final IconData icon;
  final VoidCallback? onFutureOffline;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return AnimatedContainer(
      duration: PraniDurations.short,
      curve: Curves.easeOutCubic,
      width: 220,
      padding: const EdgeInsets.all(PraniSpacing.xl),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(PraniRadius.lg),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: scheme.primary, size: 22),
          const SizedBox(height: PraniSpacing.sm),
          Text(
            title,
            style: PraniTextStyles.subheading(
              scheme,
              textTheme,
            ).copyWith(fontSize: 15),
          ),
          const SizedBox(height: PraniSpacing.xs),
          Text(
            body,
            style: PraniTextStyles.bodySmall(
              scheme,
              textTheme,
            ).copyWith(height: 1.38),
          ),
          if (onFutureOffline != null) ...[
            const SizedBox(height: PraniSpacing.md),
            TextButton(
              onPressed: onFutureOffline,
              child: const Text('অফলাইন ডাউনলোড (শীঘ্রই)'),
            ),
          ],
        ],
      ),
    );
  }
}

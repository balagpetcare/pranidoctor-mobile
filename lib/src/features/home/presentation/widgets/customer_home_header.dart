import 'package:flutter/material.dart';

import '../../../../core/constants/pd_spacing.dart';

/// Top greeting row: Bangla welcome copy, mock এলাকা chip, notification action.
class CustomerHomeHeader extends StatelessWidget {
  const CustomerHomeHeader({
    super.key,
    required this.onNotificationsTap,
    this.greetingTitle = 'হ্যালো!',
    this.greetingSubtitle = 'প্রাণির সেবায় আপনাকে স্বাগতম।',
    this.areaLabel = 'এলাকা: ঢাকা (উদাহরণ)',
  });

  final VoidCallback onNotificationsTap;
  final String greetingTitle;
  final String greetingSubtitle;
  final String areaLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greetingTitle,
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: PdSpacing.xxs),
              Text(
                greetingSubtitle,
                style: textTheme.bodyLarge?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: PdSpacing.sm),
              Wrap(
                spacing: PdSpacing.xs,
                runSpacing: PdSpacing.xs,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Icon(Icons.place_outlined, size: 18, color: scheme.primary),
                  Material(
                    color: scheme.primaryContainer.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: PdSpacing.sm,
                        vertical: PdSpacing.xxs + 2,
                      ),
                      child: Text(
                        areaLabel,
                        style: textTheme.labelMedium?.copyWith(
                          color: scheme.onPrimaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        IconButton.filledTonal(
          tooltip: 'নোটিফিকেশন',
          onPressed: onNotificationsTap,
          icon: const Icon(Icons.notifications_outlined),
        ),
      ],
    );
  }
}

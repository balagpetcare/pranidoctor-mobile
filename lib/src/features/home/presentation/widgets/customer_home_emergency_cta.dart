import 'package:flutter/material.dart';

import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';

/// Emergency call strip — [onCallPressed] uses tel: only when wired; else snackbar from parent.
class CustomerHomeEmergencyCta extends StatelessWidget {
  const CustomerHomeEmergencyCta({super.key, required this.onCallPressed});

  final VoidCallback onCallPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(PraniRadii.lg),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.5)),
        boxShadow: PraniShadows.cardLight,
      ),
      child: Padding(
        padding: const EdgeInsets.all(PraniSpacing.xl),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: PraniColors.accent.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(PraniRadii.md),
              ),
              child: Padding(
                padding: const EdgeInsets.all(PraniSpacing.sm),
                child: Icon(Icons.emergency_outlined, color: scheme.tertiary),
              ),
            ),
            const SizedBox(width: PraniSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'জরুরি প্রয়োজনে কল করুন',
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: PraniSpacing.xxs),
                  Text(
                    '২৪/৭ পেট/ফার্ম প্রাণী চিকিৎসা সহায়তা',
                    style: textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: PraniSpacing.sm),
            Flexible(
              fit: FlexFit.loose,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: PraniColors.accent,
                  foregroundColor: PraniColors.textDark,
                  padding: const EdgeInsets.symmetric(
                    horizontal: PraniSpacing.md,
                    vertical: PraniSpacing.sm,
                  ),
                ),
                onPressed: onCallPressed,
                child: const Text('কল করুন'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

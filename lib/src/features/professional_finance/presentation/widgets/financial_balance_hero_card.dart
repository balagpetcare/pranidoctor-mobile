import 'package:flutter/material.dart';

import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';

/// Hero strip: withdrawable + pending (enterprise wallet header).
class FinancialBalanceHeroCard extends StatelessWidget {
  const FinancialBalanceHeroCard({
    super.key,
    required this.withdrawableBdt,
    required this.pendingLabelBn,
    this.lifetimeBdt,
  });

  final String withdrawableBdt;
  final String pendingLabelBn;
  final String? lifetimeBdt;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: EdgeInsets.zero,
      color: scheme.primaryContainer.withValues(alpha: 0.55),
      child: Padding(
        padding: const EdgeInsets.all(PraniSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'নিষ্কাশনযোগ্য ব্যালেন্স',
              style: textTheme.labelLarge?.copyWith(
                color: scheme.onPrimaryContainer,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: PraniSpacing.xs),
            Text(
              withdrawableBdt == '—' ? '—' : '৳$withdrawableBdt',
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
                color: scheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: PraniSpacing.md),
            const Divider(height: 1),
            const SizedBox(height: PraniSpacing.md),
            Text(
              'অপেক্ষমাণ পেমেন্ট / নিষ্পত্তি',
              style: textTheme.labelMedium?.copyWith(
                color: scheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: PraniSpacing.xs),
            Text(
              pendingLabelBn,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: scheme.onPrimaryContainer,
              ),
            ),
            if (lifetimeBdt != null &&
                lifetimeBdt!.trim().isNotEmpty &&
                lifetimeBdt!.trim() != '—') ...[
              const SizedBox(height: PraniSpacing.sm),
              Text(
                'নিশ্চিত মোট আয় (লাইফটাইম): ৳${lifetimeBdt!.trim()}',
                style: textTheme.bodySmall?.copyWith(
                  color: scheme.onPrimaryContainer.withValues(alpha: 0.85),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';

/// Reusable KPI-style metric (earnings grid, wallet summaries).
class FinancialMetricCard extends StatelessWidget {
  const FinancialMetricCard({
    super.key,
    required this.labelBn,
    required this.valueBn,
    this.subtitleBn,
    this.icon = Icons.payments_outlined,
  });

  final String labelBn;
  final String valueBn;
  final String? subtitleBn;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(PraniSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: scheme.primary),
                const SizedBox(width: PraniSpacing.sm),
                Expanded(
                  child: Text(
                    labelBn,
                    style: textTheme.labelMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                    maxLines: 2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: PraniSpacing.sm),
            Text(
              _displayAmount(valueBn),
              style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            if (subtitleBn != null && subtitleBn!.trim().isNotEmpty) ...[
              const SizedBox(height: PraniSpacing.xs),
              Text(
                subtitleBn!,
                style: textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                  height: 1.35,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

String _displayAmount(String raw) {
  final t = raw.trim();
  if (t.isEmpty || t == '—') return '—';
  if (t.startsWith('৳')) return t;
  final looksDescriptive = RegExp(r'[A-Za-z\u0980-\u09FF]').hasMatch(t);
  if (looksDescriptive) return t;
  return '৳$t';
}

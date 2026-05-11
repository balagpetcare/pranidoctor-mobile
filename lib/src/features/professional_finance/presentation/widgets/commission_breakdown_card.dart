import 'package:flutter/material.dart';

import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';
import 'package:pranidoctor_mobile/src/features/professional_finance/domain/professional_finance_types.dart';

class CommissionBreakdownCard extends StatelessWidget {
  const CommissionBreakdownCard({super.key, required this.data});

  final CommissionBreakdown data;

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
            Text(
              'কমিশন ভাগ (প্রস্তুতি)',
              style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: PraniSpacing.sm),
            Text(
              data.policyLabelBn,
              style: textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: PraniSpacing.md),
            _row(context, 'মোট (গ্রস)', '৳${data.grossBdtRaw}'),
            _row(context, 'প্ল্যাটফর্ম ${data.platformFeePercent.toStringAsFixed(0)}%',
                '৳${data.platformFeeBdtRaw}'),
            _row(context, 'প্রদানযোগ্য নিট', '৳${data.providerNetBdtRaw}',
                emphasize: true),
          ],
        ),
      ),
    );
  }

  Widget _row(
    BuildContext context,
    String k,
    String v, {
    bool emphasize = false,
  }) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: PraniSpacing.sm),
      child: Row(
        children: [
          Expanded(child: Text(k, style: textTheme.bodyMedium)),
          Text(
            v,
            style: textTheme.bodyLarge?.copyWith(
              fontWeight: emphasize ? FontWeight.w900 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

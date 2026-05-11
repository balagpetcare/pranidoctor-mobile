import 'package:flutter/material.dart';

import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';
import 'package:pranidoctor_mobile/src/features/professional_finance/domain/professional_finance_types.dart';

class InvoiceReadinessCard extends StatelessWidget {
  const InvoiceReadinessCard({super.key, required this.outline});

  final InvoiceReadinessOutline outline;

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
              'ইনভয়েস ও নিষ্পত্তি (প্রস্তুতি)',
              style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: PraniSpacing.sm),
            Text(
              'নং ${outline.invoiceNumber} · ${outline.periodLabelBn}',
              style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: PraniSpacing.xs),
            Text(
              'মোট ৳${outline.totalBdtRaw} · ভ্যাট/ট্যাক্স ফিল্ড: '
              '${outline.taxReady ? "প্রস্তুত" : "অপেক্ষমাণ"}',
              style: textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: PraniSpacing.md),
            ...outline.linesBn.map(
              (l) => Padding(
                padding: const EdgeInsets.only(bottom: PraniSpacing.xs),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• '),
                    Expanded(child: Text(l, style: textTheme.bodySmall)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

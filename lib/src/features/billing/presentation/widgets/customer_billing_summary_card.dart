import 'package:flutter/material.dart';

import 'package:pranidoctor_mobile/src/features/billing/data/billing_payment_summary_model.dart';
import 'package:pranidoctor_mobile/src/features/billing/presentation/widgets/billing_money_format.dart';
import 'package:pranidoctor_mobile/src/features/billing/presentation/widgets/case_payment_status_section.dart';

/// Customer-facing receipt card — **never** shows commission / provider payout (even if present in model).
class CustomerBillingSummaryCard extends StatelessWidget {
  const CustomerBillingSummaryCard({
    super.key,
    required this.summary,
    required this.isEmpty,
    this.emptyMessage =
        'বিলিং তথ্য এখনও উপলব্ধ নয়। পরিচালক বা সাপোর্ট থেকে নিশ্চিত করা হলে এখানে দেখা যাবে।',
  });

  final BillingPaymentSummary? summary;
  final bool isEmpty;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (isEmpty || summary == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.receipt_long_outlined, color: scheme.primary),
                  const SizedBox(width: 10),
                  Text(
                    'বিলিং ও পেমেন্ট',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                emptyMessage,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final s = summary!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.receipt_long_outlined, color: scheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'রসিদ / বিলিং',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            CasePaymentStatusSection(
              title: 'পেমেন্টের অবস্থা',
              status: s.paymentStatus,
              subtitle: s.paymentMethod != BillingPaymentMethod.UNKNOWN
                  ? 'পেমেন্ট পদ্ধতি: ${s.paymentMethod.labelBn}'
                  : null,
            ),
            const SizedBox(height: 14),
            const Divider(height: 1),
            const SizedBox(height: 10),
            _BillingLineRow(
              label: 'সেবা ফি',
              value: formatTakaAmount(s.serviceFee),
            ),
            _BillingLineRow(
              label: 'যাতায়াত খরচ',
              value: formatTakaAmount(s.travelCost),
            ),
            _BillingLineRow(
              label: 'ঔষধ খরচ',
              value: formatTakaAmount(s.medicineCost),
            ),
            _BillingLineRow(
              label: 'ছাড়',
              value: s.discount != null && s.discount! > 0
                  ? '- ${formatTakaAmount(s.discount, showDashWhenNull: false)}'
                  : formatTakaAmount(s.discount),
            ),
            const SizedBox(height: 8),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    'মোট পরিশোধ',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  formatTakaAmount(s.totalCollected),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: scheme.primary,
                  ),
                ),
              ],
            ),
            if (s.notes?.trim().isNotEmpty == true) ...[
              const SizedBox(height: 14),
              Text(
                s.notes!,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _BillingLineRow extends StatelessWidget {
  const _BillingLineRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }
}

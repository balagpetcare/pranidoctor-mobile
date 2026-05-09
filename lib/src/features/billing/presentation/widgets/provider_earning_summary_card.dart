import 'package:flutter/material.dart';

import 'package:pranidoctor_mobile/src/features/billing/data/billing_payment_summary_model.dart';
import 'package:pranidoctor_mobile/src/features/billing/presentation/widgets/billing_money_format.dart';
import 'package:pranidoctor_mobile/src/features/billing/presentation/widgets/case_payment_status_section.dart';

/// Provider-only earning summary — not framed as a customer receipt.
class ProviderEarningSummaryCard extends StatelessWidget {
  const ProviderEarningSummaryCard({
    super.key,
    required this.summary,
    required this.isEmpty,
    this.footerNote,
    this.emptyMessage =
        'এই কেসের জন্য আয়ের বিস্তারিত এখনও পাওয়া যায়নি। API থেকে বিলিং যুক্ত হলে এখানে দেখা যাবে।',
  });

  final BillingPaymentSummary? summary;
  final bool isEmpty;
  final String? footerNote;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (isEmpty || summary == null) {
      return Card(
        color: scheme.surfaceContainerLow,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.payments_outlined, color: scheme.tertiary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'আয়ের সারাংশ',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'প্রদানকারী হিসাব — গ্রাহক রসিদ নয়',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 12),
              Text(
                emptyMessage,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              if (footerNote?.trim().isNotEmpty == true) ...[
                const SizedBox(height: 12),
                Text(
                  footerNote!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.account_balance_wallet_outlined,
                  color: scheme.tertiary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'আয়ের সারাংশ',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'প্রদানকারী হিসাব — গ্রাহক রসিদ নয়',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            CasePaymentStatusSection(
              title: 'পেমেন্টের অবস্থা ও পদ্ধতি',
              status: s.paymentStatus,
              subtitle: s.paymentMethod != BillingPaymentMethod.UNKNOWN
                  ? 'পেমেন্ট পদ্ধতি: ${s.paymentMethod.labelBn}'
                  : 'পেমেন্ট পদ্ধতি নির্ধারিত হয়নি',
              showBadge: true,
            ),
            const SizedBox(height: 14),
            const Divider(height: 1),
            const SizedBox(height: 10),
            _ProviderRow(
              label: 'মোট সংগৃহীত (কেস)',
              value: formatTakaAmount(s.totalCollected),
              strong: true,
            ),
            _ProviderRow(
              label: 'প্ল্যাটফর্ম কমিশন',
              value: formatTakaAmount(s.platformCommission),
            ),
            _ProviderRow(
              label: 'প্রদানকারী পেআউট',
              value: formatTakaAmount(s.providerPayout),
              emphasize: true,
            ),
            const SizedBox(height: 8),
            const Divider(height: 1),
            const SizedBox(height: 10),
            Text(
              'খরচের ভাগ (রেফারেন্স)',
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(color: scheme.primary),
            ),
            const SizedBox(height: 8),
            _ProviderRow(
              label: 'সেবা ফি',
              value: formatTakaAmount(s.serviceFee),
            ),
            _ProviderRow(
              label: 'যাতায়াত খরচ',
              value: formatTakaAmount(s.travelCost),
            ),
            _ProviderRow(
              label: 'ঔষধ খরচ',
              value: formatTakaAmount(s.medicineCost),
            ),
            _ProviderRow(label: 'ছাড়', value: formatTakaAmount(s.discount)),
            if (footerNote?.trim().isNotEmpty == true) ...[
              const SizedBox(height: 12),
              Text(
                footerNote!,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ],
            if (s.notes?.trim().isNotEmpty == true) ...[
              const SizedBox(height: 8),
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

class _ProviderRow extends StatelessWidget {
  const _ProviderRow({
    required this.label,
    required this.value,
    this.emphasize = false,
    this.strong = false,
  });

  final String label;
  final String value;
  final bool emphasize;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final style = emphasize
        ? Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: scheme.primary,
          )
        : strong
        ? Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700)
        : Theme.of(context).textTheme.bodyLarge;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(value, textAlign: TextAlign.end, style: style),
          ),
        ],
      ),
    );
  }
}

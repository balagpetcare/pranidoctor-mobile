import 'package:flutter/material.dart';

import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';
import 'package:pranidoctor_mobile/src/features/billing/data/billing_payment_summary_model.dart';
import 'package:pranidoctor_mobile/src/features/billing/presentation/widgets/payment_status_badge.dart';
import 'package:pranidoctor_mobile/src/features/professional_finance/domain/professional_finance_types.dart';

class WalletTransactionTile extends StatelessWidget {
  const WalletTransactionTile({super.key, required this.row});

  final WalletTransactionRecord row;

  static String _formatDt(DateTime t) {
    final d = t.toLocal();
    return '${d.day}/${d.month}/${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final sign = row.direction == WalletLedgerDirection.credit ? '+' : '−';
    final amt = row.amountBdtRaw.trim();

    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: PraniSpacing.md,
          vertical: PraniSpacing.xs,
        ),
        title: Text(row.titleBn, maxLines: 2, overflow: TextOverflow.ellipsis),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _formatDt(row.occurredAt),
              style: textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            if (row.commissionNoteBn != null)
              Text(
                row.commissionNoteBn!,
                style: textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                  height: 1.35,
                ),
              ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '$sign৳$amt',
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: row.direction == WalletLedgerDirection.credit
                    ? scheme.primary
                    : scheme.error,
              ),
            ),
            if (row.paymentStatus != BillingPaymentStatus.UNKNOWN)
              PaymentStatusBadge(status: row.paymentStatus, compact: true),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import 'package:pranidoctor_mobile/src/features/professional_finance/domain/professional_finance_types.dart';

class WithdrawalRequestTile extends StatelessWidget {
  const WithdrawalRequestTile({super.key, required this.row});

  final WithdrawalRequestRecord row;

  static String _formatDt(DateTime t) {
    final d = t.toLocal();
    return '${d.day}/${d.month}/${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        title: Text(
          '৳${row.amountBdtRaw.trim()}',
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        subtitle: Text(
          [
            row.status.labelBn,
            _formatDt(row.requestedAt),
            if (row.bankLast4 != null) 'ব্যাংক **${row.bankLast4}',
          ].join(' · '),
          style: textTheme.bodySmall?.copyWith(
            color: scheme.onSurfaceVariant,
            height: 1.35,
          ),
        ),
        trailing: Icon(
          Icons.account_balance_outlined,
          color: scheme.primary,
        ),
      ),
    );
  }
}

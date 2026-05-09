import 'package:flutter/material.dart';

import 'package:pranidoctor_mobile/src/features/billing/data/billing_payment_summary_model.dart';
import 'package:pranidoctor_mobile/src/features/billing/presentation/widgets/payment_status_badge.dart';

/// Header strip: title + optional Bengali helper line + status badge.
class CasePaymentStatusSection extends StatelessWidget {
  const CasePaymentStatusSection({
    super.key,
    required this.title,
    required this.status,
    this.subtitle,
    this.showBadge = true,
  });

  final String title;
  final BillingPaymentStatus status;
  final String? subtitle;
  final bool showBadge;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      color: scheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          subtitle!,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                      ],
                    ],
                  ),
                ),
                if (showBadge) PaymentStatusBadge(status: status),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

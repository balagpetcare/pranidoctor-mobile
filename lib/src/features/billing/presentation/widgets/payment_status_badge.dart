import 'package:flutter/material.dart';

import 'package:pranidoctor_mobile/src/features/billing/data/billing_payment_summary_model.dart';

/// Compact Bengali payment status chip (Material 3).
class PaymentStatusBadge extends StatelessWidget {
  const PaymentStatusBadge({
    super.key,
    required this.status,
    this.compact = false,
  });

  final BillingPaymentStatus status;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (bg, fg, icon) = _style(context, scheme);

    return Chip(
      avatar: Icon(icon, size: compact ? 16 : 18, color: fg),
      label: Text(
        status.labelBn,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
      side: BorderSide(color: scheme.outlineVariant),
      backgroundColor: bg,
      padding: EdgeInsets.zero,
      visualDensity: compact ? VisualDensity.compact : VisualDensity.standard,
    );
  }

  (Color bg, Color fg, IconData icon) _style(
    BuildContext context,
    ColorScheme scheme,
  ) {
    return switch (status) {
      BillingPaymentStatus.PAID => (
        scheme.primaryContainer,
        scheme.onPrimaryContainer,
        Icons.check_circle_outline,
      ),
      BillingPaymentStatus.PENDING ||
      BillingPaymentStatus.DUE ||
      BillingPaymentStatus.PARTIAL => (
        scheme.secondaryContainer,
        scheme.onSecondaryContainer,
        Icons.schedule_outlined,
      ),
      BillingPaymentStatus.REFUNDED || BillingPaymentStatus.WAIVED => (
        scheme.surfaceContainerHighest,
        scheme.onSurfaceVariant,
        Icons.replay_outlined,
      ),
      BillingPaymentStatus.CANCELLED => (
        scheme.errorContainer,
        scheme.onErrorContainer,
        Icons.cancel_outlined,
      ),
      BillingPaymentStatus.UNKNOWN => (
        scheme.surfaceContainerLow,
        scheme.onSurfaceVariant,
        Icons.help_outline,
      ),
    };
  }
}

import 'package:pranidoctor_mobile/src/features/billing/data/billing_payment_summary_model.dart';

/// High-level ledger direction for provider wallet UI.
enum WalletLedgerDirection {
  credit,
  debit;

  String get labelBn => switch (this) {
        WalletLedgerDirection.credit => 'জমা',
        WalletLedgerDirection.debit => 'খরচ / কর্তন',
      };
}

/// One wallet / settlement line (maps cleanly to future `GET …/wallet/transactions`).
class WalletTransactionRecord {
  const WalletTransactionRecord({
    required this.id,
    required this.occurredAt,
    required this.titleBn,
    required this.amountBdtRaw,
    required this.direction,
    this.paymentStatus = BillingPaymentStatus.UNKNOWN,
    this.commissionNoteBn,
    this.relatedServiceLabelBn,
  });

  final String id;
  final DateTime occurredAt;
  final String titleBn;

  /// Numeric string from API (e.g. `"1200.00"`); UI adds ৳ and sign.
  final String amountBdtRaw;
  final WalletLedgerDirection direction;
  final BillingPaymentStatus paymentStatus;
  final String? commissionNoteBn;
  final String? relatedServiceLabelBn;
}

enum WithdrawalRequestStatus {
  pending,
  underReview,
  approved,
  paid,
  rejected;

  String get labelBn => switch (this) {
        WithdrawalRequestStatus.pending => 'জমা হয়েছে',
        WithdrawalRequestStatus.underReview => 'যাচাই চলছে',
        WithdrawalRequestStatus.approved => 'অনুমোদিত',
        WithdrawalRequestStatus.paid => 'পরিশোধিত',
        WithdrawalRequestStatus.rejected => 'প্রত্যাখ্যাত',
      };
}

/// Future `POST /wallet/withdrawals` row shape.
class WithdrawalRequestRecord {
  const WithdrawalRequestRecord({
    required this.id,
    required this.amountBdtRaw,
    required this.status,
    required this.requestedAt,
    this.bankLast4,
    this.rejectionReasonBn,
  });

  final String id;
  final String amountBdtRaw;
  final WithdrawalRequestStatus status;
  final DateTime requestedAt;
  final String? bankLast4;
  final String? rejectionReasonBn;
}

/// Commission split — wire to pricing engine / admin rules when backend ships.
class CommissionBreakdown {
  const CommissionBreakdown({
    required this.grossBdtRaw,
    required this.platformFeePercent,
    required this.platformFeeBdtRaw,
    required this.providerNetBdtRaw,
    this.policyLabelBn =
        'প্ল্যাটফর্ম কমিশন — নীতি সার্ভার থেকে লোড হবে',
  });

  final String grossBdtRaw;
  final double platformFeePercent;
  final String platformFeeBdtRaw;
  final String providerNetBdtRaw;
  final String policyLabelBn;
}

/// Invoice / settlement document preview (PDF/URL generation stays server-side).
class InvoiceReadinessOutline {
  const InvoiceReadinessOutline({
    required this.invoiceNumber,
    required this.periodLabelBn,
    required this.totalBdtRaw,
    required this.taxReady,
    required this.linesBn,
  });

  final String invoiceNumber;
  final String periodLabelBn;
  final String totalBdtRaw;
  final bool taxReady;
  final List<String> linesBn;
}

/// Aggregated earnings headline for the professional dashboard tab.
class ProfessionalEarningsSnapshot {
  const ProfessionalEarningsSnapshot({
    required this.dailyEarningsBdt,
    required this.weeklyEarningsBdt,
    required this.monthlyEarningsBdt,
    required this.pendingPaymentsBdt,
    required this.withdrawableBalanceBdt,
    this.confirmedLifetimeBdt,
    this.dataQualityNoteBn,
  });

  final String dailyEarningsBdt;
  final String weeklyEarningsBdt;
  final String monthlyEarningsBdt;
  final String pendingPaymentsBdt;
  final String withdrawableBalanceBdt;
  final String? confirmedLifetimeBdt;
  final String? dataQualityNoteBn;

  factory ProfessionalEarningsSnapshot.unauthenticatedPlaceholder() {
    return const ProfessionalEarningsSnapshot(
      dailyEarningsBdt: '—',
      weeklyEarningsBdt: '—',
      monthlyEarningsBdt: '—',
      pendingPaymentsBdt: '—',
      withdrawableBalanceBdt: '—',
      dataQualityNoteBn: 'লগইন প্রয়োজন',
    );
  }
}

import 'package:pranidoctor_mobile/src/features/billing/data/billing_payment_summary_model.dart';
import 'package:pranidoctor_mobile/src/features/professional_finance/domain/professional_finance_types.dart';

/// In-memory demo ledger until `GET /api/mobile/wallet/transactions` exists.
class StubWalletRepository {
  const StubWalletRepository();

  List<WalletTransactionRecord> listTransactions() {
    final now = DateTime.now();
    return [
      WalletTransactionRecord(
        id: 'tx_demo_1',
        occurredAt: now.subtract(const Duration(days: 1)),
        titleBn: 'সেবা পেমেন্ট — কৃত্রিম প্রজনন',
        amountBdtRaw: '3200',
        direction: WalletLedgerDirection.credit,
        paymentStatus: BillingPaymentStatus.PAID,
        commissionNoteBn: 'প্ল্যাটফর্ম ফি ১২% কর্তন',
      ),
      WalletTransactionRecord(
        id: 'tx_demo_2',
        occurredAt: now.subtract(const Duration(days: 3)),
        titleBn: 'প্ল্যাটফর্ম কমিশন',
        amountBdtRaw: '384',
        direction: WalletLedgerDirection.debit,
        paymentStatus: BillingPaymentStatus.PAID,
      ),
      WalletTransactionRecord(
        id: 'tx_demo_3',
        occurredAt: now.subtract(const Duration(days: 5)),
        titleBn: 'খামার পরিদর্শন — ডাক্তার',
        amountBdtRaw: '1500',
        direction: WalletLedgerDirection.credit,
        paymentStatus: BillingPaymentStatus.PENDING,
      ),
    ];
  }

  List<WithdrawalRequestRecord> listWithdrawalRequests() {
    final now = DateTime.now();
    return [
      WithdrawalRequestRecord(
        id: 'wd_demo_1',
        amountBdtRaw: '5000',
        status: WithdrawalRequestStatus.paid,
        requestedAt: now.subtract(const Duration(days: 14)),
        bankLast4: '4521',
      ),
      WithdrawalRequestRecord(
        id: 'wd_demo_2',
        amountBdtRaw: '8000',
        status: WithdrawalRequestStatus.underReview,
        requestedAt: now.subtract(const Duration(days: 2)),
        bankLast4: '4521',
      ),
    ];
  }
}

/// Submit withdrawal requests — replace stub with signed API client.
abstract class WithdrawalRequestPort {
  Future<void> submitWithdrawal({
    required String amountBdtRaw,
    String? noteBn,
  });
}

class StubWithdrawalRequestPort implements WithdrawalRequestPort {
  const StubWithdrawalRequestPort();

  @override
  Future<void> submitWithdrawal({
    required String amountBdtRaw,
    String? noteBn,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final v = double.tryParse(amountBdtRaw.replaceAll(',', '').trim());
    if (v == null || v <= 0) {
      throw ArgumentError('invalid_amount');
    }
  }
}

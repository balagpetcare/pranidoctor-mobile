import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pranidoctor_mobile/src/features/ai_technician_application/application/ai_technician_providers.dart';
import 'package:pranidoctor_mobile/src/features/profile/application/profile_dashboard_providers.dart';
import 'package:pranidoctor_mobile/src/features/professional_finance/application/professional_finance_mappers.dart';
import 'package:pranidoctor_mobile/src/features/professional_finance/application/withdrawal_request_port.dart';
import 'package:pranidoctor_mobile/src/features/professional_finance/data/stub_wallet_repository.dart';
import 'package:pranidoctor_mobile/src/features/professional_finance/domain/professional_finance_types.dart';
import 'package:pranidoctor_mobile/src/features/session/application/session_notifier.dart';

final stubWalletRepositoryProvider = Provider<StubWalletRepository>(
  (_) => const StubWalletRepository(),
);

final withdrawalRequestPortProvider = Provider<WithdrawalRequestPort>(
  (_) => const StubWithdrawalRequestPort(),
);

final professionalWalletTransactionsProvider =
    FutureProvider.autoDispose<List<WalletTransactionRecord>>((ref) async {
  return ref.watch(stubWalletRepositoryProvider).listTransactions();
});

final professionalWithdrawalRequestsProvider =
    FutureProvider.autoDispose<List<WithdrawalRequestRecord>>((ref) async {
  return ref.watch(stubWalletRepositoryProvider).listWithdrawalRequests();
});

/// Earnings headline — technician uses AI dashboard; doctor uses profile dashboard.
final professionalEarningsSnapshotProvider =
    Provider.autoDispose<AsyncValue<ProfessionalEarningsSnapshot>>((ref) {
  final role = ref.watch(sessionNotifierProvider).role;
  if (role == AppRole.aiTechnician) {
    return ref.watch(aiTechnicianDashboardProvider).when(
          data: (d) => AsyncData(mapTechnicianDashboardToSnapshot(d)),
          loading: () => const AsyncLoading(),
          error: (e, st) => AsyncValue.error(e, st),
        );
  }
  if (role == AppRole.doctor) {
    return ref.watch(profileDashboardContextProvider).when(
          data: (ctx) => AsyncData(mapDoctorContextToSnapshot(ctx)),
          loading: () => const AsyncLoading(),
          error: (e, st) => AsyncValue.error(e, st),
        );
  }
  return AsyncData(ProfessionalEarningsSnapshot.unauthenticatedPlaceholder());
});

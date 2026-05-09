import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pranidoctor_mobile/src/core/network/api_client.dart';
import 'package:pranidoctor_mobile/src/features/doctor_workflow/data/doctor_case_models.dart';
import 'package:pranidoctor_mobile/src/features/doctor_workflow/data/doctor_workflow_repository.dart';

final doctorWorkflowRepositoryProvider = Provider<DoctorWorkflowRepository>((
  ref,
) {
  return DoctorWorkflowRepository(ref.watch(apiClientProvider));
});

final doctorIncomingRequestsProvider =
    AsyncNotifierProvider<
      DoctorIncomingRequestsNotifier,
      List<DoctorIncomingRequest>
    >(DoctorIncomingRequestsNotifier.new);

class DoctorIncomingRequestsNotifier
    extends AsyncNotifier<List<DoctorIncomingRequest>> {
  Future<void> refresh() async {
    state = await AsyncValue.guard(_load);
  }

  @override
  Future<List<DoctorIncomingRequest>> build() async => _load();

  Future<List<DoctorIncomingRequest>> _load() async {
    final repo = ref.read(doctorWorkflowRepositoryProvider);
    return repo.listIncomingRequests();
  }
}

final doctorCasesListProvider =
    AsyncNotifierProvider<DoctorCasesListNotifier, List<DoctorCaseListItem>>(
      DoctorCasesListNotifier.new,
    );

class DoctorCasesListNotifier extends AsyncNotifier<List<DoctorCaseListItem>> {
  Future<void> refresh() async {
    state = await AsyncValue.guard(_load);
  }

  @override
  Future<List<DoctorCaseListItem>> build() async => _load();

  Future<List<DoctorCaseListItem>> _load() async {
    final repo = ref.read(doctorWorkflowRepositoryProvider);
    return repo.listCases(activeOnly: true);
  }
}

final doctorCaseDetailProvider = FutureProvider.autoDispose
    .family<DoctorCaseDetail, String>((ref, caseId) async {
      final repo = ref.watch(doctorWorkflowRepositoryProvider);
      return repo.getCaseById(caseId);
    });

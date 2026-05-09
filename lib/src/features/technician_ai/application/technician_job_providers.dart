import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pranidoctor_mobile/src/core/config/app_config.dart';
import 'package:pranidoctor_mobile/src/core/network/api_client.dart';
import 'package:pranidoctor_mobile/src/features/technician_ai/data/technician_job_models.dart';
import 'package:pranidoctor_mobile/src/features/technician_ai/data/technician_job_repository.dart';
import 'package:pranidoctor_mobile/src/features/technician_ai/data/technician_job_repository_mock.dart';

final technicianJobRepositoryProvider = Provider<TechnicianJobRepository>((
  ref,
) {
  if (AppConfig.useMockTechnicianApi) {
    return TechnicianJobRepositoryMock();
  }
  return TechnicianJobRepositoryLive(ref.watch(apiClientProvider));
});

final technicianRequestsListProvider =
    AsyncNotifierProvider<
      TechnicianRequestsListNotifier,
      List<TechnicianIncomingRequest>
    >(TechnicianRequestsListNotifier.new);

class TechnicianRequestsListNotifier
    extends AsyncNotifier<List<TechnicianIncomingRequest>> {
  Future<void> refresh() async {
    state = await AsyncValue.guard(_load);
  }

  @override
  Future<List<TechnicianIncomingRequest>> build() async => _load();

  Future<List<TechnicianIncomingRequest>> _load() async {
    final repo = ref.read(technicianJobRepositoryProvider);
    final page = await repo.listRequests(limit: 50);
    return page.requests;
  }
}

final technicianJobsListProvider =
    AsyncNotifierProvider<
      TechnicianJobsListNotifier,
      List<TechnicianJobSummary>
    >(TechnicianJobsListNotifier.new);

class TechnicianJobsListNotifier
    extends AsyncNotifier<List<TechnicianJobSummary>> {
  Future<void> refresh() async {
    state = await AsyncValue.guard(_load);
  }

  @override
  Future<List<TechnicianJobSummary>> build() async => _load();

  Future<List<TechnicianJobSummary>> _load() async {
    final repo = ref.read(technicianJobRepositoryProvider);
    final page = await repo.listJobs(limit: 50);
    return page.jobs;
  }
}

final technicianJobDetailProvider = FutureProvider.autoDispose
    .family<TechnicianJobDetail, String>((ref, id) async {
      final repo = ref.watch(technicianJobRepositoryProvider);
      return repo.getJob(id);
    });

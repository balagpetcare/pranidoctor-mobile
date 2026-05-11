import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pranidoctor_mobile/src/core/network/api_client.dart';
import 'package:pranidoctor_mobile/src/features/ai_farmer_services/data/ai_farmer_services_models.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/application/ai_technician_request_pipeline_counts.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/data/ai_technician_models.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/data/ai_technician_repository.dart';

final aiTechnicianRepositoryProvider = Provider<AiTechnicianRepository>((ref) {
  return AiTechnicianRepository(ref.watch(apiClientProvider));
});

/// Latest `GET /api/mobile/ai-technician/me` for the logged-in customer.
final aiTechnicianMeProvider = FutureProvider.autoDispose<AiTechnicianMeResult>(
  (ref) {
    return ref.read(aiTechnicianRepositoryProvider).fetchMe();
  },
);

final aiTechnicianDashboardProvider =
    FutureProvider.autoDispose<AiTechnicianDashboardData>((ref) {
      return ref.read(aiTechnicianRepositoryProvider).fetchDashboard();
    });

/// Per-tab pipeline counts from existing paginated list API (see TODO on model).
///
/// TODO(backend): Ship authoritative counts on dashboard to replace these calls.
final aiTechnicianRequestPipelineCountsProvider =
    FutureProvider.autoDispose<Map<String, AiTechnicianRequestPipelineCount>>((
      ref,
    ) async {
      final repo = ref.read(aiTechnicianRepositoryProvider);
      const tabs = <String>[
        'new',
        'accepted',
        'ongoing',
        'completed',
        'cancelled',
      ];
      Future<MapEntry<String, AiTechnicianRequestPipelineCount>> load(
        String tab,
      ) async {
        try {
          final r = await repo.listTechnicianJobRequests(
            tab: tab,
            limit: 200,
            offset: 0,
          );
          return MapEntry(
            tab,
            AiTechnicianRequestPipelineCount(
              count: r.items.length,
              truncated: r.truncated,
            ),
          );
        } catch (_) {
          return MapEntry(tab, AiTechnicianRequestPipelineCount.unavailable());
        }
      }

      final entries = await Future.wait(tabs.map(load));
      return Map<String, AiTechnicianRequestPipelineCount>.fromEntries(entries);
    });

final aiTechnicianServicesListProvider =
    FutureProvider.autoDispose<List<AiTechnicianServiceRow>>((ref) {
      return ref.read(aiTechnicianRepositoryProvider).listServices();
    });

final aiTechnicianJobRequestsForTabProvider = FutureProvider.autoDispose
    .family<
      ({
        List<AiFarmerServiceRequestRow> items,
        int limit,
        int offset,
        bool truncated,
      }),
      String
    >((ref, tab) {
      return ref
          .read(aiTechnicianRepositoryProvider)
          .listTechnicianJobRequests(tab: tab);
    });

void invalidateAiTechnicianJobRequestLists(WidgetRef ref) {
  for (final tab in <String>[
    'new',
    'accepted',
    'ongoing',
    'completed',
    'cancelled',
  ]) {
    ref.invalidate(aiTechnicianJobRequestsForTabProvider(tab));
  }
  ref.invalidate(aiTechnicianRequestPipelineCountsProvider);
}

final aiTechnicianJobRequestDetailProvider = FutureProvider.autoDispose
    .family<AiFarmerServiceRequestRow, String>((ref, id) {
      return ref
          .read(aiTechnicianRepositoryProvider)
          .getTechnicianJobRequest(id);
    });

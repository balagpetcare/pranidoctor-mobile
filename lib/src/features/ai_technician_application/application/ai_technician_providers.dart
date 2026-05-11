import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
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
  (ref) async {
    final cancel = CancelToken();
    ref.onDispose(() {
      if (!cancel.isCancelled) {
        cancel.cancel('Provider disposed');
      }
    });
    if (kDebugMode) {
      debugPrint('aiTechnicianMeProvider: loading');
    }
    try {
      final me = await ref
          .read(aiTechnicianRepositoryProvider)
          .fetchMe(cancelToken: cancel);
      if (kDebugMode) {
        debugPrint(
          'aiTechnicianMeProvider: success profile=${me.profile != null}',
        );
      }
      return me;
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('aiTechnicianMeProvider: error $e\n$st');
      }
      rethrow;
    }
  },
);

final aiTechnicianDashboardProvider =
    FutureProvider.autoDispose<AiTechnicianDashboardData>((ref) async {
      final cancel = CancelToken();
      ref.onDispose(() {
        if (!cancel.isCancelled) {
          cancel.cancel('Provider disposed');
        }
      });
      if (kDebugMode) {
        debugPrint('aiTechnicianDashboardProvider: loading');
      }
      try {
        final data = await ref
            .read(aiTechnicianRepositoryProvider)
            .fetchDashboard(cancelToken: cancel);
        if (kDebugMode) {
          debugPrint(
            'aiTechnicianDashboardProvider: success '
            'profile=${data.profile != null}',
          );
        }
        return data;
      } catch (e, st) {
        if (kDebugMode) {
          debugPrint('aiTechnicianDashboardProvider: error $e\n$st');
        }
        rethrow;
      }
    });

/// Per-tab pipeline counts from existing paginated list API (see TODO on model).
///
/// TODO(backend): Ship authoritative counts on dashboard to replace these calls.
final aiTechnicianRequestPipelineCountsProvider =
    FutureProvider.autoDispose<Map<String, AiTechnicianRequestPipelineCount>>((
      ref,
    ) async {
      final cancel = CancelToken();
      ref.onDispose(() {
        if (!cancel.isCancelled) {
          cancel.cancel('Provider disposed');
        }
      });
      if (kDebugMode) {
        debugPrint('aiTechnicianRequestPipelineCountsProvider: loading');
      }
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
            cancelToken: cancel,
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
      final out = Map<String, AiTechnicianRequestPipelineCount>.fromEntries(
        entries,
      );
      if (kDebugMode) {
        debugPrint(
          'aiTechnicianRequestPipelineCountsProvider: success tabs=${out.length}',
        );
      }
      return out;
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

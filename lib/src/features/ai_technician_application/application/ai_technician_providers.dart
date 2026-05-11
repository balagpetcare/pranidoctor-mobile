import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pranidoctor_mobile/src/core/network/api_client.dart';
import 'package:pranidoctor_mobile/src/features/ai_farmer_services/data/ai_farmer_services_models.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/application/ai_technician_request_pipeline_counts.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/data/ai_technician_api_exception.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/data/ai_technician_models.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/data/ai_technician_repository.dart';

final aiTechnicianRepositoryProvider = Provider<AiTechnicianRepository>((ref) {
  return AiTechnicianRepository(ref.watch(apiClientProvider));
});

/// Latest `GET /api/mobile/ai-technician/me` for the logged-in customer.
///
/// No [CancelToken]: cancelling on autoDispose caused spurious
/// [AiTechnicianApiException] `(CANCELLED)` during navigation and duplicate
/// invalidations (Profile prefetch + entry resolver).
final aiTechnicianMeProvider = FutureProvider.autoDispose<AiTechnicianMeResult>(
  (ref) async {
    if (kDebugMode) {
      debugPrint('aiTechnicianMeProvider: loading');
    }
    try {
      final me = await ref.read(aiTechnicianRepositoryProvider).fetchMe();
      if (kDebugMode) {
        debugPrint(
          'aiTechnicianMeProvider: success profile=${me.profile != null}',
        );
      }
      return me;
    } catch (e, st) {
      if (kDebugMode) {
        if (isCancelledAiTechnicianError(e)) {
          debugPrint('aiTechnicianMeProvider: cancelled (non-fatal) $e');
        } else {
          debugPrint('aiTechnicianMeProvider: error $e\n$st');
        }
      }
      rethrow;
    }
  },
);

final aiTechnicianDashboardProvider =
    FutureProvider.autoDispose<AiTechnicianDashboardData>((ref) async {
      Future<AiTechnicianDashboardData> fetchOnce() async {
        return ref.read(aiTechnicianRepositoryProvider).fetchDashboard();
      }

      if (kDebugMode) {
        debugPrint('aiTechnicianDashboardProvider: loading');
      }
      try {
        final data = await fetchOnce();
        if (kDebugMode) {
          debugPrint(
            'aiTechnicianDashboardProvider: success '
            'profile=${data.profile != null}',
          );
        }
        return data;
      } catch (e, st) {
        if (isCancelledAiTechnicianError(e)) {
          if (kDebugMode) {
            debugPrint(
              'aiTechnicianDashboardProvider: cancelled — retry once after settle',
            );
          }
          await Future<void>.delayed(const Duration(milliseconds: 80));
          try {
            final retry = await fetchOnce();
            if (kDebugMode) {
              debugPrint(
                'aiTechnicianDashboardProvider: retry ok '
                'profile=${retry.profile != null}',
              );
            }
            return retry;
          } catch (e2, st2) {
            if (kDebugMode) {
              if (isCancelledAiTechnicianError(e2)) {
                debugPrint(
                  'aiTechnicianDashboardProvider: cancelled again (non-fatal) $e2',
                );
              } else {
                debugPrint(
                  'aiTechnicianDashboardProvider: retry error $e2\n$st2',
                );
              }
            }
            rethrow;
          }
        }
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

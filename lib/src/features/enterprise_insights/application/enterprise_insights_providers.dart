import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pranidoctor_mobile/src/core/network/api_client.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/application/ai_technician_providers.dart';
import 'package:pranidoctor_mobile/src/features/enterprise_insights/application/enterprise_analytics_mappers.dart';
import 'package:pranidoctor_mobile/src/features/enterprise_insights/application/offline_sync_monitoring_ports.dart';
import 'package:pranidoctor_mobile/src/features/enterprise_insights/application/sync_action_executor_port.dart';
import 'package:pranidoctor_mobile/src/features/enterprise_insights/application/connectivity_port.dart';
import 'package:pranidoctor_mobile/src/features/enterprise_insights/application/enterprise_sync_tick.dart';
import 'package:pranidoctor_mobile/src/features/enterprise_insights/data/api_sync_action_executor.dart';
import 'package:pranidoctor_mobile/src/features/enterprise_insights/data/enterprise_insights_json_cache.dart';
import 'package:pranidoctor_mobile/src/features/enterprise_insights/data/enterprise_audit_activity_store.dart';
import 'package:pranidoctor_mobile/src/features/enterprise_insights/data/persistent_sync_coordinator.dart';
import 'package:pranidoctor_mobile/src/features/enterprise_insights/data/professional_sync_outbox.dart';
import 'package:pranidoctor_mobile/src/features/enterprise_insights/data/sync_outbox_store.dart';
import 'package:pranidoctor_mobile/src/features/enterprise_insights/domain/enterprise_audit_activity.dart';
import 'package:pranidoctor_mobile/src/features/enterprise_insights/domain/professional_analytics_snapshot.dart';
import 'package:pranidoctor_mobile/src/features/enterprise_insights/domain/sync_outbox_snapshot.dart';
import 'package:pranidoctor_mobile/src/features/profile/application/profile_dashboard_providers.dart';
import 'package:pranidoctor_mobile/src/features/session/application/session_notifier.dart';

export 'package:pranidoctor_mobile/src/features/enterprise_insights/application/enterprise_sync_tick.dart';

/// Injectable cache — swap for encrypted / Drift-backed implementation later.
final offlineJsonCachePortProvider = Provider<OfflineJsonCachePort>((ref) {
  return SharedPreferencesOfflineJsonCache();
});

final syncOutboxStoreProvider = Provider<SyncOutboxStore>((ref) {
  return SyncOutboxStore();
});

final connectivityPortProvider = Provider<ConnectivityPort>((ref) {
  return ConnectivityPlusPort();
});

final syncActionExecutorProvider = Provider<SyncActionExecutorPort>((ref) {
  return ApiSyncActionExecutor(ref.watch(apiClientProvider));
});

final Provider<PersistentSyncCoordinator> persistentSyncCoordinatorProvider =
    Provider<PersistentSyncCoordinator>((ref) {
  final coordinator = PersistentSyncCoordinator(
    store: ref.watch(syncOutboxStoreProvider),
    connectivity: ref.watch(connectivityPortProvider),
    executor: ref.watch(syncActionExecutorProvider),
    monitoring: ref.watch(monitoringPortProvider),
    getRole: () => ref.read(sessionNotifierProvider).role,
    onOutboxChanged: () {
      ref.read(enterpriseSyncTickProvider.notifier).bump();
    },
  );
  ref.onDispose(coordinator.dispose);
  Future.microtask(() => coordinator.init());
  return coordinator;
});

final syncCoordinatorPortProvider = Provider<SyncCoordinatorPort>((ref) {
  return ref.watch(persistentSyncCoordinatorProvider);
});

/// Typed enqueue helpers for repositories (profile, booking, media metadata, …).
final professionalSyncOutboxProvider = Provider<ProfessionalSyncOutbox>((ref) {
  return ProfessionalSyncOutbox(ref.watch(syncCoordinatorPortProvider));
});

final monitoringPortProvider = Provider<MonitoringPort>((ref) {
  return const NoOpMonitoringPort();
});

/// Chart + headline data derived from existing dashboard providers (select-friendly).
final professionalAnalyticsSnapshotProvider =
    Provider.autoDispose<AsyncValue<ProfessionalAnalyticsSnapshot>>((ref) {
  final session = ref.watch(sessionNotifierProvider);
  if (!session.isAuthenticated) {
    return const AsyncValue.data(ProfessionalAnalyticsSnapshot.empty);
  }
  final role = session.role;
  if (role == AppRole.aiTechnician) {
    return ref.watch(aiTechnicianDashboardProvider).when(
          data: (d) => AsyncValue.data(mapTechnicianAnalytics(d)),
          loading: () => const AsyncValue.loading(),
          error: (e, st) => AsyncValue.error(e, st),
        );
  }
  if (role == AppRole.doctor) {
    return ref.watch(profileDashboardContextProvider).when(
          data: (c) => AsyncValue.data(mapDoctorDashboardAnalytics(c)),
          loading: () => const AsyncValue.loading(),
          error: (e, st) => AsyncValue.error(e, st),
        );
  }
  return const AsyncValue.data(ProfessionalAnalyticsSnapshot.empty);
});

final enterpriseAuditListProvider =
    FutureProvider.autoDispose<List<EnterpriseAuditEntry>>((ref) async {
  final role = ref.watch(sessionNotifierProvider).role;
  if (role == null) return const [];
  return loadEnterpriseAudit(role);
});

final enterpriseActivityListProvider =
    FutureProvider.autoDispose<List<EnterpriseActivityEntry>>((ref) async {
  final role = ref.watch(sessionNotifierProvider).role;
  if (role == null) return const [];
  return loadEnterpriseActivity(role);
});

/// Full outbox snapshot (queues + connectivity + UI status).
final FutureProvider<SyncOutboxSnapshot> enterpriseSyncSnapshotProvider =
    FutureProvider.autoDispose<SyncOutboxSnapshot>((ref) async {
  ref.watch(enterpriseSyncTickProvider);
  final c = ref.read(persistentSyncCoordinatorProvider);
  return c.getOutboxSnapshot();
});

/// Back-compat: pending + retry rows only.
final Provider<int> enterpriseSyncPendingCountProvider =
    Provider.autoDispose<int>((ref) {
  final async = ref.watch(enterpriseSyncSnapshotProvider);
  return async.when(
    data: (s) => s.workQueueCount,
    loading: () => 0,
    error: (_, _) => 0,
  );
});

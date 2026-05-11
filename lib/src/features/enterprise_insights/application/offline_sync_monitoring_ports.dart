import 'package:pranidoctor_mobile/src/features/enterprise_insights/domain/sync_outbox_snapshot.dart';

/// Typed JSON blob cache for offline-first reads (Drift/sqflite can wrap this later).
abstract class OfflineJsonCachePort {
  Future<String?> get(String namespace, String key);
  Future<void> put(String namespace, String key, String json);
  Future<void> remove(String namespace, String key);
}

/// Outbox for mutations when offline — flush when transport resumes.
abstract class SyncCoordinatorPort {
  Future<void> enqueue({
    required String resource,
    required String operation,
    required String payloadJson,
  });

  /// Items waiting to sync (pending + scheduled retry).
  Future<int> pendingCount();

  /// Full queue snapshot for enterprise UI and diagnostics.
  Future<SyncOutboxSnapshot> getOutboxSnapshot();

  /// Process pending items while online (idempotent; serialized internally).
  Future<void> requestFlush();
}

/// Sentry/Datadog-style hooks (no SDK in repo yet).
abstract class MonitoringPort {
  void breadcrumb(String name, {Map<String, String>? data});
  void captureException(Object error, StackTrace? stackTrace);
}

class NoOpMonitoringPort implements MonitoringPort {
  const NoOpMonitoringPort();

  @override
  void breadcrumb(String name, {Map<String, String>? data}) {}

  @override
  void captureException(Object error, StackTrace? stackTrace) {}
}

class NoOpSyncCoordinatorPort implements SyncCoordinatorPort {
  const NoOpSyncCoordinatorPort();

  @override
  Future<void> enqueue({
    required String resource,
    required String operation,
    required String payloadJson,
  }) async {}

  @override
  Future<int> pendingCount() async => 0;

  @override
  Future<SyncOutboxSnapshot> getOutboxSnapshot() async =>
      SyncOutboxSnapshot.empty();

  @override
  Future<void> requestFlush() async {}
}

/// Optional hook for OS background tasks / WorkManager — call [requestFlush] on a
/// fresh [ProviderContainer] bound to the same storage (see docs).
abstract class SyncBackgroundFlushPort {
  /// Safe to invoke from a short-lived background isolate callback **after**
  /// re-hydrating auth + [ProviderScope]; otherwise prefer main isolate.
  Future<void> requestBackgroundFlush();
}

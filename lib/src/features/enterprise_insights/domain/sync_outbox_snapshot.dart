import 'package:meta/meta.dart';

import 'package:pranidoctor_mobile/src/features/enterprise_insights/domain/sync_outbox_action.dart';

/// Aggregate UX state for status chips and banners.
enum EnterpriseSyncDisplayStatus {
  offline,
  synced,
  pending,
  syncing,
  failed,
}

@immutable
class SyncOutboxSnapshot {
  const SyncOutboxSnapshot({
    required this.isOnline,
    required this.isFlushing,
    required this.pendingQueueCount,
    required this.retryQueueCount,
    required this.failedQueueCount,
    required this.syncedArchiveCount,
    required this.displayStatus,
    required this.activePreview,
    this.lastGlobalError,
  });

  final bool isOnline;
  final bool isFlushing;
  final int pendingQueueCount;
  final int retryQueueCount;
  final int failedQueueCount;
  final int syncedArchiveCount;
  final EnterpriseSyncDisplayStatus displayStatus;
  final List<SyncOutboxAction> activePreview;
  final String? lastGlobalError;

  int get workQueueCount => pendingQueueCount + retryQueueCount;

  static SyncOutboxSnapshot empty() => const SyncOutboxSnapshot(
        isOnline: true,
        isFlushing: false,
        pendingQueueCount: 0,
        retryQueueCount: 0,
        failedQueueCount: 0,
        syncedArchiveCount: 0,
        displayStatus: EnterpriseSyncDisplayStatus.synced,
        activePreview: [],
      );

  static EnterpriseSyncDisplayStatus computeDisplay({
    required bool isOnline,
    required bool isFlushing,
    required int pending,
    required int retry,
    required int failed,
  }) {
    if (isFlushing) return EnterpriseSyncDisplayStatus.syncing;
    if (!isOnline) return EnterpriseSyncDisplayStatus.offline;
    if (pending + retry > 0) return EnterpriseSyncDisplayStatus.pending;
    if (failed > 0) return EnterpriseSyncDisplayStatus.failed;
    return EnterpriseSyncDisplayStatus.synced;
  }
}

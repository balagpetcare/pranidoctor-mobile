import 'dart:async';
import 'dart:math';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:pranidoctor_mobile/src/features/enterprise_insights/application/connectivity_port.dart';
import 'package:pranidoctor_mobile/src/features/enterprise_insights/application/offline_sync_monitoring_ports.dart';
import 'package:pranidoctor_mobile/src/features/enterprise_insights/application/sync_action_executor_port.dart';
import 'package:pranidoctor_mobile/src/features/enterprise_insights/application/sync_backoff.dart';
import 'package:pranidoctor_mobile/src/features/enterprise_insights/data/enterprise_audit_activity_store.dart';
import 'package:pranidoctor_mobile/src/features/enterprise_insights/data/sync_outbox_store.dart';
import 'package:pranidoctor_mobile/src/features/enterprise_insights/domain/sync_outbox_action.dart';
import 'package:pranidoctor_mobile/src/features/enterprise_insights/domain/sync_outbox_snapshot.dart';
import 'package:pranidoctor_mobile/src/features/session/application/session_notifier.dart';

/// Persistent outbox + retry engine (main isolate). Background workers should
/// post back to this coordinator rather than touching [SharedPreferences] directly.
class PersistentSyncCoordinator
    implements SyncCoordinatorPort, SyncBackgroundFlushPort {
  PersistentSyncCoordinator({
    required SyncOutboxStore store,
    required ConnectivityPort connectivity,
    required SyncActionExecutorPort executor,
    required MonitoringPort monitoring,
    required AppRole? Function() getRole,
    required void Function() onOutboxChanged,
  })  : _store = store,
        _connectivity = connectivity,
        _executor = executor,
        _monitoring = monitoring,
        _getRole = getRole,
        _onOutboxChanged = onOutboxChanged;

  final SyncOutboxStore _store;
  final ConnectivityPort _connectivity;
  final SyncActionExecutorPort _executor;
  final MonitoringPort _monitoring;
  final AppRole? Function() _getRole;
  final void Function() _onOutboxChanged;

  final Random _rand = Random.secure();
  Future<void> _mutex = Future<void>.value();
  var _flushRunning = false;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;

  Future<void> init() async {
    await _connectivitySub?.cancel();
    _connectivitySub = _connectivity.onConnectivityChanged.listen((_) {
      _monitoring.breadcrumb('sync.connectivity_tick');
      _onOutboxChanged();
      unawaited(requestFlush());
    });
  }

  void dispose() {
    unawaited(_connectivitySub?.cancel());
    _connectivitySub = null;
  }

  @override
  Future<void> requestBackgroundFlush() => requestFlush();

  Future<T> _withLock<T>(Future<T> Function() fn) {
    final completer = Completer<T>();
    _mutex = _mutex.then((_) async {
      try {
        completer.complete(await fn());
      } catch (e, st) {
        completer.completeError(e, st);
        _monitoring.captureException(e, st);
      }
    });
    return completer.future;
  }

  Future<void> _audit(String actionKey, String summaryBn) async {
    final role = _getRole();
    if (role == null) return;
    await recordEnterpriseAuditPreview(
      role: role,
      actionKey: actionKey,
      summaryBn: summaryBn,
    );
  }

  bool _eligible(SyncOutboxAction a, DateTime nowUtc) {
    switch (a.status) {
      case SyncActionStatus.pending:
        return true;
      case SyncActionStatus.retryScheduled:
        final n = a.nextAttemptAtUtc;
        return n == null || !n.isAfter(nowUtc);
      default:
        return false;
    }
  }

  @override
  Future<void> enqueue({
    required String resource,
    required String operation,
    required String payloadJson,
  }) {
    return _withLock(() async {
      var rows = await _store.loadActive();
      rows = await _store.resetStuckSyncing(rows);
      final type = inferSyncActionType(resource, operation);
      final now = DateTime.now().toUtc();
      final id =
          '${now.millisecondsSinceEpoch}_${_rand.nextInt(1 << 30)}';
      rows.add(
        SyncOutboxAction(
          id: id,
          type: type,
          resource: resource,
          operation: operation,
          payloadJson: payloadJson,
          createdAtUtc: now,
          retryCount: 0,
          status: SyncActionStatus.pending,
          lastError: null,
          nextAttemptAtUtc: null,
          updatedAtUtc: now,
        ),
      );
      await _store.saveActive(rows);
      _monitoring.breadcrumb(
        'sync.enqueue',
        data: {'id': id, 'type': type.name},
      );
      await _audit(
        'sync.enqueue',
        '${type.name}: $resource.$operation',
      );
      _onOutboxChanged();
      if (await _connectivity.isConnected) {
        unawaited(requestFlush());
      }
    });
  }

  @override
  Future<int> pendingCount() async {
    final snap = await getOutboxSnapshot();
    return snap.workQueueCount;
  }

  @override
  Future<SyncOutboxSnapshot> getOutboxSnapshot() {
    return _withLock(() async {
      var active = await _store.loadActive();
      active = await _store.resetStuckSyncing(active);
      final archive = await _store.loadSyncedArchive();
      final online = await _connectivity.isConnected;
      final pending =
          active.where((a) => a.status == SyncActionStatus.pending).length;
      final retry = active
          .where((a) => a.status == SyncActionStatus.retryScheduled)
          .length;
      final failed =
          active.where((a) => a.status == SyncActionStatus.failed).length;
      final sorted = List<SyncOutboxAction>.from(active)
        ..sort((a, b) => a.createdAtUtc.compareTo(b.createdAtUtc));
      final preview = sorted.length > 12 ? sorted.sublist(0, 12) : sorted;
      String? lastErr;
      for (final a in active.reversed) {
        if (a.lastError != null && a.lastError!.isNotEmpty) {
          lastErr = a.lastError;
          break;
        }
      }
      return SyncOutboxSnapshot(
        isOnline: online,
        isFlushing: _flushRunning,
        pendingQueueCount: pending,
        retryQueueCount: retry,
        failedQueueCount: failed,
        syncedArchiveCount: archive.length,
        displayStatus: SyncOutboxSnapshot.computeDisplay(
          isOnline: online,
          isFlushing: _flushRunning,
          pending: pending,
          retry: retry,
          failed: failed,
        ),
        activePreview: preview,
        lastGlobalError: lastErr,
      );
    });
  }

  @override
  Future<void> requestFlush() {
    return _withLock(() async {
      if (_flushRunning) return;
      if (!await _connectivity.isConnected) {
        _onOutboxChanged();
        return;
      }
      _flushRunning = true;
      _onOutboxChanged();
      await _audit('sync.flush.start', 'আউটবক্স ফ্লাশ শুরু');
      try {
        while (true) {
          if (!await _connectivity.isConnected) break;

          var active = await _store.loadActive();
          active = await _store.resetStuckSyncing(active);
          final now = DateTime.now().toUtc();

          SyncOutboxAction? pick;
          for (final a in active) {
            if (_eligible(a, now)) {
              pick = a;
              break;
            }
          }
          if (pick == null) break;

          final idx = active.indexWhere((e) => e.id == pick!.id);
          if (idx < 0) continue;
          var current = active[idx];

          final syncStart = DateTime.now().toUtc();
          current = current.copyWith(
            status: SyncActionStatus.syncing,
            updatedAtUtc: syncStart,
          );
          active[idx] = current;
          await _store.saveActive(active);
          _onOutboxChanged();

          SyncExecutionResult result;
          try {
            result = await _executor.execute(current);
          } catch (e, st) {
            _monitoring.captureException(e, st);
            result = SyncExecutionResult.retryLater('$e');
          }

          final after = DateTime.now().toUtc();
          active = await _store.loadActive();
          final idx2 = active.indexWhere((e) => e.id == current.id);
          if (idx2 < 0) {
            continue;
          }

          if (result.success) {
            final done = current.copyWith(
              status: SyncActionStatus.synced,
              updatedAtUtc: after,
              clearLastError: true,
              clearNextAttempt: true,
            );
            active.removeAt(idx2);
            await _store.saveActive(active);
            final arc = await _store.loadSyncedArchive();
            arc.add(done);
            await _store.saveSyncedArchive(arc);
            await _audit(
              'sync.item.success',
              'সিঙ্ক সম্পন্ন · ${current.type.name} · ${current.id}',
            );
          } else if (result.retryable) {
            final attemptsAfter = current.retryCount + 1;
            if (attemptsAfter > SyncBackoff.maxRetries) {
              active[idx2] = current.copyWith(
                status: SyncActionStatus.failed,
                retryCount: attemptsAfter,
                lastError: result.message ?? 'max_retries',
                updatedAtUtc: after,
                clearNextAttempt: true,
              );
              await _store.saveActive(active);
              await _audit(
                'sync.item.failed',
                'সর্বোচ্চ পুনঃচেষ্টা · ${current.type.name}',
              );
            } else {
              final nextAt = SyncBackoff.nextAttemptAfter(
                nowUtc: after,
                zeroBasedRetryCount: current.retryCount,
              );
              active[idx2] = current.copyWith(
                status: SyncActionStatus.retryScheduled,
                retryCount: attemptsAfter,
                lastError: result.message,
                nextAttemptAtUtc: nextAt,
                updatedAtUtc: after,
              );
              await _store.saveActive(active);
              await _audit(
                'sync.item.retry',
                'পুনঃচেষ্টা #$attemptsAfter · ${current.type.name}',
              );
            }
          } else {
            active[idx2] = current.copyWith(
              status: SyncActionStatus.failed,
              lastError: result.message ?? 'terminal',
              updatedAtUtc: after,
              clearNextAttempt: true,
            );
            await _store.saveActive(active);
            await _audit(
              'sync.item.failed',
              'স্থায়ী ব্যর্থ · ${current.type.name}: ${result.message ?? ''}',
            );
          }
        }
      } finally {
        _flushRunning = false;
        await _audit('sync.flush.complete', 'আউটবক্স ফ্লাশ শেষ');
        _onOutboxChanged();
      }
    });
  }
}

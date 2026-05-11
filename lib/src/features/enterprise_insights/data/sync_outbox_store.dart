import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:pranidoctor_mobile/src/features/enterprise_insights/domain/sync_outbox_action.dart';

const _kActive = 'pd_enterprise_sync_outbox_active_v1';
const _kSynced = 'pd_enterprise_sync_outbox_synced_archive_v1';
const int _maxActive = 400;
const int _maxSyncedArchive = 120;

class SyncOutboxStore {
  Future<List<SyncOutboxAction>> loadActive() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kActive);
    if (raw == null || raw.trim().isEmpty) return const [];
    try {
      final list = jsonDecode(raw);
      if (list is! List) return const [];
      return list
          .map(
            (e) => SyncOutboxAction.fromJson(
              Map<String, Object?>.from(e as Map),
            ),
          )
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> saveActive(List<SyncOutboxAction> rows) async {
    final prefs = await SharedPreferences.getInstance();
    var next = rows;
    if (next.length > _maxActive) {
      next = next.sublist(next.length - _maxActive);
    }
    await prefs.setString(
      _kActive,
      jsonEncode(next.map((e) => e.toJson()).toList()),
    );
  }

  Future<List<SyncOutboxAction>> loadSyncedArchive() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kSynced);
    if (raw == null || raw.trim().isEmpty) return const [];
    try {
      final list = jsonDecode(raw);
      if (list is! List) return const [];
      return list
          .map(
            (e) => SyncOutboxAction.fromJson(
              Map<String, Object?>.from(e as Map),
            ),
          )
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> saveSyncedArchive(List<SyncOutboxAction> rows) async {
    final prefs = await SharedPreferences.getInstance();
    final capped =
        rows.length > _maxSyncedArchive ? rows.sublist(rows.length - _maxSyncedArchive) : rows;
    await prefs.setString(
      _kSynced,
      jsonEncode(capped.map((e) => e.toJson()).toList()),
    );
  }

  /// Recover from a crash mid-flush.
  Future<List<SyncOutboxAction>> resetStuckSyncing(List<SyncOutboxAction> rows) async {
    final now = DateTime.now().toUtc();
    final fixed = rows.map((a) {
      if (a.status != SyncActionStatus.syncing) return a;
      return a.copyWith(
        status: SyncActionStatus.retryScheduled,
        nextAttemptAtUtc: now,
        updatedAtUtc: now,
        lastError: 'recovered_from_stuck_syncing',
      );
    }).toList();
    await saveActive(fixed);
    return fixed;
  }
}

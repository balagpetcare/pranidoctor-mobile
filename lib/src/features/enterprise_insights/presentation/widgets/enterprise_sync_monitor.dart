import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';
import 'package:pranidoctor_mobile/src/features/enterprise_insights/application/enterprise_insights_providers.dart';
import 'package:pranidoctor_mobile/src/features/enterprise_insights/domain/sync_outbox_snapshot.dart';

/// Compact status row for professional shells and insights hub.
class EnterpriseSyncMonitor extends StatelessWidget {
  const EnterpriseSyncMonitor({super.key, required this.snapshot});

  final SyncOutboxSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final label = switch (snapshot.displayStatus) {
      EnterpriseSyncDisplayStatus.offline => 'অফলাইন',
      EnterpriseSyncDisplayStatus.synced => 'সিঙ্কড',
      EnterpriseSyncDisplayStatus.pending => 'অপেক্ষমাণ',
      EnterpriseSyncDisplayStatus.syncing => 'সিঙ্ক হচ্ছে',
      EnterpriseSyncDisplayStatus.failed => 'ব্যর্থ',
    };
    final color = switch (snapshot.displayStatus) {
      EnterpriseSyncDisplayStatus.offline => scheme.outline,
      EnterpriseSyncDisplayStatus.synced => scheme.primary,
      EnterpriseSyncDisplayStatus.pending => scheme.tertiary,
      EnterpriseSyncDisplayStatus.syncing => scheme.secondary,
      EnterpriseSyncDisplayStatus.failed => scheme.error,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: PraniSpacing.xs,
          runSpacing: PraniSpacing.xs,
          children: [
            _Chip(
              icon: Icons.cloud_done_outlined,
              label: label,
              color: color,
            ),
            _Chip(
              icon: Icons.hourglass_empty_rounded,
              label: 'পেন্ডিং ${snapshot.pendingQueueCount}',
              color: scheme.onSurfaceVariant,
            ),
            _Chip(
              icon: Icons.replay_rounded,
              label: 'রিট্রাই ${snapshot.retryQueueCount}',
              color: scheme.onSurfaceVariant,
            ),
            _Chip(
              icon: Icons.error_outline_rounded,
              label: 'ফেইল্ড ${snapshot.failedQueueCount}',
              color: snapshot.failedQueueCount > 0
                  ? scheme.error
                  : scheme.onSurfaceVariant,
            ),
            _Chip(
              icon: Icons.history_rounded,
              label: 'সিঙ্কড আর্কাইভ ${snapshot.syncedArchiveCount}',
              color: scheme.onSurfaceVariant,
            ),
          ],
        ),
        if (snapshot.lastGlobalError != null &&
            snapshot.lastGlobalError!.isNotEmpty) ...[
          SizedBox(height: PraniSpacing.xs),
          Text(
            'সর্বশেষ ত্রুটি: ${snapshot.lastGlobalError}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: scheme.error,
                ),
          ),
        ],
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 18, color: color),
      label: Text(label),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}

/// Triggers [requestFlush] when the app returns to foreground (main isolate).
class EnterpriseSyncLifecycleWatcher extends ConsumerStatefulWidget {
  const EnterpriseSyncLifecycleWatcher({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<EnterpriseSyncLifecycleWatcher> createState() =>
      _EnterpriseSyncLifecycleWatcherState();
}

class _EnterpriseSyncLifecycleWatcherState
    extends ConsumerState<EnterpriseSyncLifecycleWatcher>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final sync = ref.read(syncCoordinatorPortProvider);
      unawaited(sync.requestFlush());
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

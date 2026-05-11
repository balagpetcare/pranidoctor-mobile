import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Version counter for outbox UI — incremented by [PersistentSyncCoordinator].
final class EnterpriseSyncTickNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void bump() => state++;
}

final enterpriseSyncTickProvider =
    NotifierProvider<EnterpriseSyncTickNotifier, int>(
  EnterpriseSyncTickNotifier.new,
);

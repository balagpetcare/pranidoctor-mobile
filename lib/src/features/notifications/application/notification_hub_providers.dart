import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pranidoctor_mobile/src/features/notifications/application/notification_ports.dart';
import 'package:pranidoctor_mobile/src/features/notifications/application/notifications_providers.dart';
import 'package:pranidoctor_mobile/src/features/notifications/data/notification_preferences_store.dart';
import 'package:pranidoctor_mobile/src/features/notifications/domain/notification_category.dart';

final notificationPreferencesStoreProvider =
    Provider<NotificationPreferencesStore>(
  (_) => NotificationPreferencesStore(),
);

final notificationPreferencesProvider =
    AsyncNotifierProvider<NotificationPreferencesNotifier,
        NotificationPreferencesState>(
  NotificationPreferencesNotifier.new,
);

class NotificationPreferencesNotifier
    extends AsyncNotifier<NotificationPreferencesState> {
  @override
  Future<NotificationPreferencesState> build() async {
    final store = ref.read(notificationPreferencesStoreProvider);
    return store.load();
  }

  Future<void> setCategory(NotificationCategory c, bool enabled) async {
    final prev = state.asData?.value ?? NotificationPreferencesState.allOn();
    state = AsyncData(prev.copyWithCategory(c, enabled));
    await ref.read(notificationPreferencesStoreProvider).setEnabled(c, enabled);
  }
}

final realtimeNotificationPortProvider = Provider<RealtimeNotificationPort>(
  (_) => const NoOpRealtimeNotificationPort(),
);

final pushNotificationRegistrationPortProvider =
    Provider<PushNotificationRegistrationPort>(
  (_) => const StubPushNotificationRegistrationPort(),
);

final localNotificationDisplayPortProvider =
    Provider<LocalNotificationDisplayPort>(
  (_) => const NoOpLocalNotificationDisplayPort(),
);

/// Keeps inbox in sync when a socket/Firebase implementation emits events.
final notificationRealtimeInboxSyncProvider = Provider<void>((ref) {
  final port = ref.watch(realtimeNotificationPortProvider);
  final sub = port.events().listen((_) {
    ref.invalidate(notificationsListProvider);
    ref.invalidate(unreadNotificationsTotalProvider);
  });
  ref.onDispose(sub.cancel);
});

final notificationCenterCategoryFilterProvider =
    NotifierProvider<NotificationCategoryFilterNotifier, NotificationCategory?>(
  NotificationCategoryFilterNotifier.new,
);

class NotificationCategoryFilterNotifier extends Notifier<NotificationCategory?> {
  @override
  NotificationCategory? build() => null;

  void select(NotificationCategory? c) => state = c;
}

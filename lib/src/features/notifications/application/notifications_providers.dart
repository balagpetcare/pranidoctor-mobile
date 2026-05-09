import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pranidoctor_mobile/src/core/network/api_client.dart';
import 'package:pranidoctor_mobile/src/features/notifications/data/notification_repository.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository(ref.watch(apiClientProvider));
});

/// Total unread count from list API (`unreadOnly: true`, minimal page size).
final unreadNotificationsTotalProvider = FutureProvider<int>((ref) async {
  final repo = ref.watch(notificationRepositoryProvider);
  final page = await repo.list(limit: 1, offset: 0, unreadOnly: true);
  return page.total;
});

final notificationsListProvider =
    AsyncNotifierProvider<NotificationsListNotifier, NotificationsPageData>(
      NotificationsListNotifier.new,
    );

class NotificationsListNotifier extends AsyncNotifier<NotificationsPageData> {
  bool _unreadOnly = false;

  bool get unreadOnly => _unreadOnly;

  void setUnreadOnly(bool value) {
    if (_unreadOnly == value) return;
    _unreadOnly = value;
    refresh();
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(() => _load());
    ref.invalidate(unreadNotificationsTotalProvider);
  }

  @override
  Future<NotificationsPageData> build() async {
    final data = await _load();
    ref.invalidate(unreadNotificationsTotalProvider);
    return data;
  }

  Future<NotificationsPageData> _load() async {
    final repo = ref.read(notificationRepositoryProvider);
    return repo.list(limit: 50, offset: 0, unreadOnly: _unreadOnly);
  }

  Future<void> markRead(String id) async {
    final repo = ref.read(notificationRepositoryProvider);
    await repo.markRead(id);
    await refresh();
  }

  Future<void> markAllRead() async {
    final repo = ref.read(notificationRepositoryProvider);
    await repo.markAllRead();
    await refresh();
  }
}

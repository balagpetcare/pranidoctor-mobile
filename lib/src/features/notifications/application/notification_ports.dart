import 'dart:async';

/// Normalized realtime payload (WebSocket / Firebase → same shape).
class NotificationRealtimeEvent {
  const NotificationRealtimeEvent({
    required this.eventId,
    this.titleBn,
    this.bodyBn,
    this.data = const {},
  });

  final String eventId;
  final String? titleBn;
  final String? bodyBn;
  final Map<String, dynamic> data;
}

/// WebSocket / SSE / Firebase `onMessage` — swap implementation at app bootstrap.
abstract class RealtimeNotificationPort {
  Stream<NotificationRealtimeEvent> events();
  Future<void> connect();
  Future<void> disconnect();
}

class NoOpRealtimeNotificationPort implements RealtimeNotificationPort {
  const NoOpRealtimeNotificationPort();

  @override
  Future<void> connect() async {}

  @override
  Future<void> disconnect() async {}

  @override
  Stream<NotificationRealtimeEvent> events() => const Stream.empty();
}

/// FCM token + topic subscription — call from login success.
abstract class PushNotificationRegistrationPort {
  Future<String?> getDeviceToken();
  Future<void> subscribeTopic(String topic);
  Future<void> unsubscribeTopic(String topic);
}

class StubPushNotificationRegistrationPort
    implements PushNotificationRegistrationPort {
  const StubPushNotificationRegistrationPort();

  @override
  Future<String?> getDeviceToken() async => null;

  @override
  Future<void> subscribeTopic(String topic) async {}

  @override
  Future<void> unsubscribeTopic(String topic) async {}
}

/// OS-level heads-up (schedule / foreground) — add `flutter_local_notifications` impl later.
abstract class LocalNotificationDisplayPort {
  Future<void> showNow({
    required int id,
    required String titleBn,
    required String bodyBn,
    String? channelId,
  });
}

class NoOpLocalNotificationDisplayPort implements LocalNotificationDisplayPort {
  const NoOpLocalNotificationDisplayPort();

  @override
  Future<void> showNow({
    required int id,
    required String titleBn,
    required String bodyBn,
    String? channelId,
  }) async {}
}

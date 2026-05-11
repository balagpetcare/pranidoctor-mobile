import 'package:pranidoctor_mobile/src/features/notifications/domain/notification_category.dart';

/// Topic names for FCM / backend subscription (keep aligned with server).
abstract final class NotificationPushTopic {
  static String forCategory(NotificationCategory c) => 'prani_${c.topicSuffix}';
}

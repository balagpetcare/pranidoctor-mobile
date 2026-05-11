import 'package:pranidoctor_mobile/src/features/notifications/data/notification_model.dart';
import 'package:pranidoctor_mobile/src/features/notifications/domain/notification_category.dart';
import 'package:pranidoctor_mobile/src/features/notifications/presentation/widgets/notification_type_labels.dart';

extension AppNotificationCategoryX on AppNotification {
  NotificationCategory get notificationCategory =>
      notificationCategoryForPayload(type: type, metadata: metadata);
}

/// Maps API `type` and optional `metadata` keys to [NotificationCategory].
NotificationCategory notificationCategoryForPayload({
  required String type,
  Map<String, dynamic>? metadata,
}) {
  final key = notificationTypeKey(type);
  final meta = metadata ?? const <String, dynamic>{};
  final metaEvent = '${meta['event'] ?? meta['eventId'] ?? ''}'.toLowerCase();
  final blob = '$key $metaEvent';

  if (blob.contains('emergency')) {
    return NotificationCategory.emergency;
  }
  if (blob.contains('verification') ||
      metaEvent.startsWith('verification.') ||
      key.contains('verification')) {
    return NotificationCategory.verification;
  }
  if (blob.contains('earning') ||
      blob.contains('payout') ||
      blob.contains('wallet') ||
      key == 'payment_billing_update') {
    return NotificationCategory.earnings;
  }
  if (blob.contains('appointment') ||
      blob.contains('schedule') ||
      key.contains('follow_up') ||
      key.contains('reminder')) {
    return NotificationCategory.appointment;
  }
  if (metaEvent.startsWith('livestock_booking.') ||
      key.contains('request') ||
      key.contains('doctor_accepted') ||
      key.contains('technician_accepted') ||
      key.contains('completed') ||
      key.contains('submitted')) {
    return NotificationCategory.booking;
  }
  return NotificationCategory.general;
}

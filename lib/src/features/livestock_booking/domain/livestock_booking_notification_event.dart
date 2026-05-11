/// Stable event ids for FCM / in-app notification routing (booking domain).
abstract final class LivestockBookingNotificationEvent {
  static const requestCreated = 'livestock_booking.request_created';
  static const assigned = 'livestock_booking.assigned';
  static const accepted = 'livestock_booking.accepted';
  static const onTheWay = 'livestock_booking.on_the_way';
  static const inService = 'livestock_booking.in_service';
  static const completed = 'livestock_booking.completed';
  static const cancelled = 'livestock_booking.cancelled';
  static const noteAdded = 'livestock_booking.note_added';
  static const attachmentAdded = 'livestock_booking.attachment_added';
}

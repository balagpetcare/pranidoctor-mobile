/// Canonical livestock service booking phases (customer journey + ops).
///
/// Maps from [ServiceRequestStatus] and timestamps via
/// [livestockBookingPhaseFor] in `service_request_booking_mapper.dart`.
enum LivestockBookingPhase {
  requestCreated,
  assigned,
  accepted,
  onTheWay,
  inService,
  completed,
  cancelled;

  String get labelBn => switch (this) {
        LivestockBookingPhase.requestCreated => 'অনুরোধ তৈরি',
        LivestockBookingPhase.assigned => 'নিয়োগ হয়েছে',
        LivestockBookingPhase.accepted => 'গ্রহণ হয়েছে',
        LivestockBookingPhase.onTheWay => 'পথে',
        LivestockBookingPhase.inService => 'সেবা চলছে',
        LivestockBookingPhase.completed => 'সম্পন্ন',
        LivestockBookingPhase.cancelled => 'বাতিল',
      };

  /// Display order for progress UI (0-based).
  int get stepIndex => LivestockBookingPhase.values.indexOf(this);
}

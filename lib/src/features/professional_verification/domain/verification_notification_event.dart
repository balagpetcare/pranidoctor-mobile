/// Stable event ids for push/in-app notification wiring (COMMAND 6).
///
/// Backend can mirror these strings in webhooks or FCM `data.type`.
abstract final class VerificationNotificationEvent {
  static const phaseChanged = 'verification.phase_changed';
  static const submitted = 'verification.submitted';
  static const underReview = 'verification.under_review';
  static const verified = 'verification.verified';
  static const rejected = 'verification.rejected';
  static const suspended = 'verification.suspended';
  static const resubmissionUnlocked = 'verification.resubmission_unlocked';
  static const documentReviewUpdated = 'verification.document_review_updated';
}

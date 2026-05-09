/// Customer-facing urgency for booking UI & persisted copy (API has no top-level
/// urgency field — merged into [description] on submit).
enum BookingUrgency {
  normal,
  urgent,
  emergency;

  String get labelBn {
    return switch (this) {
      BookingUrgency.normal => 'সাধারণ',
      BookingUrgency.urgent => 'দ্রুত',
      BookingUrgency.emergency => 'জরুরি',
    };
  }

  static BookingUrgency? tryParse(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      return BookingUrgency.values.byName(raw);
    } catch (_) {
      return null;
    }
  }
}

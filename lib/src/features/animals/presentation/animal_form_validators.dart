/// Pure validation helpers for animal create/edit forms (Bengali messages).
abstract final class AnimalFormValidators {
  static const int notesMaxChars = 8000;
  static const double weightKgMax = 99999;
  static const int ageYearsMax = 80;

  /// At least one of [name] or [tag] must be non-empty (trimmed).
  static String? nameOrTagRequired(String name, String tag) {
    if (name.trim().isEmpty && tag.trim().isEmpty) {
      return 'নাম অথবা ট্যাগ অন্তত একটি দিন';
    }
    return null;
  }

  static String? notesLength(String? notes) {
    if (notes == null) return null;
    if (notes.length > notesMaxChars) {
      return 'নোট সর্বোচ্চ $notesMaxChars অক্ষর';
    }
    return null;
  }

  /// Empty [raw] is valid (optional field). Otherwise must parse to (0, weightKgMax].
  static String? weightKgOptional(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final normalized = raw.trim().replaceAll(',', '.');
    final v = double.tryParse(normalized);
    if (v == null || v <= 0 || v > weightKgMax) {
      return 'সঠিক ওজন (কেজি) দিন (০.০১–${weightKgMax.toStringAsFixed(0)})';
    }
    return null;
  }

  static String? ageYearsOptional(String raw, {required bool useBirthDate}) {
    if (useBirthDate) return null;
    final t = raw.trim();
    if (t.isEmpty) return null;
    final y = int.tryParse(t);
    if (y == null || y < 0 || y > ageYearsMax) {
      return 'বয়স সঠিক সংখ্যায় লিখুন (০–$ageYearsMax)';
    }
    return null;
  }

  static String? photoUrlOptional(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final uri = Uri.tryParse(raw.trim());
    if (uri == null || !uri.hasScheme || !uri.scheme.startsWith('http')) {
      return 'ছবির লিঙ্ক http/https দিন';
    }
    return null;
  }
}

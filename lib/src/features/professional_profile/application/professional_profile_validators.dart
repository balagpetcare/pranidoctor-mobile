/// Shared validators for professional profile forms (Bangladesh-first UX copy).
abstract final class ProfessionalProfileValidators {
  static String? requiredLine(String? v, {String emptyMessage = 'এই ঘরটি পূরণ করুন'}) {
    if (v == null || v.trim().isEmpty) return emptyMessage;
    return null;
  }

  static String? minLength(String? v, int n, {String? message}) {
    final t = v?.trim() ?? '';
    if (t.length < n) {
      return message ?? 'কমপক্ষে $n অক্ষর লিখুন';
    }
    return null;
  }

  static String? bdMobileLoose(String? v) {
    final t = (v ?? '').replaceAll(RegExp(r'\s'), '');
    if (t.isEmpty) return null;
    if (!RegExp(r'^01[3-9]\d{8}$').hasMatch(t)) {
      return '১১ সংখ্যার বাংলাদেশি মোবাইল নম্বর লিখুন';
    }
    return null;
  }
}

/// Customer-facing provider role for navigation and unified APIs.
enum ProviderKind {
  doctor,
  aiTechnician;

  String get labelBn {
    return switch (this) {
      ProviderKind.doctor => 'ডাক্তার',
      ProviderKind.aiTechnician => 'এআই টেকনিশিয়ান',
    };
  }

  static ProviderKind? tryParse(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    final v = raw.toLowerCase().trim();
    if (v == 'doctor' || v == 'doc') return ProviderKind.doctor;
    if (v == 'technician' ||
        v == 'ai' ||
        v == 'ai_technician' ||
        v == 'aitechnician') {
      return ProviderKind.aiTechnician;
    }
    return null;
  }
}

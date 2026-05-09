/// `GET /api/mobile/app-config` — non-secret bootstrap for the home screen.
class MobileAppConfig {
  const MobileAppConfig({this.emergencyPhone});

  final String? emergencyPhone;

  static const MobileAppConfig empty = MobileAppConfig();

  factory MobileAppConfig.fromJson(Map<String, dynamic> json) {
    final raw = json['emergencyPhone'];
    final s = raw is String ? raw.trim() : '';
    return MobileAppConfig(emergencyPhone: s.isEmpty ? null : s);
  }
}

/// DTOs for `GET /api/mobile/locations/*` (aligned with web `MobileLocationDto`).
class MobileLocationDto {
  const MobileLocationDto({
    required this.id,
    required this.slug,
    required this.nameBn,
    required this.nameEn,
  });

  final String id;
  final String slug;
  final String nameBn;
  final String nameEn;

  String get displayLabelBn =>
      nameBn.trim().isNotEmpty ? nameBn.trim() : nameEn.trim();

  static String _stringField(dynamic v, {String fallback = ''}) {
    if (v == null) return fallback;
    if (v is String) return v;
    return v.toString();
  }

  factory MobileLocationDto.fromJson(Map<String, dynamic> j) {
    return MobileLocationDto(
      id: _stringField(j['id']),
      slug: _stringField(j['slug']),
      nameBn: _stringField(j['nameBn']),
      nameEn: _stringField(j['nameEn']),
    );
  }
}

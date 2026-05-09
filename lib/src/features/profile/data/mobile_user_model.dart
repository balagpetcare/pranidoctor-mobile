/// Logged-in mobile user from `GET /api/mobile/me` (customer-first).
class MobileUser {
  const MobileUser({
    this.id,
    required this.name,
    required this.phone,
    this.email,
    this.area,
    this.role,
    this.profilePhotoUrl,
  });

  final String? id;
  final String name;
  final String phone;
  final String? email;
  final String? area;

  /// API string e.g. `customer`, `doctor`, `technician`.
  final String? role;
  final String? profilePhotoUrl;

  factory MobileUser.fromJson(Map<String, dynamic> json) {
    final name = _string(json, const ['name', 'fullName', 'displayName']) ?? '';
    final phone = _string(json, const ['phone', 'phoneNumber', 'mobile']) ?? '';
    return MobileUser(
      id: _string(json, const ['id', 'userId']),
      name: name.isEmpty ? 'ব্যবহারকারী' : name,
      phone: phone.isEmpty ? '—' : phone,
      email: _string(json, const ['email']),
      area: _string(json, const ['area', 'areaLabel', 'address', 'location']),
      role: _string(json, const ['role', 'userRole']),
      profilePhotoUrl: _string(json, const [
        'profilePhotoUrl',
        'avatarUrl',
        'photoUrl',
        'imageUrl',
      ]),
    );
  }
}

String? _string(Map<String, dynamic> json, List<String> keys) {
  for (final k in keys) {
    final v = json[k];
    if (v is String && v.trim().isNotEmpty) return v.trim();
  }
  return null;
}

/// Partial update for `PATCH /api/mobile/me`.
class MobileUserPatch {
  const MobileUserPatch({this.name, this.email, this.area});

  final String? name;

  /// Pass `''` to clear optional email when backend supports it.
  final String? email;
  final String? area;

  Map<String, dynamic> toJson() {
    final m = <String, dynamic>{};
    if (name != null) m['name'] = name;
    if (email != null) m['email'] = email;
    if (area != null) m['area'] = area;
    return m;
  }

  bool get isEmpty => toJson().isEmpty;
}

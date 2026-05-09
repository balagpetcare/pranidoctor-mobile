/// Whether `/api/mobile/me` returned usable remote profile data.
enum MobileProfileLoadStatus {
  /// Successful JSON from the API.
  loaded,

  /// HTTP 404 / endpoint not deployed — treated as guest UX, not an error channel.
  fallbackEndpointMissing,

  /// Timeout, network, or unexpected envelope — guest UX with retry.
  fallbackUnavailable,
}

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
    this.loadStatus = MobileProfileLoadStatus.loaded,
  });

  final String? id;
  final String name;
  final String phone;
  final String? email;
  final String? area;

  /// API string e.g. `customer`, `doctor`, `technician`, `guest`.
  final String? role;
  final String? profilePhotoUrl;

  /// Whether `/api/mobile/me` returned a normal profile body.
  final MobileProfileLoadStatus loadStatus;

  static const String kPlaceholderPhoneBn = 'মোবাইল নম্বর যোগ করুন';
  static const String kPlaceholderAreaBn = 'এলাকা সেট করুন';

  /// `true` when the server returned a full profile payload.
  bool get isRemoteProfile => loadStatus == MobileProfileLoadStatus.loaded;

  /// How many of (phone, area) still need user input (guest or incomplete).
  int get missingProfileFieldsCount {
    var n = 0;
    final ph = phone.trim();
    if (ph.isEmpty || ph == '—' || ph == kPlaceholderPhoneBn) n++;
    final ar = area?.trim() ?? '';
    if (ar.isEmpty || ar == kPlaceholderAreaBn || ar == 'এলাকা সেট করা হয়নি') {
      n++;
    }
    return n;
  }

  /// Local guest row when the profile API is missing or failed (not real server data).
  static MobileUser guestFallback(MobileProfileLoadStatus status) {
    return MobileUser(
      name: 'অতিথি ব্যবহারকারী',
      phone: kPlaceholderPhoneBn,
      area: kPlaceholderAreaBn,
      role: 'guest',
      loadStatus: status,
    );
  }

  /// Back-compat name for tests / old call sites.
  static MobileUser get profileUnavailablePlaceholder =>
      guestFallback(MobileProfileLoadStatus.fallbackUnavailable);

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
      loadStatus: MobileProfileLoadStatus.loaded,
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
///
/// Keys are omitted when `null` — never send `email: ""` (server rejects invalid email).
/// Phone is not supported on this endpoint (OTP-linked identity).
class MobileUserPatch {
  const MobileUserPatch({this.name, this.email, this.area});

  final String? name;

  /// Non-empty email only when updating. Omit entirely when unchanged.
  final String? email;
  final String? area;

  Map<String, dynamic> toJson() {
    final m = <String, dynamic>{};
    if (name != null) m['name'] = name;
    if (email != null && email!.isNotEmpty) m['email'] = email;
    if (area != null && area!.isNotEmpty) m['area'] = area;
    return m;
  }

  bool get isEmpty => toJson().isEmpty;

  /// Sends only fields that differ from initial snapshot.
  /// Clearing email locally omits `email` from JSON — server keeps previous email.
  factory MobileUserPatch.onlyChangedFields({
    required String initialName,
    required String initialEmail,
    required String initialArea,
    required String draftName,
    required String draftEmail,
    required String draftArea,
  }) {
    final name = draftName.trim();
    final email = draftEmail.trim();
    final area = draftArea.trim();

    final inName = initialName.trim();
    final inEmail = initialEmail.trim();
    final inArea = initialArea.trim();

    String? nameOut;
    if (name != inName) nameOut = name;

    String? emailOut;
    if (email != inEmail && email.isNotEmpty) emailOut = email;

    String? areaOut;
    if (area != inArea && area.isNotEmpty) areaOut = area;

    return MobileUserPatch(name: nameOut, email: emailOut, area: areaOut);
  }
}

String bnDigit0to9(int n) {
  const d = '০১২৩৪৫৬৭৮৯';
  if (n < 0) return n.toString();
  if (n < 10) return d[n];
  return n.toString().split('').map((c) {
    final i = int.tryParse(c);
    return i != null && i < 10 ? d[i] : c;
  }).join();
}

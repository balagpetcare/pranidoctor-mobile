/// Whether `/api/mobile/me` returned usable remote profile data.
enum MobileProfileLoadStatus {
  /// Successful JSON from the API.
  loaded,

  /// HTTP 404 / endpoint not deployed — treated as guest UX, not an error channel.
  fallbackEndpointMissing,

  /// Timeout, network, or unexpected envelope — guest UX with retry.
  fallbackUnavailable,

  /// No customer session — do not call `/me` or show guest marketing profile card.
  signedOut,
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
    this.coverPhotoUrl,
    this.locationConfigured,
    this.divisionId,
    this.districtId,
    this.upazilaId,
    this.unionId,
    this.villageId,
    this.villageName,
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
  final String? coverPhotoUrl;

  /// Server hint that structured location is complete; `null` if omitted by API.
  final bool? locationConfigured;

  /// Administrative location ids when the backend returns them (flat or nested).
  final String? divisionId;
  final String? districtId;
  final String? upazilaId;
  final String? unionId;
  final String? villageId;
  final String? villageName;

  /// Whether `/api/mobile/me` returned a normal profile body.
  final MobileProfileLoadStatus loadStatus;

  static const String kPlaceholderPhoneBn = 'মোবাইল নম্বর যোগ করুন';
  static const String kPlaceholderAreaBn = 'এলাকা সেট করুন';

  /// `true` when [area] is non-empty, not a known placeholder, and not a demo/fake label.
  static bool areaLooksLikeRealUserLocation(String? area) {
    final t = area?.trim() ?? '';
    if (t.isEmpty) return false;
    if (t == kPlaceholderAreaBn || t == 'এলাকা সেট করা হয়নি') return false;
    if (t.contains('ডেমো')) return false;
    final lower = t.toLowerCase();
    if (lower.contains('demo')) return false;
    if (lower.contains('sample')) return false;
    if (lower.contains('fake')) return false;
    if (lower.contains('placeholder')) return false;
    return true;
  }

  /// `true` when the server returned a full profile payload.
  bool get isRemoteProfile => loadStatus == MobileProfileLoadStatus.loaded;

  /// Uses [locationConfigured] when the server sends it; otherwise structured
  /// ids or the same heuristic as [areaLooksLikeRealUserLocation].
  bool get isLocationConfigured {
    if (locationConfigured != null) return locationConfigured!;
    if (_hasStructuredLocationIds) return true;
    return areaLooksLikeRealUserLocation(area);
  }

  bool get _hasStructuredLocationIds {
    final d = districtId?.trim() ?? '';
    final u = upazilaId?.trim() ?? '';
    final n = unionId?.trim() ?? '';
    return d.isNotEmpty && u.isNotEmpty && n.isNotEmpty;
  }

  /// How many of (phone, area) still need user input (guest or incomplete).
  int get missingProfileFieldsCount {
    var n = 0;
    final ph = phone.trim();
    if (ph.isEmpty || ph == '—' || ph == kPlaceholderPhoneBn) n++;
    if (!isLocationConfigured) n++;
    return n;
  }

  /// Local guest row when the profile API is missing or failed (not real server data).
  static MobileUser guestFallback(MobileProfileLoadStatus status) {
    return MobileUser(
      name: 'অতিথি ব্যবহারকারী',
      phone: kPlaceholderPhoneBn,
      area: kPlaceholderAreaBn,
      role: 'guest',
      locationConfigured: null,
      loadStatus: status,
    );
  }

  /// Placeholder when there is no token — [ProfileHomeScreen] should not render
  /// the guest header; kept for [mobileUserProvider] when unauthenticated.
  static MobileUser signedOutPlaceholder() {
    return const MobileUser(
      name: '',
      phone: '',
      loadStatus: MobileProfileLoadStatus.signedOut,
    );
  }

  /// Back-compat name for tests / old call sites.
  static MobileUser get profileUnavailablePlaceholder =>
      guestFallback(MobileProfileLoadStatus.fallbackUnavailable);

  factory MobileUser.fromJson(Map<String, dynamic> json) {
    final name = _string(json, const ['name', 'fullName', 'displayName']) ?? '';
    final phone = _string(json, const ['phone', 'phoneNumber', 'mobile']) ?? '';
    final loc = _locationNestedMap(json);
    return MobileUser(
      id: _string(json, const ['id', 'userId']),
      name: name.isEmpty ? 'ব্যবহারকারী' : name,
      phone: phone.isEmpty ? '—' : phone,
      email: _string(json, const ['email']),
      area:
          _string(json, const ['area', 'areaLabel', 'address', 'location']) ??
          _stringFrom(loc, const ['area', 'areaLabel', 'label']),
      role: _string(json, const ['role', 'userRole']),
      profilePhotoUrl: _string(json, const [
        'profilePhotoUrl',
        'avatarUrl',
        'photoUrl',
        'imageUrl',
      ]),
      coverPhotoUrl: _string(json, const [
        'coverPhotoUrl',
        'coverImageUrl',
        'backgroundPhotoUrl',
        'bannerUrl',
      ]),
      locationConfigured:
          _boolOrNull(json, const [
            'locationConfigured',
            'locationSet',
            'hasConfiguredLocation',
            'isLocationConfigured',
          ]) ??
          _boolOrNull(loc, const [
            'locationConfigured',
            'locationSet',
            'hasConfiguredLocation',
          ]),
      divisionId:
          _string(json, const ['divisionId']) ??
          _stringFrom(loc, const ['divisionId']),
      districtId:
          _string(json, const ['districtId']) ??
          _stringFrom(loc, const ['districtId']),
      upazilaId:
          _string(json, const ['upazilaId']) ??
          _stringFrom(loc, const ['upazilaId']),
      unionId:
          _string(json, const ['unionId']) ??
          _stringFrom(loc, const ['unionId']),
      villageId:
          _string(json, const ['villageId']) ??
          _stringFrom(loc, const ['villageId']),
      villageName:
          _string(json, const ['villageName']) ??
          _stringFrom(loc, const ['villageName', 'villageLabel']),
      loadStatus: MobileProfileLoadStatus.loaded,
    );
  }
}

Map<String, dynamic>? _locationNestedMap(Map<String, dynamic> json) {
  for (final key in const ['addressJson', 'address', 'location']) {
    final v = json[key];
    if (v is Map<String, dynamic>) return v;
  }
  return null;
}

bool? _boolOrNull(Map<String, dynamic>? json, List<String> keys) {
  if (json == null) return null;
  for (final k in keys) {
    final v = json[k];
    if (v is bool) return v;
    if (v is num) return v != 0;
    if (v is String) {
      final s = v.trim().toLowerCase();
      if (s == 'true' || s == '1' || s == 'yes') return true;
      if (s == 'false' || s == '0' || s == 'no') return false;
    }
  }
  return null;
}

String? _stringFrom(Map<String, dynamic>? json, List<String> keys) {
  if (json == null) return null;
  return _string(json, keys);
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

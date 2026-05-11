// Central paths and feature flags for customer profile / location / photo APIs.
// Live server today: GET + PATCH /api/mobile/me. Split routes are optional; see flags below.

// --- Paths (relative to ApiClient base URL, no host hardcoding) ---

abstract final class MobileProfileApiPaths {
  static const String getMe = '/api/mobile/me';

  /// Monolithic profile update (supported by current backend).
  static const String patchMeLegacy = '/api/mobile/me';

  /// Planned: partial update — name, email, etc. (no location).
  /// TODO(backend): implement `PATCH /api/mobile/me/profile`
  static const String patchProfile = '/api/mobile/me/profile';

  /// Planned: structured location + optional human-readable [area] label.
  /// TODO(backend): implement `PATCH /api/mobile/me/location`
  static const String patchLocation = '/api/mobile/me/location';

  /// Multipart field `file` → returns envelope; client refetches [getMe].
  static const String postProfilePhoto = '/api/mobile/uploads/profile-image';

  /// Multipart field `file` → returns envelope; client refetches [getMe].
  static const String postCoverPhoto = '/api/mobile/uploads/cover-image';
}

/// When `true`, [MobileUserRepositoryLive.updateBasicProfile] uses
/// [MobileProfileApiPaths.patchProfile] and [updateLocation] uses
/// [MobileProfileApiPaths.patchLocation]. When `false` (default), both use
/// [MobileProfileApiPaths.patchMeLegacy] with a safe JSON subset.
const bool kMobileProfileUseSplitProfileLocationPatch = false;

/// When `true`, [MobileUserRepositoryLive.uploadProfilePhoto] /
/// [uploadCoverPhoto] send `multipart/form-data` with field name `file`.
/// When `false` (default), those methods return immediately with a Bengali
/// “not deployed” result (no HTTP round-trip).
const bool kMobileProfilePhotoPostEndpointsEnabled = true;

/// Location patch body: omit nulls. Legacy [patchMeLegacy] sends only [area]
/// unless split patch is enabled (then all non-null keys are sent).
class MobileUserLocationUpdate {
  const MobileUserLocationUpdate({
    this.area,
    this.divisionId,
    this.districtId,
    this.upazilaId,
    this.unionId,
    this.villageId,
    this.villageName,
  });

  final String? area;
  final String? divisionId;
  final String? districtId;
  final String? upazilaId;
  final String? unionId;
  final String? villageId;
  final String? villageName;

  bool get isEmpty {
    final keys = toJsonSplit();
    return keys.isEmpty;
  }

  /// JSON for [MobileProfileApiPaths.patchLocation] (all optional keys).
  Map<String, dynamic> toJsonSplit() {
    final m = <String, dynamic>{};
    if (area != null && area!.trim().isNotEmpty) m['area'] = area!.trim();
    if (divisionId != null && divisionId!.trim().isNotEmpty) {
      m['divisionId'] = divisionId!.trim();
    }
    if (districtId != null && districtId!.trim().isNotEmpty) {
      m['districtId'] = districtId!.trim();
    }
    if (upazilaId != null && upazilaId!.trim().isNotEmpty) {
      m['upazilaId'] = upazilaId!.trim();
    }
    if (unionId != null && unionId!.trim().isNotEmpty) {
      m['unionId'] = unionId!.trim();
    }
    if (villageId != null && villageId!.trim().isNotEmpty) {
      m['villageId'] = villageId!.trim();
    }
    if (villageName != null && villageName!.trim().isNotEmpty) {
      m['villageName'] = villageName!.trim();
    }
    return m;
  }

  /// Legacy monolithic PATCH — only the free-text label (safest for old servers).
  Map<String, dynamic> toJsonLegacy() {
    final m = <String, dynamic>{};
    if (area != null && area!.trim().isNotEmpty) m['area'] = area!.trim();
    return m;
  }
}

enum MobileProfilePhotoUploadStatus { success, endpointNotReady, failure }

class MobileProfilePhotoUploadResult {
  const MobileProfilePhotoUploadResult._({
    required this.status,
    this.messageBn,
  });

  final MobileProfilePhotoUploadStatus status;
  final String? messageBn;

  static const MobileProfilePhotoUploadResult success =
      MobileProfilePhotoUploadResult._(
        status: MobileProfilePhotoUploadStatus.success,
      );

  static MobileProfilePhotoUploadResult notDeployed({String? messageBn}) {
    return MobileProfilePhotoUploadResult._(
      status: MobileProfilePhotoUploadStatus.endpointNotReady,
      messageBn:
          messageBn ??
          'সার্ভারে প্রোফাইল/কভার ছবি আপলোড এখনো সক্রিয় নয়। পরে আবার চেষ্টা করুন।',
    );
  }

  static MobileProfilePhotoUploadResult failed(String messageBn) {
    return MobileProfilePhotoUploadResult._(
      status: MobileProfilePhotoUploadStatus.failure,
      messageBn: messageBn,
    );
  }
}

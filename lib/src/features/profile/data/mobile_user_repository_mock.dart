import 'package:pranidoctor_mobile/src/features/profile/data/mobile_profile_api_contract.dart';
import 'package:pranidoctor_mobile/src/features/profile/data/mobile_user_model.dart';
import 'package:pranidoctor_mobile/src/features/profile/data/mobile_user_repository.dart';
import 'package:pranidoctor_mobile/src/features/profile/data/profile_api_exception.dart';

/// Demo user when `USE_MOCK_PROFILE_API=true`.
class MobileUserRepositoryMock implements MobileUserRepository {
  MobileUser _user = const MobileUser(
    id: 'mock-1',
    name: 'রহিম উদ্দিন',
    phone: '০১৭১১১১১১১১',
    email: 'rahim@example.com',
    area: 'ঢাকা, মিরপুর',
    role: 'customer',
    profilePhotoUrl: null,
    coverPhotoUrl: null,
    locationConfigured: true,
  );

  @override
  Future<MobileUser> fetchMe() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return _user;
  }

  @override
  Future<MobileUser> patchMe(MobileUserPatch patch) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    if (patch.isEmpty) {
      return _user;
    }
    _user = _copyWithPatch(patch);
    return _user;
  }

  @override
  Future<MobileUser> updateBasicProfile({String? name, String? email}) async {
    final tName = name?.trim();
    final tEmail = email?.trim();
    final useName = tName != null && tName.isNotEmpty;
    final useEmail = tEmail != null && tEmail.isNotEmpty;
    if (!useName && !useEmail) {
      throw ProfileApiException('কোনো পরিবর্তন নেই।');
    }
    await Future<void>.delayed(const Duration(milliseconds: 350));
    return patchMe(
      MobileUserPatch(
        name: useName ? tName : null,
        email: useEmail ? tEmail : null,
      ),
    );
  }

  @override
  Future<MobileUser> updateLocation(MobileUserLocationUpdate update) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    if (update.isEmpty) {
      throw ProfileApiException('কোনো পরিবর্তন নেই।');
    }
    _user = MobileUser(
      id: _user.id,
      name: _user.name,
      phone: _user.phone,
      email: _user.email,
      area: update.area?.trim().isNotEmpty == true
          ? update.area!.trim()
          : _user.area,
      role: _user.role,
      profilePhotoUrl: _user.profilePhotoUrl,
      coverPhotoUrl: _user.coverPhotoUrl,
      locationConfigured: true,
      divisionId: update.divisionId ?? _user.divisionId,
      districtId: update.districtId ?? _user.districtId,
      upazilaId: update.upazilaId ?? _user.upazilaId,
      unionId: update.unionId ?? _user.unionId,
      villageId: update.villageId ?? _user.villageId,
      villageName: update.villageName ?? _user.villageName,
      loadStatus: MobileProfileLoadStatus.loaded,
    );
    return _user;
  }

  @override
  Future<MobileProfilePhotoUploadResult> uploadProfilePhoto(
    String filePath,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    if (!kMobileProfilePhotoPostEndpointsEnabled) {
      return MobileProfilePhotoUploadResult.notDeployed();
    }
    _user = MobileUser(
      id: _user.id,
      name: _user.name,
      phone: _user.phone,
      email: _user.email,
      area: _user.area,
      role: _user.role,
      profilePhotoUrl: 'https://example.invalid/mock-profile-photo',
      coverPhotoUrl: _user.coverPhotoUrl,
      locationConfigured: _user.locationConfigured,
      divisionId: _user.divisionId,
      districtId: _user.districtId,
      upazilaId: _user.upazilaId,
      unionId: _user.unionId,
      villageId: _user.villageId,
      villageName: _user.villageName,
      loadStatus: _user.loadStatus,
    );
    return MobileProfilePhotoUploadResult.success;
  }

  @override
  Future<MobileProfilePhotoUploadResult> uploadCoverPhoto(
    String filePath,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    if (!kMobileProfilePhotoPostEndpointsEnabled) {
      return MobileProfilePhotoUploadResult.notDeployed();
    }
    _user = MobileUser(
      id: _user.id,
      name: _user.name,
      phone: _user.phone,
      email: _user.email,
      area: _user.area,
      role: _user.role,
      profilePhotoUrl: _user.profilePhotoUrl,
      coverPhotoUrl: 'https://example.invalid/mock-cover-photo',
      locationConfigured: _user.locationConfigured,
      divisionId: _user.divisionId,
      districtId: _user.districtId,
      upazilaId: _user.upazilaId,
      unionId: _user.unionId,
      villageId: _user.villageId,
      villageName: _user.villageName,
      loadStatus: _user.loadStatus,
    );
    return MobileProfilePhotoUploadResult.success;
  }

  MobileUser _copyWithPatch(MobileUserPatch patch) {
    return MobileUser(
      id: _user.id,
      name: patch.name ?? _user.name,
      phone: _user.phone,
      email: patch.email != null
          ? (patch.email!.isEmpty ? null : patch.email)
          : _user.email,
      area: patch.area ?? _user.area,
      role: _user.role,
      profilePhotoUrl: _user.profilePhotoUrl,
      coverPhotoUrl: _user.coverPhotoUrl,
      locationConfigured: _user.locationConfigured,
      divisionId: _user.divisionId,
      districtId: _user.districtId,
      upazilaId: _user.upazilaId,
      unionId: _user.unionId,
      villageId: _user.villageId,
      villageName: _user.villageName,
      loadStatus: MobileProfileLoadStatus.loaded,
    );
  }
}

import 'package:pranidoctor_mobile/src/features/profile/data/mobile_user_model.dart';
import 'package:pranidoctor_mobile/src/features/profile/data/mobile_user_repository.dart';

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
    _user = MobileUser(
      id: _user.id,
      name: patch.name ?? _user.name,
      phone: _user.phone,
      email: patch.email != null
          ? (patch.email!.isEmpty ? null : patch.email)
          : _user.email,
      area: patch.area ?? _user.area,
      role: _user.role,
      profilePhotoUrl: _user.profilePhotoUrl,
      loadStatus: MobileProfileLoadStatus.loaded,
    );
    return _user;
  }
}

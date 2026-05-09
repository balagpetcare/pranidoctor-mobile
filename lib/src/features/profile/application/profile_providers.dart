import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pranidoctor_mobile/src/core/config/app_config.dart';
import 'package:pranidoctor_mobile/src/core/network/api_client.dart';
import 'package:pranidoctor_mobile/src/features/profile/data/mobile_user_model.dart';
import 'package:pranidoctor_mobile/src/features/profile/data/mobile_user_repository.dart';
import 'package:pranidoctor_mobile/src/features/profile/data/mobile_user_repository_mock.dart';

final profileRepositoryProvider = Provider<MobileUserRepository>((ref) {
  if (AppConfig.useMockProfileApi) {
    return MobileUserRepositoryMock();
  }
  return MobileUserRepositoryLive(ref.watch(apiClientProvider));
});

final mobileUserProvider = FutureProvider.autoDispose<MobileUser>((ref) {
  return ref.watch(profileRepositoryProvider).fetchMe();
});

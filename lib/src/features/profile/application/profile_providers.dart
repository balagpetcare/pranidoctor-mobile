import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pranidoctor_mobile/src/core/config/app_config.dart';
import 'package:pranidoctor_mobile/src/core/network/api_client.dart';
import 'package:pranidoctor_mobile/src/features/home/application/home_startup_defer.dart';
import 'package:pranidoctor_mobile/src/features/profile/data/mobile_user_model.dart';
import 'package:pranidoctor_mobile/src/features/profile/data/mobile_user_repository.dart';
import 'package:pranidoctor_mobile/src/features/profile/data/mobile_user_repository_mock.dart';

final profileRepositoryProvider = Provider<MobileUserRepository>((ref) {
  if (AppConfig.useMockProfileApi) {
    return MobileUserRepositoryMock();
  }
  return MobileUserRepositoryLive(ref.watch(apiClientProvider));
});

/// Fetches `GET /api/mobile/me` with a hard timeout so the Profile tab never
/// spins forever if the client, storage read, or network stalls.
///
/// **Note:** If `Dio` `onRequest` (e.g. secure token read) hangs beyond this
/// timeout, the Profile tab still recovers; consider a bounded read in the
/// interceptor if that is ever observed in the field.
final mobileUserProvider = FutureProvider.autoDispose<MobileUser>((ref) async {
  try {
    await ref.watch(homeNetworkDeferProvider.future);
    return await ref
        .read(profileRepositoryProvider)
        .fetchMe()
        .timeout(const Duration(seconds: 25));
  } on TimeoutException {
    return MobileUser.guestFallback(
      MobileProfileLoadStatus.fallbackUnavailable,
    );
  }
});

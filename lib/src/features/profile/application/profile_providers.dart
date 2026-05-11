import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pranidoctor_mobile/src/core/config/app_config.dart';
import 'package:pranidoctor_mobile/src/core/network/api_client.dart';
import 'package:pranidoctor_mobile/src/features/home/application/home_startup_defer.dart';
import 'package:pranidoctor_mobile/src/features/profile/data/mobile_user_model.dart';
import 'package:pranidoctor_mobile/src/features/profile/data/mobile_user_repository.dart';
import 'package:pranidoctor_mobile/src/features/profile/data/mobile_user_repository_mock.dart';
import 'package:pranidoctor_mobile/src/features/session/application/session_notifier.dart';

final profileRepositoryProvider = Provider<MobileUserRepository>((ref) {
  if (AppConfig.useMockProfileApi) {
    return MobileUserRepositoryMock();
  }
  return MobileUserRepositoryLive(ref.watch(apiClientProvider));
});

/// Fetches `GET /api/mobile/me` with a hard timeout so the Profile tab never
/// spins forever if the client, storage read, or network stalls.
///
/// Watches [sessionNotifierProvider] so a cached guest `/me` result is not kept
/// after OTP login / logout — the provider rebuilds when auth changes and
/// refetches with the current token (Dio reads token per request).
///
/// **Note:** If `Dio` `onRequest` (e.g. secure token read) hangs beyond this
/// timeout, the Profile tab still recovers; consider a bounded read in the
/// interceptor if that is ever observed in the field.
final mobileUserProvider = FutureProvider.autoDispose<MobileUser>((ref) async {
  final authKey = ref.watch(
    sessionNotifierProvider.select((s) => (s.isAuthenticated, s.role)),
  );
  assert(() {
    debugPrint(
      '[PraniDoctor][auth] mobileUserProvider: refetch scheduled '
      '(authed=${authKey.$1} role=${authKey.$2})',
    );
    return true;
  }());

  try {
    await ref.watch(homeNetworkDeferProvider.future);
    final user = await ref
        .read(profileRepositoryProvider)
        .fetchMe()
        .timeout(const Duration(seconds: 25));
    assert(() {
      debugPrint(
        '[PraniDoctor][auth] profile/me: loadStatus=${user.loadStatus} '
        'remote=${user.isRemoteProfile}',
      );
      return true;
    }());
    return user;
  } on TimeoutException {
    assert(() {
      debugPrint('[PraniDoctor][auth] profile/me: timeout → guest fallback');
      return true;
    }());
    return MobileUser.guestFallback(
      MobileProfileLoadStatus.fallbackUnavailable,
    );
  }
});

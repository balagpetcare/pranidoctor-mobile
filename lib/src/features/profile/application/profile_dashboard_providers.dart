import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pranidoctor_mobile/src/core/network/api_client.dart';
import 'package:pranidoctor_mobile/src/features/home/application/home_startup_defer.dart';
import 'package:pranidoctor_mobile/src/features/profile/data/dashboard_context_models.dart';
import 'package:pranidoctor_mobile/src/features/profile/data/profile_dashboard_repository.dart';
import 'package:pranidoctor_mobile/src/features/session/application/session_notifier.dart';

final profileDashboardRepositoryProvider =
    Provider<ProfileDashboardRepository>((ref) {
  return ProfileDashboardRepositoryLive(ref.watch(apiClientProvider));
});

/// Dashboard routing for the Profile tab (`GET /api/mobile/profile/dashboard-context`).
///
/// Only watch when [sessionNotifierProvider.isAuthenticated] is true — the gate
/// short-circuits for logged-out users so this provider is not subscribed.
final profileDashboardContextProvider =
    FutureProvider.autoDispose<DashboardContext>((ref) async {
  final authed = ref.watch(
    sessionNotifierProvider.select((s) => s.isAuthenticated),
  );
  assert(() {
    debugPrint(
      '[PraniDoctor][auth] profileDashboardContextProvider: authed=$authed',
    );
    return true;
  }());

  if (!authed) {
    throw StateError(
      'profileDashboardContextProvider must not be watched when logged out',
    );
  }

  try {
    await ref.watch(homeNetworkDeferProvider.future);
    if (!ref.mounted) {
      throw StateError('profileDashboardContextProvider disposed');
    }
    if (!ref.read(sessionNotifierProvider).isAuthenticated) {
      throw StateError('profileDashboardContextProvider unauthenticated');
    }
    final ctx = await ref
        .read(profileDashboardRepositoryProvider)
        .fetchDashboardContext()
        .timeout(const Duration(seconds: 25));
    if (!ref.mounted) {
      throw StateError('profileDashboardContextProvider disposed');
    }
    return ctx;
  } on TimeoutException {
    throw TimeoutException('dashboard-context timeout');
  }
});

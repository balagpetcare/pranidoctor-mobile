import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/navigation_keys.dart';
import '../../profile/application/profile_providers.dart';
import '../../session/application/session_notifier.dart';
import 'post_customer_login_navigation.dart';

/// Persists customer JWT, refreshes profile providers, then navigates like OTP success.
///
/// [postLoginTab] / [postLoginNextPath] are typically from [GoRouterState] on the login route.
///
/// Used after OTP verify, password login, and registration — do not log [accessToken].
Future<void> completeCustomerSessionAfterSignIn({
  required WidgetRef ref,
  required String accessToken,
  String? postLoginTab,
  String? postLoginNextPath,
}) async {
  await ref.read(sessionNotifierProvider.notifier).signInCustomer(accessToken);
  ref.invalidate(mobileUserProvider);
  final ctx = pdRootNavigatorKey.currentContext;
  if (ctx == null || !ctx.mounted) return;
  navigateAfterCustomerLogin(
    ref,
    ctx,
    tab: postLoginTab,
    nextPath: postLoginNextPath,
  );
}

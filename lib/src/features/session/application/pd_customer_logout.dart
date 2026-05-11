import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../home/application/home_shell_tab_provider.dart';
import '../../workspace/application/professional_workspace_tab_provider.dart';
import 'session_notifier.dart';

/// Clears JWT + [SessionState], resets bottom navigation to Home (index 0).
///
/// Accepts [WidgetRef], [Ref], or [ProviderContainer] (anything with `.read`).
///
/// All `ref.read` calls that use the **caller's** ref happen before the async
/// [SessionNotifier.signOut] gap. Otherwise a short‑lived ref (notably from
/// [dioProvider] during in‑flight teardown) can be invalid after `await`.
Future<void> pdPerformCustomerLogout(dynamic ref) async {
  final sessionNotifier = ref.read(sessionNotifierProvider.notifier);
  final homeTab = ref.read(homeShellTabIndexProvider.notifier);
  final proTab = ref.read(professionalWorkspaceTabIndexProvider.notifier);
  // Reset shell tab while [ref] is still known valid — never after [await],
  // e.g. [dioProvider] interceptors may outlive a disposed [ProviderContainer].
  homeTab.select(0);
  proTab.select(0);
  await sessionNotifier.signOut();
}

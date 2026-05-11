import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pranidoctor_mobile/src/features/auth/login_entry_screen.dart';
import 'package:pranidoctor_mobile/src/features/session/application/session_notifier.dart';

/// Whether the app has a persisted customer session flag (JWT present in storage
/// is implied by [SessionNotifier]; treat as "logged in" for shell tab gating).
bool pdCustomerSessionIsAuthenticated(WidgetRef ref) =>
    ref.read(sessionNotifierProvider).isAuthenticated;

/// Opens [LoginEntryScreen] with `?tab=` (and optional `next=`) for post-login
/// shell tab selection (`post_customer_login_navigation.dart`).
///
/// **Never** opens the legacy verification bottom sheet
/// (`showCustomerAuthRequiredSheet` / "সেবা নিতে মোবাইল নম্বর ভেরিফাই করুন").
/// Use that sheet only for contextual CTAs outside the main bottom navigation.
void pdPushCustomerLoginIntent(
  BuildContext context, {
  required String shellTab,
  String? nextPath,
}) {
  if (!context.mounted) return;
  final path = GoRouterState.of(context).uri.path;
  if (path == LoginEntryScreen.routePath) return;

  final params = <String, String>{'tab': shellTab.trim()};
  final next = nextPath?.trim();
  if (next != null && next.isNotEmpty) {
    params['next'] = next;
  }
  final q = params.entries
      .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
      .join('&');
  context.push('${LoginEntryScreen.routePath}?$q');
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pranidoctor_mobile/src/features/home/application/home_shell_tab_provider.dart';
import 'package:pranidoctor_mobile/src/features/home/home_shell_screen.dart';

/// Whether [path] is safe to open after customer OTP (same-origin app routes only).
bool isAllowedPostLoginCustomerPath(String path) {
  final p = path.trim();
  if (p.isEmpty || !p.startsWith('/') || p.contains('..')) return false;
  if (p == HomeShellScreen.routePath) return true;
  const exact = <String>{
    '/booking/new',
    '/notifications',
    '/animals',
    '/knowledge',
  };
  if (exact.contains(p)) return true;
  const prefixes = <String>[
    '/providers/',
    '/knowledge/',
    '/profile/',
    '/ai-services/technicians',
    '/ai-services/my-requests',
    '/ai-services/request',
    '/service-requests/',
  ];
  for (final pre in prefixes) {
    if (p.startsWith(pre)) return true;
  }
  return false;
}

/// After OTP success: optional deep link [nextPath], else shell [tab] (`profile`|`notifications`|`services`).
void navigateAfterCustomerLogin(
  WidgetRef ref,
  BuildContext context, {
  String? tab,
  String? nextPath,
}) {
  if (!context.mounted) return;
  final next = nextPath?.trim();
  if (next != null && next.isNotEmpty && isAllowedPostLoginCustomerPath(next)) {
    context.go(next);
    return;
  }

  final t = tab?.trim().toLowerCase();
  switch (t) {
    case 'profile':
      ref.read(homeShellTabIndexProvider.notifier).select(4);
      break;
    case 'notifications':
      ref.read(homeShellTabIndexProvider.notifier).select(3);
      break;
    case 'services':
      ref.read(homeShellTabIndexProvider.notifier).select(2);
      break;
    default:
      ref.read(homeShellTabIndexProvider.notifier).select(0);
  }
  context.go(HomeShellScreen.routePath);
}

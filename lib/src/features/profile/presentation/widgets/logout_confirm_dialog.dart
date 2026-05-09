import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pranidoctor_mobile/src/features/auth/login_entry_screen.dart';
import 'package:pranidoctor_mobile/src/features/session/application/session_notifier.dart';

/// Shows Bengali confirmation; on confirm clears session and navigates to login.
Future<void> showPdLogoutConfirmAndExecute(
  BuildContext context,
  WidgetRef ref,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('প্রস্থান করবেন?'),
      content: const Text('আপনার সেশন বন্ধ হবে। পরে আবার লগইন করতে হবে।'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('বাতিল'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: const Text('প্রস্থান'),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return;
  await ref.read(sessionNotifierProvider.notifier).signOut();
  if (context.mounted) {
    context.go(LoginEntryScreen.routePath);
  }
}

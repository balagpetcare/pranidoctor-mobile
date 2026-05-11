import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pranidoctor_mobile/src/features/home/home_shell_screen.dart';
import 'package:pranidoctor_mobile/src/features/notifications/application/notifications_providers.dart';
import 'package:pranidoctor_mobile/src/features/profile/application/profile_providers.dart';
import 'package:pranidoctor_mobile/src/features/session/application/pd_customer_logout.dart';

/// Shows Bengali confirmation; on confirm clears session, caches, and goes Home.
Future<void> showPdLogoutConfirmAndExecute(
  BuildContext context,
  WidgetRef ref,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      icon: Icon(
        Icons.logout_rounded,
        color: Theme.of(context).colorScheme.primary,
      ),
      title: const Text('প্রস্থান করবেন?'),
      content: const Text(
        'লগআউট করলে এই ডিভাইসের সেশন শেষ হবে। আবার ব্যবহার করতে মোবাইল নম্বর দিয়ে যাচাইকরণ লাগবে।',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('থাকুন'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: const Text('লগআউট'),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return;
  await pdPerformCustomerLogout(ref);
  ref.invalidate(mobileUserProvider);
  ref.invalidate(unreadNotificationsTotalProvider);
  ref.invalidate(notificationsListProvider);
  if (context.mounted) {
    context.go(HomeShellScreen.routePath);
  }
}

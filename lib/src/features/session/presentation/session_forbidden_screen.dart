import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:pranidoctor_mobile/src/features/home/home_shell_screen.dart';

/// Shown when a signed-in **general** user opens a professional-only route.
class SessionForbiddenScreen extends StatelessWidget {
  const SessionForbiddenScreen({super.key});

  static const routePath = '/session/forbidden';
  static const routeName = 'sessionForbidden';

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('প্রবেশ সীমিত')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(Icons.lock_outline, size: 56, color: scheme.primary),
            const SizedBox(height: 16),
            Text(
              'এই অংশটি শুধুমাত্র পেশাদার অ্যাকাউন্টের জন্য।',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Text(
              'আপনার গ্রাহক অ্যাকাউন্ট দিয়ে এখানে যাওয়া যাবে না।',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                    height: 1.45,
                  ),
            ),
            const SizedBox(height: 28),
            FilledButton(
              onPressed: () =>
                  context.go(HomeShellScreen.routePath),
              child: const Text('হোমে ফিরুন'),
            ),
          ],
        ),
      ),
    );
  }
}

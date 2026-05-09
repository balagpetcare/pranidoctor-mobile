import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/screen_padding.dart';
import '../../core/constants/pd_radii.dart';
import '../home/home_shell_screen.dart';
import '../session/application/session_notifier.dart';

/// Customer entry — M02 placeholder-first; [signInGuest] continues without backend.
class LoginEntryScreen extends ConsumerWidget {
  const LoginEntryScreen({super.key});

  static const routePath = '/login';
  static const routeName = 'loginEntry';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final pad = pdScreenPadding(context);

    return Scaffold(
      appBar: AppBar(title: const Text('প্রবেশ')),
      body: ListView(
        padding: pad.copyWith(top: 16, bottom: 32),
        children: [
          Icon(Icons.pets, size: 72, color: scheme.primary),
          const SizedBox(height: 20),
          Text(
            'প্রাণি ডাক্তারে স্বাগতম',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          Text(
            'পরবর্তীতে SMS বা সোশ্যাল লগইন যুক্ত হবে। এখন ডেমো হিসেবে অ্যাপ চালিয়ে দেখতে নিচের বোতাম চাপুন।',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 32),
          FilledButton(
            onPressed: () {
              ref.read(sessionNotifierProvider.notifier).signInGuest();
              context.go(HomeShellScreen.routePath);
            },
            child: const Text('চালিয়ে যান'),
          ),
          const SizedBox(height: 16),
          Text(
            'সতর্কতা: ডেমো প্রবেশে সার্ভার API কাজ নাও করতে পারে।',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: scheme.outline),
          ),
          const SizedBox(height: 28),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(PdRadii.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'পরবর্তী ধাপ',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'আসল লগইন ও নিরাপদ সেশন পরের টাস্কে যুক্ত হবে।',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

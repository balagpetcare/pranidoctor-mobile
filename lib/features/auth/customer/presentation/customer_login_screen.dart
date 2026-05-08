import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/app_config.dart';
import '../../../home/customer/presentation/customer_home_screen.dart';
import '../../../session/application/session_notifier.dart';

class CustomerLoginScreen extends ConsumerWidget {
  const CustomerLoginScreen({super.key});

  static const routePath = '/customer/login';
  static const routeName = 'customerLogin';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: const Text('গ্রাহক লগইন'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Customer sign-in',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'মোবাইল নম্বর দিয়ে প্রবেশ (শীঘ্রই)',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 20),
          TextField(
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'মোবাইল নম্বর',
              hintText: '01XXXXXXXXX',
            ),
            enabled: false,
          ),
          const SizedBox(height: 12),
          TextField(
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'OTP / পাসওয়ার্ড',
            ),
            enabled: false,
          ),
          const SizedBox(height: 28),
          FilledButton(
            onPressed: () async {
              await ref.read(sessionNotifierProvider.notifier).completePlaceholderSignIn();
              if (context.mounted) {
                context.go(CustomerHomeScreen.routePath);
              }
            },
            child: const Text('চালিয়ে যান (placeholder)'),
          ),
          const SizedBox(height: 12),
          Text(
            'API: ${AppConfig.apiBaseUrl}',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: scheme.outline,
                ),
          ),
        ],
      ),
    );
  }
}

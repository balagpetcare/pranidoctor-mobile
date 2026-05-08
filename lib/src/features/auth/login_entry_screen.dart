import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/screen_padding.dart';
import '../../core/config/app_config.dart';
import '../home/home_shell_screen.dart';

/// Customer login entry — UI only; no real auth, OTP, or social SDKs.
class LoginEntryScreen extends StatelessWidget {
  const LoginEntryScreen({super.key});

  static const routePath = '/login';
  static const routeName = 'loginEntry';

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final pad = pdScreenPadding(context);
    return Scaffold(
      appBar: AppBar(title: const Text('প্রবেশ')),
      body: ListView(
        padding: pad.copyWith(top: 12, bottom: 28),
        children: [
          Text(
            'গ্রাহক হিসেবে চালিয়ে যান',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'নিচে মোবাইল বা সোশ্যাল অপশন দেখানো হয়েছে। আসল লগইন পরের কাজে যুক্ত হবে।',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 28),
          Text(
            'মোবাইল নম্বর দিয়ে লগইন',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
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
            decoration: const InputDecoration(labelText: 'OTP / পাসওয়ার্ড'),
            enabled: false,
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: () => context.go(HomeShellScreen.routePath),
            child: const Text('মোবাইল দিয়ে চালিয়ে যান (খোলস)'),
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(child: Divider(color: scheme.outlineVariant)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'অথবা',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
              Expanded(child: Divider(color: scheme.outlineVariant)),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'সোশ্যাল (শীঘ্রই)',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: null,
            icon: const Icon(Icons.g_translate, size: 22),
            label: const Text('Google দিয়ে লগইন (শীঘ্রই)'),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: null,
            icon: const Icon(Icons.facebook, size: 22),
            label: const Text('Facebook দিয়ে লগইন (শীঘ্রই)'),
          ),
          const SizedBox(height: 24),
          Center(
            child: TextButton(
              onPressed: () => context.go(HomeShellScreen.routePath),
              child: const Text('লগইন ছাড়াই হোম দেখুন (খোলস)'),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'API ভিত্তি: ${AppConfig.apiBaseUrl}',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: scheme.outline),
          ),
        ],
      ),
    );
  }
}

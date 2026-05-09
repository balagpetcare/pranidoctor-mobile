import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/app_config.dart';
import '../../../session/application/session_notifier.dart';
import '../../../technician_ai/presentation/technician_dashboard_screen.dart';

class TechnicianLoginScreen extends ConsumerWidget {
  const TechnicianLoginScreen({super.key});

  static const routePath = '/technician/login';
  static const routeName = 'technicianLogin';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final mock = AppConfig.useMockTechnicianApi;
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: const Text('AI টেকনিশিয়ান প্রবেশ'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'কৃত্রিম প্রজনন (AI) টেকনিশিয়ান ওয়ার্কফ্লো',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          Text(
            mock
                ? 'ডেমো মোড চালু। প্রদর্শনের জন্য কৃত্রিম ডেটা ব্যবহার করা হচ্ছে।'
                : 'লাইভ সার্ভারে টেকনিশিয়ান এন্ডপয়েন্ট সংযুক্ত থাকলে আসল ডেটা দেখা যাবে।',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          TextField(
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'ইমেইল (শীঘ্রই)',
              hintText: 'টেক@উদাহরণ.কম',
            ),
            enabled: false,
          ),
          const SizedBox(height: 12),
          TextField(
            obscureText: true,
            decoration: const InputDecoration(labelText: 'পাসওয়ার্ড (শীঘ্রই)'),
            enabled: false,
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () async {
                await ref
                    .read(sessionNotifierProvider.notifier)
                    .setRole(AppRole.technician);
                if (context.mounted) {
                  context.go(TechnicianDashboardScreen.routePath);
                }
              },
              child: const Text('চালিয়ে যান (খোলস)'),
            ),
          ),
          const SizedBox(height: 12),
          if (kDebugMode)
            Text(
              'API (ডিবাগ): ${AppConfig.apiBaseUrl}',
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: scheme.outline),
            ),
        ],
      ),
    );
  }
}

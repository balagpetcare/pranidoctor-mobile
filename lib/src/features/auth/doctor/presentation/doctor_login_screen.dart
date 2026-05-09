import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/app_config.dart';
import '../../../session/application/session_notifier.dart';
import '../../../home/doctor/presentation/doctor_home_screen.dart';

class DoctorLoginScreen extends ConsumerWidget {
  const DoctorLoginScreen({super.key});

  static const routePath = '/doctor/login';
  static const routeName = 'doctorLogin';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: const Text('চিকিৎসক লগইন'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'চিকিৎসক প্রবেশ (ভবিষ্যৎ)',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          Text(
            'ইমেইল ও পাসওয়ার্ড (শীঘ্রই)',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 20),
          TextField(
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'ইমেইল',
              hintText: 'ডাক্তার@উদাহরণ.কম',
            ),
            enabled: false,
          ),
          const SizedBox(height: 12),
          TextField(
            obscureText: true,
            decoration: const InputDecoration(labelText: 'পাসওয়ার্ড'),
            enabled: false,
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () async {
                await ref
                    .read(sessionNotifierProvider.notifier)
                    .setRole(AppRole.doctor);
                if (context.mounted) {
                  context.go(DoctorHomeScreen.routePath);
                }
              },
              child: const Text('চালিয়ে যান (খোলস)'),
            ),
          ),
          const SizedBox(height: 12),
          if (AppConfig.isDevelopmentEnv)
            Text(
              'API (ডিবাগ): ${AppConfig.resolvedApiBaseUrl}',
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: scheme.outline),
            ),
        ],
      ),
    );
  }
}

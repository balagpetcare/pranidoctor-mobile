import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_client.dart';
import '../../../role_selection/presentation/role_selection_screen.dart';
import '../../../session/application/session_notifier.dart';

class DoctorHomeScreen extends ConsumerWidget {
  const DoctorHomeScreen({super.key});

  static const routePath = '/doctor/home';
  static const routeName = 'doctorHome';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final base = ref.watch(apiClientProvider).baseUrl;
    return Scaffold(
      appBar: AppBar(
        title: const Text('চিকিৎসক হোম'),
        actions: [
          TextButton(
            onPressed: () async {
              await ref.read(sessionNotifierProvider.notifier).signOut();
              if (context.mounted) {
                context.go(RoleSelectionScreen.routePath);
              }
            },
            child: const Text('সাইন আউট'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'স্বাগতম',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 6),
          Text(
            'Doctor home (placeholder)',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'API client',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 6),
                  SelectableText(
                    base,
                    style: Theme.of(context).textTheme.bodySmall,
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

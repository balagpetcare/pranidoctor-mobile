import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/network/api_client.dart';
import '../../../auth/login_entry_screen.dart';
import '../../../session/application/session_notifier.dart';
import '../../../knowledge_hub/presentation/knowledge_hub_home_screen.dart';

class DoctorHomeScreen extends ConsumerWidget {
  const DoctorHomeScreen({super.key});

  static const routePath = '/doctor/home';
  static const routeName = 'doctorHome';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final base = AppConfig.isDevelopmentEnv
        ? ref.watch(apiClientProvider).baseUrl
        : null;
    return Scaffold(
      appBar: AppBar(
        title: const Text('চিকিৎসক হোম'),
        actions: [
          TextButton(
            onPressed: () async {
              await ref.read(sessionNotifierProvider.notifier).signOut();
              if (context.mounted) {
                context.go(LoginEntryScreen.routePath);
              }
            },
            child: const Text('সাইন আউট'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('স্বাগতম', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 6),
          Text(
            'চিকিৎসক হোম (খোলস)',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 20),
          Card(
            child: ListTile(
              leading: Icon(Icons.menu_book_outlined, color: scheme.primary),
              title: const Text('জ্ঞানকেন্দ্র'),
              subtitle: const Text(
                'প্রকাশিত নির্দেশনা ও নিবন্ধ — গ্রাহকদের মতোই দেখুন',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(KnowledgeHubHomeScreen.routePath),
            ),
          ),
          if (base != null) ...[
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'API ক্লায়েন্ট (ডিবাগ)',
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
        ],
      ),
    );
  }
}

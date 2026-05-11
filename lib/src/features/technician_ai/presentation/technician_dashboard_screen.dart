import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_config.dart';
import '../../auth/login_entry_screen.dart';
import '../../session/application/pd_customer_logout.dart';
import '../../knowledge_hub/presentation/knowledge_hub_home_screen.dart';
import 'technician_jobs_screen.dart';
import 'technician_requests_screen.dart';
import 'widgets/technician_ai_widgets.dart';

class TechnicianDashboardScreen extends ConsumerWidget {
  const TechnicianDashboardScreen({super.key});

  static const routePath = '/technician/home';
  static const routeName = 'technicianHome';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final hPad = 20.0;
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI টেকনিশিয়ান'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Center(child: TechnicianAiBadge()),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 32),
        children: [
          Text('ড্যাশবোর্ড', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            'কৃত্রিম প্রজনন সেবার নতুন অনুরোধ দেখুন এবং চলমান কাজ পরিচালনা করুন।',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
          ),
          if (AppConfig.useMockTechnicianApi) ...[
            const SizedBox(height: 12),
            Card(
              color: scheme.tertiaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(
                      Icons.science_outlined,
                      color: scheme.onTertiaryContainer,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'মক ডেটা চালু আছে (USE_MOCK_TECHNICIAN_API)',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          Card(
            child: ListTile(
              leading: Icon(
                Icons.mark_email_unread_outlined,
                color: scheme.primary,
              ),
              title: const Text('নতুন অনুরোধ'),
              subtitle: const Text('আপনার জন্য নতুন AI সেবা অনুরোধ'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(TechnicianRequestsScreen.routePath),
            ),
          ),
          const SizedBox(height: 10),
          Card(
            child: ListTile(
              leading: Icon(Icons.work_outline, color: scheme.primary),
              title: const Text('চলমান কাজ'),
              subtitle: const Text('গ্রহণ করা ও চলমান কাজের তালিকা'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(TechnicianJobsScreen.routePath),
            ),
          ),
          const SizedBox(height: 10),
          Card(
            child: ListTile(
              leading: Icon(Icons.menu_book_outlined, color: scheme.primary),
              title: const Text('জ্ঞানকেন্দ্র'),
              subtitle: const Text('টিউটোরিয়াল ও শিক্ষামূলক লেখা'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(KnowledgeHubHomeScreen.routePath),
            ),
          ),
          const SizedBox(height: 28),
          OutlinedButton.icon(
            onPressed: () async {
              await pdPerformCustomerLogout(ref);
              if (context.mounted) {
                context.go(LoginEntryScreen.routePath);
              }
            },
            icon: const Icon(Icons.logout),
            label: const Text('প্রস্থান / লগইন'),
          ),
        ],
      ),
    );
  }
}

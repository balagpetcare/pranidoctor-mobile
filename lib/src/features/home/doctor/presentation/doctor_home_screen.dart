import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/doctor/presentation/doctor_login_screen.dart';
import '../../../auth/login_entry_screen.dart';
import '../../../doctor_workflow/application/doctor_workflow_providers.dart';
import '../../../doctor_workflow/presentation/doctor_cases_screen.dart';
import '../../../doctor_workflow/presentation/doctor_requests_screen.dart';
import '../../../session/application/session_notifier.dart';
import '../../../tutorials/presentation/tutorial_list_screen.dart';
import '../../../doctor_workflow/presentation/widgets/doctor_workflow_badges.dart';

class DoctorHomeScreen extends ConsumerWidget {
  const DoctorHomeScreen({super.key});

  static const routePath = '/doctor/home';
  static const routeName = 'doctorHome';

  static String _asyncLen<T>(AsyncValue<List<T>> async) {
    return async.when(
      data: (l) => '${l.length}',
      loading: () => '…',
      error: (_, _) => '—',
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final incoming = ref.watch(doctorIncomingRequestsProvider);
    final cases = ref.watch(doctorCasesListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('চিকিৎসক ড্যাশবোর্ড'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Center(child: DoctorModeChip()),
          ),
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
          Text(
            'স্বাগতম',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            'নতুন অনুরোধ ও সক্রিয় কেস পরিচালনা করুন।',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 24),
          Card(
            child: ListTile(
              leading: Icon(
                Icons.mark_email_unread_outlined,
                color: scheme.primary,
              ),
              title: const Text('নতুন অনুরোধ'),
              subtitle: Text('সংখ্যা: ${_asyncLen(incoming)}'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(DoctorRequestsScreen.routePath),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: Icon(
                Icons.assignment_turned_in_outlined,
                color: scheme.primary,
              ),
              title: const Text('সক্রিয় কেস'),
              subtitle: Text('সংখ্যা: ${_asyncLen(cases)}'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(DoctorCasesScreen.routePath),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: Icon(Icons.menu_book_outlined, color: scheme.primary),
              title: const Text('নলেজ হাব (টিউটোরিয়াল)'),
              subtitle: const Text('প্রকাশিত নির্দেশনা ও নিবন্ধ'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(TutorialListScreen.routePath),
            ),
          ),
          const SizedBox(height: 20),
          TextButton.icon(
            onPressed: () => context.go(DoctorLoginScreen.routePath),
            icon: const Icon(Icons.swap_horiz_outlined),
            label: const Text('লগইন স্ক্রিনে ফিরুন'),
          ),
        ],
      ),
    );
  }
}

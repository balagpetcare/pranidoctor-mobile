import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../animals/presentation/animals_tab_screen.dart';
import '../auth/login_entry_screen.dart';
import '../notifications/presentation/notifications_list_screen.dart';
import 'package:pranidoctor_mobile/src/features/service_requests/presentation/service_requests_tab_screen.dart';
import '../session/application/session_notifier.dart';
import 'home_screen.dart';

class HomeShellScreen extends ConsumerStatefulWidget {
  const HomeShellScreen({super.key});

  static const routePath = '/home';
  static const routeName = 'homeShell';

  @override
  ConsumerState<HomeShellScreen> createState() => _HomeShellScreenState();
}

class _HomeShellScreenState extends ConsumerState<HomeShellScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: const [
          HomeScreen(),
          ServiceRequestsTabScreen(),
          AnimalsTabScreen(),
          _ProfileTab(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'হোম',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment),
            label: 'অনুরোধ',
          ),
          NavigationDestination(
            icon: Icon(Icons.pets_outlined),
            selectedIcon: Icon(Icons.pets),
            label: 'আমার পশু',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'প্রোফাইল',
          ),
        ],
      ),
    );
  }
}

class _ProfileTab extends ConsumerWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          children: [
            Icon(Icons.person_outline, size: 64, color: scheme.secondary),
            const SizedBox(height: 20),
            Text(
              'প্রোফাইল',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text(
              'অ্যাকাউন্ট ও সেটিংস এখানে থাকবে।',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.notifications_outlined,
                      color: scheme.primary,
                    ),
                    title: const Text('নোটিফিকেশন'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () =>
                        context.push(NotificationsListScreen.routePath),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            const _SignOutButton(),
          ],
        ),
      ),
    );
  }
}

class _SignOutButton extends ConsumerWidget {
  const _SignOutButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FilledButton.tonal(
      onPressed: () async {
        await ref.read(sessionNotifierProvider.notifier).signOut();
        if (context.mounted) {
          context.go(LoginEntryScreen.routePath);
        }
      },
      child: const Text('প্রস্থান / লগইন স্ক্রিনে'),
    );
  }
}

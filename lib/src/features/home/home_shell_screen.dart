import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../auth/login_entry_screen.dart';
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
          _RequestsPlaceholderTab(),
          _MyAnimalsPlaceholderTab(),
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

class _RequestsPlaceholderTab extends StatelessWidget {
  const _RequestsPlaceholderTab();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return _PlaceholderScaffold(
      title: 'অনুরোধ',
      subtitle:
          'জরুরি ডাক বা চিকিৎসা অনুরোধ এখানে দেখাবে। ব্যাকএন্ড সংযোগের পর কাজ শুরু হবে।',
      icon: Icons.assignment_outlined,
      iconColor: scheme.primary,
    );
  }
}

class _MyAnimalsPlaceholderTab extends StatelessWidget {
  const _MyAnimalsPlaceholderTab();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return _PlaceholderScaffold(
      title: 'আমার পশু',
      subtitle: 'প্রাণির তালিকা, ট্যাগ ও স্বাস্থ্য সারাংশ — খুব শীঘ্রই।',
      icon: Icons.pets_outlined,
      iconColor: scheme.tertiary,
    );
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return _PlaceholderScaffold(
      title: 'প্রোফাইল',
      subtitle: 'অ্যাকাউন্ট ও সেটিংস এখানে থাকবে।',
      icon: Icons.person_outline,
      iconColor: scheme.secondary,
      extra: const _SignOutButton(),
    );
  }
}

class _PlaceholderScaffold extends StatelessWidget {
  const _PlaceholderScaffold({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    this.extra,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Widget? extra;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight - 48,
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 64, color: iconColor),
                    const SizedBox(height: 20),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    if (extra != null) ...[const SizedBox(height: 28), extra!],
                  ],
                ),
              ),
            ),
          );
        },
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

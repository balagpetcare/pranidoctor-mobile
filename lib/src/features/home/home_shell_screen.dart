import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../animals/presentation/animals_tab_screen.dart';
import 'application/home_shell_tab_provider.dart';
import 'package:pranidoctor_mobile/src/features/profile/presentation/profile_home_screen.dart';
import 'package:pranidoctor_mobile/src/features/service_requests/presentation/service_requests_tab_screen.dart';
import 'home_screen.dart';

class HomeShellScreen extends ConsumerStatefulWidget {
  const HomeShellScreen({super.key});

  static const routePath = '/home';
  static const routeName = 'homeShell';

  @override
  ConsumerState<HomeShellScreen> createState() => _HomeShellScreenState();
}

class _HomeShellScreenState extends ConsumerState<HomeShellScreen> {
  /// Avoid building every tab on first paint — IndexedStack still lays out all
  /// children, which was forcing four heavy screens to initialize at once.
  final Set<int> _activatedTabs = {0};

  @override
  Widget build(BuildContext context) {
    final index = ref.watch(homeShellTabIndexProvider);
    _activatedTabs.add(index);
    return Scaffold(
      body: IndexedStack(
        index: index,
        children: [
          _activatedTabs.contains(0)
              ? const HomeScreen()
              : const SizedBox.shrink(),
          _activatedTabs.contains(1)
              ? const ServiceRequestsTabScreen()
              : const SizedBox.shrink(),
          _activatedTabs.contains(2)
              ? const AnimalsTabScreen()
              : const SizedBox.shrink(),
          _activatedTabs.contains(3)
              ? const ProfileHomeScreen()
              : const SizedBox.shrink(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) =>
            ref.read(homeShellTabIndexProvider.notifier).select(i),
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


import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../animals/presentation/animals_tab_screen.dart';
import 'application/home_shell_tab_provider.dart';
import 'package:pranidoctor_mobile/src/features/profile/presentation/profile_home_screen.dart';
import 'package:pranidoctor_mobile/src/features/service_requests/presentation/service_requests_tab_screen.dart';
import 'home_screen.dart';

class HomeShellScreen extends ConsumerWidget {
  const HomeShellScreen({super.key});

  static const routePath = '/home';
  static const routeName = 'homeShell';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(homeShellTabIndexProvider);
    return Scaffold(
      body: IndexedStack(
        index: index,
        children: const [
          HomeScreen(),
          ServiceRequestsTabScreen(),
          AnimalsTabScreen(),
          ProfileHomeScreen(),
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

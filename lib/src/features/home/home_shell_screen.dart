import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pranidoctor_mobile/src/features/home/presentation/doctor_tab_screen.dart';
import 'package:pranidoctor_mobile/src/features/notifications/presentation/notifications_list_screen.dart';
import 'package:pranidoctor_mobile/src/features/profile/presentation/profile_home_screen.dart';
import 'package:pranidoctor_mobile/src/features/service_requests/presentation/service_requests_tab_screen.dart';

import 'application/home_shell_tab_provider.dart';
import 'home_screen.dart';

class HomeShellScreen extends ConsumerStatefulWidget {
  const HomeShellScreen({super.key});

  static const routePath = '/home';
  static const routeName = 'homeShell';

  @override
  ConsumerState<HomeShellScreen> createState() => _HomeShellScreenState();
}

class _HomeShellScreenState extends ConsumerState<HomeShellScreen> {
  /// Avoid building every tab on first paint — [IndexedStack] still lays out all
  /// children; defer unvisited tabs until selected once.
  final Set<int> _activatedTabs = {0};

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
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
              ? const DoctorTabScreen()
              : const SizedBox.shrink(),
          _activatedTabs.contains(2)
              ? const ServiceRequestsTabScreen()
              : const SizedBox.shrink(),
          _activatedTabs.contains(3)
              ? const NotificationsListScreen()
              : const SizedBox.shrink(),
          _activatedTabs.contains(4)
              ? const ProfileHomeScreen()
              : const SizedBox.shrink(),
        ],
      ),
      bottomNavigationBar: Material(
        elevation: 6,
        shadowColor: Colors.black.withValues(alpha: 0.12),
        surfaceTintColor: Colors.transparent,
        color: scheme.surface,
        child: SafeArea(
          top: false,
          minimum: const EdgeInsets.only(bottom: 4),
          child: NavigationBar(
            height: 72,
            elevation: 0,
            shadowColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            backgroundColor: scheme.surface,
            indicatorColor: scheme.primaryContainer,
            selectedIndex: index,
            onDestinationSelected: (i) =>
                ref.read(homeShellTabIndexProvider.notifier).select(i),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded),
                label: 'হোম',
              ),
              NavigationDestination(
                icon: Icon(Icons.medical_services_outlined),
                selectedIcon: Icon(Icons.medical_services_rounded),
                label: 'ডাক্তার',
              ),
              NavigationDestination(
                icon: Icon(Icons.grid_view_outlined),
                selectedIcon: Icon(Icons.grid_view_rounded),
                label: 'সেবা',
              ),
              NavigationDestination(
                icon: Icon(Icons.notifications_outlined),
                selectedIcon: Icon(Icons.notifications_rounded),
                label: 'নোটিফিকেশন',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline_rounded),
                selectedIcon: Icon(Icons.person_rounded),
                label: 'প্রোফাইল',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

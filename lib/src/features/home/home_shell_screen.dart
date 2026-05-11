import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pranidoctor_mobile/src/features/auth/application/customer_shell_login_navigation.dart';
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
  Widget _buildTab(int index) {
    switch (index) {
      case 0:
        return const HomeScreen();
      case 1:
        return const DoctorTabScreen();
      case 2:
        return const ServiceRequestsTabScreen();
      case 3:
        return const NotificationsListScreen();
      case 4:
        return const ProfileHomeScreen();
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final index = ref.watch(homeShellTabIndexProvider);
    return Scaffold(
      body: _buildTab(index),
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
            onDestinationSelected: (i) {
              final authed = pdCustomerSessionIsAuthenticated(ref);
              if (!authed && (i == 2 || i == 3 || i == 4)) {
                final tab = switch (i) {
                  2 => 'services',
                  3 => 'notifications',
                  4 => 'profile',
                  _ => null,
                };
                if (tab != null) {
                  pdPushCustomerLoginIntent(context, shellTab: tab);
                }
                return;
              }
              ref.read(homeShellTabIndexProvider.notifier).select(i);
            },
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

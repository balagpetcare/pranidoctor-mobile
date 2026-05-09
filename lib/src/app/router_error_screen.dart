import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/login_entry_screen.dart';
import '../features/home/home_shell_screen.dart';
import '../features/splash/splash_screen.dart';

/// Unknown route / navigation error — Bengali-first fallback.
class RouterErrorScreen extends StatelessWidget {
  const RouterErrorScreen({super.key, required this.state});

  final GoRouterState state;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final loc = state.uri.path;

    return Scaffold(
      appBar: AppBar(title: const Text('প্রবেশ')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.travel_explore_outlined,
                size: 56,
                color: scheme.primary,
              ),
              const SizedBox(height: 20),
              Text(
                'পৃষ্ঠা পাওয়া যায়নি',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                loc,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 28),
              FilledButton(
                onPressed: () => context.go(HomeShellScreen.routePath),
                child: const Text('হোমে যান'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => context.go(LoginEntryScreen.routePath),
                child: const Text('প্রবেশ স্ক্রিন'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => context.go(SplashScreen.routePath),
                child: const Text('আবার শুরু'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

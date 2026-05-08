import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/doctor/presentation/doctor_login_screen.dart';
import '../features/auth/login_entry_screen.dart';
import '../features/home/doctor/presentation/doctor_home_screen.dart';
import '../features/home/home_shell_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/splash/splash_screen.dart';

final _rootKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: SplashScreen.routePath,
    routes: [
      GoRoute(
        path: SplashScreen.routePath,
        name: SplashScreen.routeName,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: OnboardingScreen.routePath,
        name: OnboardingScreen.routeName,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: LoginEntryScreen.routePath,
        name: LoginEntryScreen.routeName,
        builder: (context, state) => const LoginEntryScreen(),
      ),
      GoRoute(
        path: HomeShellScreen.routePath,
        name: HomeShellScreen.routeName,
        builder: (context, state) => const HomeShellScreen(),
      ),
      GoRoute(
        path: DoctorLoginScreen.routePath,
        name: DoctorLoginScreen.routeName,
        builder: (context, state) => const DoctorLoginScreen(),
      ),
      GoRoute(
        path: DoctorHomeScreen.routePath,
        name: DoctorHomeScreen.routeName,
        builder: (context, state) => const DoctorHomeScreen(),
      ),
    ],
  );
});

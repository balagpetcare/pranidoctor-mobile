import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/customer/presentation/customer_login_screen.dart';
import '../features/auth/doctor/presentation/doctor_login_screen.dart';
import '../features/home/customer/presentation/customer_home_screen.dart';
import '../features/home/doctor/presentation/doctor_home_screen.dart';
import '../features/role_selection/presentation/role_selection_screen.dart';
import '../features/splash/presentation/splash_screen.dart';

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
        path: RoleSelectionScreen.routePath,
        name: RoleSelectionScreen.routeName,
        builder: (context, state) => const RoleSelectionScreen(),
      ),
      GoRoute(
        path: CustomerLoginScreen.routePath,
        name: CustomerLoginScreen.routeName,
        builder: (context, state) => const CustomerLoginScreen(),
      ),
      GoRoute(
        path: DoctorLoginScreen.routePath,
        name: DoctorLoginScreen.routeName,
        builder: (context, state) => const DoctorLoginScreen(),
      ),
      GoRoute(
        path: CustomerHomeScreen.routePath,
        name: CustomerHomeScreen.routeName,
        builder: (context, state) => const CustomerHomeScreen(),
      ),
      GoRoute(
        path: DoctorHomeScreen.routePath,
        name: DoctorHomeScreen.routeName,
        builder: (context, state) => const DoctorHomeScreen(),
      ),
    ],
  );
});

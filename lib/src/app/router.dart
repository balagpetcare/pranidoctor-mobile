import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'navigation_keys.dart';
import 'router_error_screen.dart';
import '../features/auth/doctor/presentation/doctor_login_screen.dart';
import '../features/auth/login_entry_screen.dart';
import '../features/auth/otp_verify_screen.dart';
import '../features/home/doctor/presentation/doctor_home_screen.dart';
import '../features/home/home_shell_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/providers/presentation/doctor_detail_screen.dart';
import '../features/providers/presentation/doctor_list_screen.dart';
import '../features/providers/presentation/provider_finder_landing_screen.dart';
import '../features/providers/presentation/technician_detail_screen.dart';
import '../features/providers/presentation/technician_list_screen.dart';
import '../features/service_requests/data/service_request_model.dart';
import '../features/service_requests/presentation/booking_success_screen.dart';
import '../features/service_requests/presentation/booking_wizard_screen.dart';
import '../features/service_requests/presentation/service_request_detail_screen.dart';
import '../features/service_requests/presentation/service_requests_list_screen.dart';
import '../features/splash/splash_screen.dart';
import '../features/tutorials/presentation/tutorial_detail_screen.dart';
import '../features/tutorials/presentation/tutorial_list_screen.dart';
import '../features/notifications/presentation/notifications_list_screen.dart';
import '../features/session/application/session_notifier.dart';

bool _isPublicCustomerPath(String path) {
  return path == SplashScreen.routePath ||
      path == OnboardingScreen.routePath ||
      path == LoginEntryScreen.routePath ||
      path ==
          '${LoginEntryScreen.routePath}/${OtpVerifyScreen.routePathSegment}';
}

class _OtpRouteExtra {
  _OtpRouteExtra({required this.phone, this.ttl});

  final String phone;
  final int? ttl;
}

_OtpRouteExtra _otpExtraFrom(GoRouterState state) {
  final ex = state.extra;
  if (ex is String && ex.isNotEmpty) {
    return _OtpRouteExtra(phone: ex, ttl: null);
  }
  if (ex is Map) {
    final p = ex['phone'];
    final t = ex['ttl'];
    if (p is String && p.isNotEmpty) {
      int? ttl;
      if (t is int) ttl = t;
      if (t is num) ttl = t.toInt();
      return _OtpRouteExtra(phone: p, ttl: ttl);
    }
  }
  final q = state.uri.queryParameters['phone'];
  if (q != null && q.isNotEmpty) {
    return _OtpRouteExtra(phone: Uri.decodeComponent(q), ttl: null);
  }
  return _OtpRouteExtra(phone: '');
}

final goRouterProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);
  ref.listen(sessionNotifierProvider, (_, _) => refresh.value++);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    navigatorKey: pdRootNavigatorKey,
    initialLocation: SplashScreen.routePath,
    refreshListenable: refresh,
    errorBuilder: (context, state) => RouterErrorScreen(state: state),
    redirect: (context, state) {
      final loc = state.uri.path;
      final auth = ref.read(sessionNotifierProvider);

      if (auth.isAuthenticated &&
          (loc == LoginEntryScreen.routePath ||
              loc.startsWith('${LoginEntryScreen.routePath}/'))) {
        return HomeShellScreen.routePath;
      }

      if (loc ==
          '${LoginEntryScreen.routePath}/${OtpVerifyScreen.routePathSegment}') {
        if (_otpExtraFrom(state).phone.isEmpty) {
          return LoginEntryScreen.routePath;
        }
      }

      if (_isPublicCustomerPath(loc)) return null;
      if (loc.startsWith('/doctor')) return null;
      if (!auth.isAuthenticated) return LoginEntryScreen.routePath;
      return null;
    },
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
        routes: [
          GoRoute(
            path: OtpVerifyScreen.routePathSegment,
            name: OtpVerifyScreen.routeName,
            builder: (context, state) {
              final e = _otpExtraFrom(state);
              return OtpVerifyScreen(
                apiPhone: e.phone,
                resendCooldownSeconds: e.ttl,
              );
            },
          ),
        ],
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
      GoRoute(
        path: ProviderFinderLandingScreen.routePath,
        name: ProviderFinderLandingScreen.routeName,
        builder: (context, state) => const ProviderFinderLandingScreen(),
      ),
      GoRoute(
        path: DoctorListScreen.routePath,
        name: DoctorListScreen.routeName,
        builder: (context, state) => const DoctorListScreen(),
        routes: [
          GoRoute(
            path: ':doctorId',
            name: DoctorDetailScreen.routeName,
            builder: (context, state) {
              final id = state.pathParameters['doctorId']!;
              return DoctorDetailScreen(doctorId: id);
            },
          ),
        ],
      ),
      GoRoute(
        path: TechnicianListScreen.routePath,
        name: TechnicianListScreen.routeName,
        builder: (context, state) => const TechnicianListScreen(),
        routes: [
          GoRoute(
            path: ':technicianId',
            name: TechnicianDetailScreen.routeName,
            builder: (context, state) {
              final id = state.pathParameters['technicianId']!;
              return TechnicianDetailScreen(technicianId: id);
            },
          ),
        ],
      ),
      GoRoute(
        path: NotificationsListScreen.routePath,
        name: NotificationsListScreen.routeName,
        builder: (context, state) => const NotificationsListScreen(),
      ),
      GoRoute(
        path: TutorialListScreen.routePath,
        name: TutorialListScreen.routeName,
        builder: (context, state) => const TutorialListScreen(),
        routes: [
          GoRoute(
            path: ':slugOrId',
            name: TutorialDetailScreen.routeName,
            builder: (context, state) {
              final raw = state.pathParameters['slugOrId']!;
              return TutorialDetailScreen(slugOrId: raw);
            },
          ),
        ],
      ),
      GoRoute(
        path: BookingWizardScreen.routePath,
        name: BookingWizardScreen.routeName,
        builder: (context, state) {
          ServiceRequestType? preset;
          final raw = state.uri.queryParameters['preset'];
          if (raw != null && raw.isNotEmpty) {
            try {
              preset = ServiceRequestType.values.byName(raw);
            } catch (_) {
              preset = null;
            }
          }
          return BookingWizardScreen(initialServiceType: preset);
        },
      ),
      GoRoute(
        path: BookingSuccessScreen.routePath,
        name: BookingSuccessScreen.routeName,
        builder: (context, state) {
          final extra = state.extra;
          if (extra is ServiceRequest) {
            return BookingSuccessScreen(request: extra);
          }
          return Scaffold(
            appBar: AppBar(title: const Text('ত্রুটি')),
            body: const Center(
              child: Text('কোনো অনুরোধের তথ্য নেই। হোম থেকে আবার চেষ্টা করুন।'),
            ),
          );
        },
      ),
      GoRoute(
        path: ServiceRequestsListScreen.routePath,
        name: ServiceRequestsListScreen.routeName,
        builder: (context, state) => const ServiceRequestsListScreen(),
      ),
      GoRoute(
        path: '/service-requests/:requestId',
        name: ServiceRequestDetailScreen.routeName,
        builder: (context, state) {
          final id = state.pathParameters['requestId']!;
          return ServiceRequestDetailScreen(requestId: id);
        },
      ),
    ],
  );
});

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/navigation_keys.dart';
import '../../features/auth/login_entry_screen.dart';
import '../../features/home/home_shell_screen.dart';
import '../../features/session/application/pd_customer_logout.dart';
import '../../features/session/application/session_notifier.dart';
import '../config/app_config.dart';
import '../storage/token_storage.dart';

/// Shared [Dio] instance with base URL and JSON defaults.
final dioProvider = Provider<Dio>((ref) {
  // [dioProvider] can dispose while requests still run (nothing keeps this
  // provider alive once repository/apiClient listeners drop). Interceptors
  // must not touch this [Ref] after an async gap — use [ProviderContainer] and
  // captured services instead.
  final container = ref.container;
  final tokenStorage = ref.read(tokenStorageProvider);

  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.resolvedApiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
      headers: {
        Headers.acceptHeader: 'application/json',
        Headers.contentTypeHeader: 'application/json',
      },
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await tokenStorage.readAccessToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (DioException e, handler) async {
        final path = e.requestOptions.path;
        final isPublicMobileCustomerAuth =
            path.contains('/api/mobile/auth/otp/') ||
            path.contains('/api/mobile/auth/send-otp') ||
            path.contains('/api/mobile/auth/verify-otp') ||
            path.contains('/api/mobile/auth/register') ||
            path.contains('/api/mobile/auth/login');
        final code = e.response?.statusCode;
        // Only invalid/expired credentials clear the session — 403 is used for
        // role-scoped or business-rule denials that must not wipe login.
        final unauthorized = code == 401 && !isPublicMobileCustomerAuth;
        if (unauthorized) {
          final wasAuthed = container
              .read(sessionNotifierProvider)
              .isAuthenticated;
          if (wasAuthed) {
            try {
              await pdPerformCustomerLogout(container);
            } catch (e, st) {
              assert(() {
                debugPrint(
                  '[PraniDoctor][dio] pdPerformCustomerLogout failed: $e\n$st',
                );
                return true;
              }());
            }
            final ctx = pdRootNavigatorKey.currentContext;
            if (ctx != null && ctx.mounted) {
              final loc = GoRouterState.of(ctx).uri.path;
              if (loc != LoginEntryScreen.routePath) {
                ctx.go(HomeShellScreen.routePath);
              }
              SchedulerBinding.instance.addPostFrameCallback((_) {
                final m = pdRootNavigatorKey.currentContext;
                if (m != null && m.mounted) {
                  ScaffoldMessenger.maybeOf(m)?.showSnackBar(
                    const SnackBar(
                      behavior: SnackBarBehavior.floating,
                      content: Text('সেশন শেষ হয়েছে, আবার লগইন করুন'),
                    ),
                  );
                }
              });
            }
          }
        }
        handler.next(e);
      },
    ),
  );

  ref.onDispose(dio.close);
  return dio;
});

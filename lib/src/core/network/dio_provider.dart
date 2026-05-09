import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/navigation_keys.dart';
import '../../features/auth/login_entry_screen.dart';
import '../../features/session/application/session_notifier.dart';
import '../config/app_config.dart';
import '../storage/token_storage.dart';

/// Shared [Dio] instance with base URL and JSON defaults.
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
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
        final token = await ref.read(tokenStorageProvider).readAccessToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (DioException e, handler) async {
        if (e.response?.statusCode == 401) {
          await ref.read(sessionNotifierProvider.notifier).signOut();
          final ctx = pdRootNavigatorKey.currentContext;
          if (ctx != null && ctx.mounted) {
            ctx.go(LoginEntryScreen.routePath);
          }
        }
        handler.next(e);
      },
    ),
  );

  ref.onDispose(dio.close);
  return dio;
});

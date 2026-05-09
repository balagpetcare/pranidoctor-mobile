import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pranidoctor_mobile/src/app/app.dart';
import 'package:pranidoctor_mobile/src/core/config/app_config.dart';

void main() {
  runZonedGuarded(
    () {
      WidgetsFlutterBinding.ensureInitialized();

      if (AppConfig.isDevelopmentEnv) {
        debugPrint(
          '[PraniDoctor] API_BASE_URL=${AppConfig.resolvedApiBaseUrl} APP_ENV=${AppConfig.appEnv}',
        );
      }

      FlutterError.onError = (FlutterErrorDetails details) {
        FlutterError.presentError(details);
        debugPrint('FlutterError: ${details.exceptionAsString()}');
        debugPrintStack(stackTrace: details.stack);
      };

      PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
        debugPrint('PlatformDispatcher.onError: $error');
        debugPrintStack(stackTrace: stack);
        return true;
      };

      runApp(const ProviderScope(child: PraniDoctorApp()));
    },
    (Object error, StackTrace stack) {
      debugPrint('Uncaught zone error: $error');
      debugPrintStack(stackTrace: stack);
      runApp(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          locale: const Locale('bn', 'BD'),
          supportedLocales: const [Locale('bn', 'BD'), Locale('en', 'US')],
          home: Scaffold(
            body: SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    kDebugMode
                        ? 'চালু করতে সমস্যা হয়েছে। অ্যাপটি আবার খুলুন।\n\n$error'
                        : 'চালু করতে সমস্যা হয়েছে। অ্যাপটি আবার খুলুন।',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, height: 1.35),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

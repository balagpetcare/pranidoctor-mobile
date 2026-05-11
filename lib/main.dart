import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pranidoctor_mobile/src/app/app.dart';
import 'package:pranidoctor_mobile/src/core/config/app_config.dart';

void main() {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      if (kDebugMode || AppConfig.isDevelopmentEnv) {
        debugPrint(
          '[PraniDoctor] resolvedApiBaseUrl=${AppConfig.resolvedApiBaseUrl} '
          'APP_ENV=${AppConfig.appEnv} ENABLE_DEV_OTP=${AppConfig.enableDevOtp}',
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
      // Do not call [runApp] here: bindings were initialized in the guarded
      // body; a second [runApp] from this handler triggers Flutter's
      // "Zone mismatch" (ensureInitialized vs runApp zones).
    },
  );
}

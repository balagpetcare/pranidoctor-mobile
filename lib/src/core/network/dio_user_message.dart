import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:pranidoctor_mobile/src/core/config/app_config.dart';

import 'dio_connectivity.dart';
import 'network_messages.dart';

/// Converts [DioException] to **safe Bengali** copy for SnackBars/dialogs.
///
/// Never surfaces [DioException.message] (often English status boilerplate).
String userFacingDioMessageBn(DioException e, {String? debugLabel}) {
  if (kDebugMode || AppConfig.isDevelopmentEnv) {
    final code = e.response?.statusCode;
    final path = e.requestOptions.uri.path;
    debugPrint(
      '[Dio${debugLabel != null ? ':$debugLabel' : ''}] '
      'type=${e.type} status=$code path=$path',
    );
  }

  if (e.type == DioExceptionType.connectionTimeout ||
      e.type == DioExceptionType.sendTimeout ||
      e.type == DioExceptionType.receiveTimeout) {
    return NetworkMessages.bnConnectionTimeout;
  }

  if (isDioConnectionUnreachable(e)) {
    return NetworkMessages.bnServerUnreachable;
  }

  final status = e.response?.statusCode;
  if (status != null) {
    if (status == 404) {
      return NetworkMessages.bnEndpointNotFound;
    }
    if (status >= 500) {
      return NetworkMessages.bnServerError;
    }
    if (status == 401 || status == 403) {
      return 'প্রবেশের অনুমতি নেই বা সেশন শেষ হয়েছে। আবার লগইন করুন।';
    }
    if (status == 429) {
      return 'অনুরোধ খুব দ্রুত। কিছুক্ষণ পরে আবার চেষ্টা করুন।';
    }
  }

  return NetworkMessages.bnGenericRequestFailed;
}

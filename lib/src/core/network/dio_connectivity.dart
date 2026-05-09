import 'package:dio/dio.dart';

import 'network_messages.dart';

/// True when [e] indicates no usable HTTP response (offline, timeout, TLS, etc.).
bool isDioConnectionUnreachable(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.connectionError:
    case DioExceptionType.badCertificate:
    case DioExceptionType.cancel:
      return true;
    case DioExceptionType.badResponse:
      return false;
    case DioExceptionType.unknown:
      return e.response == null;
  }
}

/// Short fallback when there is a [DioException] but no JSON error envelope.
String bnUserFacingDioNetworkMessage(DioException e) {
  if (isDioConnectionUnreachable(e)) {
    return NetworkMessages.bnServerUnreachable;
  }
  final m = e.message;
  if (m != null && m.isNotEmpty) return m;
  return 'সংযোগ ত্রুটি';
}

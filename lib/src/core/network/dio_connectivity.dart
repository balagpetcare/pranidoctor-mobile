import 'package:dio/dio.dart';

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

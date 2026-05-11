import 'package:dio/dio.dart';

import 'package:pranidoctor_mobile/src/core/network/dio_connectivity.dart';

/// Bengali copy for customer OTP [DioException]s (HTTP layer).
/// Prefer status-based messages for predictable UX.
String userFacingOtpDioMessageBn(DioException e) {
  if (e.type == DioExceptionType.connectionTimeout ||
      e.type == DioExceptionType.sendTimeout ||
      e.type == DioExceptionType.receiveTimeout) {
    return 'ইন্টারনেট সংযোগ পরীক্ষা করুন';
  }
  if (isDioConnectionUnreachable(e)) {
    return 'ইন্টারনেট সংযোগ পরীক্ষা করুন';
  }

  final status = e.response?.statusCode;
  if (status != null) {
    if (status == 400 || status == 422) {
      return 'তথ্য সঠিকভাবে দিন';
    }
    if (status == 401) {
      return 'OTP সঠিক নয় বা মেয়াদ শেষ হয়েছে';
    }
    if (status == 403) {
      return 'এই নম্বর দিয়ে এখন প্রবেশ করা যাচ্ছে না';
    }
    if (status == 429) {
      return 'অনুরোধ খুব দ্রুত। কিছুক্ষণ পরে আবার চেষ্টা করুন।';
    }
    if (status >= 500) {
      return 'আবার চেষ্টা করুন';
    }
  }

  return 'আবার চেষ্টা করুন';
}

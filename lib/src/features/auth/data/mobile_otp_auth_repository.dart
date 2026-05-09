import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_provider.dart';

final mobileOtpAuthRepositoryProvider = Provider<MobileOtpAuthRepository>((
  ref,
) {
  return MobileOtpAuthRepository(ref.watch(dioProvider));
});

class OtpAuthException implements Exception {
  OtpAuthException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Result of OTP start; [otpTtlSeconds] may be absent if the server omits it.
class OtpStartResult {
  const OtpStartResult({this.otpTtlSeconds});

  final int? otpTtlSeconds;
}

class MobileOtpAuthRepository {
  MobileOtpAuthRepository(this._dio);

  final Dio _dio;

  static const _pathStart = '/api/mobile/auth/otp/start';
  static const _pathVerify = '/api/mobile/auth/otp/verify';

  /// Sends OTP to [apiPhone] — must be `8801XXXXXXXXX` (see [BdPhone]).
  Future<OtpStartResult> startOtp(String apiPhone) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        _pathStart,
        data: <String, dynamic>{'phone': apiPhone},
      );
      final body = res.data;
      _ensureOk(body);
      final data = body?['data'];
      int? ttl;
      if (data is Map) {
        final raw = data['otpTtlSeconds'];
        if (raw is int) ttl = raw;
        if (raw is num) ttl = raw.toInt();
      }
      return OtpStartResult(otpTtlSeconds: ttl);
    } on DioException catch (e) {
      throw OtpAuthException(_messageFromDio(e));
    }
  }

  /// Verifies OTP. HTTP body uses **`code`** (many backends use this key). Some
  /// docs refer to the same value as `otp`; servers that require `otp` must align separately.
  Future<String> verifyOtp(String apiPhone, String otpDigits) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        _pathVerify,
        data: <String, dynamic>{'phone': apiPhone, 'code': otpDigits},
      );
      final body = res.data;
      _ensureOk(body);
      final token = parseAccessTokenFromVerifyBody(body);
      if (token != null && token.isNotEmpty) return token;
      throw OtpAuthException('সার্ভার থেকে টোকেন পাওয়া যায়নি।');
    } on DioException catch (e) {
      throw OtpAuthException(_messageFromDio(e));
    }
  }

  void _ensureOk(Map<String, dynamic>? body) {
    if (body == null || body['ok'] != false) return;
    final err = body['error'];
    if (err is Map && err['message'] is String) {
      throw OtpAuthException(err['message'] as String);
    }
    throw OtpAuthException('অনুরোধ ব্যর্থ হয়েছে।');
  }

  String _messageFromDio(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['error'] is Map) {
      final msg = (data['error'] as Map)['message'];
      if (msg is String && msg.isNotEmpty) return msg;
    }
    return 'নেটওয়ার্ক ত্রুটি। আবার চেষ্টা করুন।';
  }
}

/// Extracts JWT/access token from verify responses across common shapes:
/// `{ token }`, `{ accessToken }`, `{ data: { token } }`, `{ data: { accessToken } }`.
String? parseAccessTokenFromVerifyBody(Map<String, dynamic>? body) {
  if (body == null) return null;

  final topToken = body['accessToken'] ?? body['token'];
  if (topToken is String && topToken.isNotEmpty) return topToken;

  final data = body['data'];
  if (data is Map) {
    final m = Map<String, dynamic>.from(data);
    final inner = m['accessToken'] ?? m['token'];
    if (inner is String && inner.isNotEmpty) return inner;
  }
  return null;
}

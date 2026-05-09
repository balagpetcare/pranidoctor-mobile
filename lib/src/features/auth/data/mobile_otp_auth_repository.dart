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

class MobileOtpAuthRepository {
  MobileOtpAuthRepository(this._dio);

  final Dio _dio;

  Future<void> requestOtp(String phone) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        '/api/mobile/auth/otp/request',
        data: <String, dynamic>{'phone': phone},
      );
      _ensureOk(res.data);
    } on DioException catch (e) {
      throw OtpAuthException(_messageFromDio(e));
    }
  }

  Future<String> verifyOtp(String phone, String code) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        '/api/mobile/auth/otp/verify',
        data: <String, dynamic>{'phone': phone, 'code': code},
      );
      _ensureOk(res.data);
      final data = res.data?['data'];
      if (data is! Map<String, dynamic>) {
        throw OtpAuthException('সার্ভার থেকে টোকেন পাওয়া যায়নি।');
      }
      final token = data['accessToken'];
      if (token is! String || token.isEmpty) {
        throw OtpAuthException('সার্ভার থেকে টোকেন পাওয়া যায়নি।');
      }
      return token;
    } on DioException catch (e) {
      throw OtpAuthException(_messageFromDio(e));
    }
  }

  void _ensureOk(Map<String, dynamic>? body) {
    if (body == null || body['ok'] == true) return;
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

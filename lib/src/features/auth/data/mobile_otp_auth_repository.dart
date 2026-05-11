import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/network/dio_connectivity.dart';
import '../../../core/network/dio_provider.dart';
import 'otp_auth_user_messages.dart';

final mobileOtpAuthRepositoryProvider = Provider<MobileOtpAuthRepository>((
  ref,
) {
  return MobileOtpAuthRepository(ref.watch(dioProvider));
});

/// How the OTP send step completed (SMS API vs dev terminal fallback).
enum OtpSendChannel { smsApi, devTerminalFallback }

class OtpAuthException implements Exception {
  OtpAuthException(this.message);
  final String message;

  @override
  String toString() => message;
}

class MobileOtpAuthRepository {
  MobileOtpAuthRepository(this._dio);

  final Dio _dio;

  Future<OtpSendChannel> requestOtp(String phone) async {
    if (!AppConfig.useDevOtpFallback) {
      try {
        await _postRequestOtp(phone);
      } on DioException catch (e) {
        throw OtpAuthException(_messageFromDio(e));
      }
      return OtpSendChannel.smsApi;
    }
    try {
      await _postRequestOtp(phone);
      return OtpSendChannel.smsApi;
    } on DioException catch (e) {
      if (isDioConnectionUnreachable(e)) {
        debugPrint(
          '[PraniDoctor][DEV OTP] API unreachable; dev OTP fallback (OTP not logged).',
        );
        return OtpSendChannel.devTerminalFallback;
      }
      throw OtpAuthException(_messageFromDio(e));
    }
  }

  Future<void> _postRequestOtp(String phone) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/mobile/auth/otp/request',
      data: <String, dynamic>{'phone': phone},
    );
    _ensureOk(res.data);
  }

  Future<String> verifyOtp(String phone, String code) async {
    final trimmed = code.trim();
    if (AppConfig.useDevOtpFallback && trimmed == AppConfig.devOtpCode) {
      try {
        return await _postVerifyOtp(phone, trimmed);
      } on DioException catch (e) {
        if (isDioConnectionUnreachable(e)) {
          return AppConfig.devCustomerAccessToken;
        }
        throw OtpAuthException(_messageFromDio(e));
      }
    }
    try {
      return await _postVerifyOtp(phone, trimmed);
    } on DioException catch (e) {
      throw OtpAuthException(_messageFromDio(e));
    }
  }

  Future<String> _postVerifyOtp(String phone, String code) async {
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
    final status = e.response?.statusCode;
    if (status == 400 || status == 422 || status == 401 || status == 403) {
      return userFacingOtpDioMessageBn(e);
    }
    final data = e.response?.data;
    if (data is Map && data['error'] is Map) {
      final msg = (data['error'] as Map)['message'];
      if (msg is String && msg.isNotEmpty) {
        if (status == 429 || (status != null && status >= 500)) {
          return userFacingOtpDioMessageBn(e);
        }
        return msg;
      }
    }
    return userFacingOtpDioMessageBn(e);
  }
}

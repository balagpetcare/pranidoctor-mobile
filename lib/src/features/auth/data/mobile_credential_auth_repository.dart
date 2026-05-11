import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_connectivity.dart';
import '../../../core/network/dio_provider.dart';

final mobileCredentialAuthRepositoryProvider =
    Provider<MobileCredentialAuthRepository>((ref) {
      return MobileCredentialAuthRepository(ref.watch(dioProvider));
    });

/// POST `/api/mobile/auth/register` and `/api/mobile/auth/login` (same `ok`/`data` envelope as OTP).
class CredentialAuthException implements Exception {
  CredentialAuthException(this.message);
  final String message;

  @override
  String toString() => message;
}

class MobileCredentialAuthRepository {
  MobileCredentialAuthRepository(this._dio);

  final Dio _dio;

  /// Returns access token (same JWT as OTP flow).
  Future<String> register({
    required String name,
    required String mobile,
    String? email,
    required String password,
  }) async {
    try {
      final body = <String, dynamic>{
        'name': name.trim(),
        'mobile': mobile,
        'password': password,
      };
      final e = email?.trim();
      if (e != null && e.isNotEmpty) {
        body['email'] = e;
      }
      final res = await _dio.post<Map<String, dynamic>>(
        '/api/mobile/auth/register',
        data: body,
      );
      return _readAccessToken(res.data);
    } on DioException catch (e) {
      throw CredentialAuthException(_messageFromDio(e));
    }
  }

  Future<String> loginWithPassword({
    required String identifier,
    required String password,
  }) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        '/api/mobile/auth/login',
        data: <String, dynamic>{
          'identifier': identifier.trim(),
          'password': password,
        },
      );
      return _readAccessToken(res.data);
    } on DioException catch (e) {
      throw CredentialAuthException(_messageFromDio(e));
    }
  }

  String _readAccessToken(Map<String, dynamic>? body) {
    _ensureOk(body);
    final data = body?['data'];
    if (data is! Map<String, dynamic>) {
      throw CredentialAuthException('সার্ভার থেকে টোকেন পাওয়া যায়নি।');
    }
    final token = data['accessToken'];
    if (token is! String || token.isEmpty) {
      throw CredentialAuthException('সার্ভার থেকে টোকেন পাওয়া যায়নি।');
    }
    return token;
  }

  void _ensureOk(Map<String, dynamic>? body) {
    if (body == null || body['ok'] == true) return;
    final err = body['error'];
    if (err is Map && err['message'] is String) {
      throw CredentialAuthException(err['message'] as String);
    }
    throw CredentialAuthException('অনুরোধ ব্যর্থ হয়েছে।');
  }

  String _messageFromDio(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['error'] is Map) {
      final msg = (data['error'] as Map)['message'];
      if (msg is String && msg.isNotEmpty) {
        return msg;
      }
    }
    if (isDioConnectionUnreachable(e) ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'ইন্টারনেট সংযোগ পরীক্ষা করুন';
    }
    final status = e.response?.statusCode;
    if (status == 422) {
      return 'তথ্য সঠিকভাবে দিন';
    }
    if (status == 429) {
      return 'অনুরোধ খুব দ্রুত। কিছুক্ষণ পরে আবার চেষ্টা করুন।';
    }
    if (status != null && status >= 500) {
      return 'সার্ভারে সমস্যা হয়েছে। আবার চেষ্টা করুন।';
    }
    return 'আবার চেষ্টা করুন';
  }
}

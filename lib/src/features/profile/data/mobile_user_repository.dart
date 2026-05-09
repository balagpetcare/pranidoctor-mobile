import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:pranidoctor_mobile/src/core/network/api_client.dart';
import 'package:pranidoctor_mobile/src/core/network/dio_connectivity.dart';
import 'package:pranidoctor_mobile/src/features/profile/data/mobile_user_model.dart';
import 'package:pranidoctor_mobile/src/features/profile/data/profile_api_exception.dart';

abstract class MobileUserRepository {
  Future<MobileUser> fetchMe();

  Future<MobileUser> patchMe(MobileUserPatch patch);
}

class MobileUserRepositoryLive implements MobileUserRepository {
  MobileUserRepositoryLive(this._client);

  final ApiClient _client;

  static const String _path = '/api/mobile/me';

  Map<String, dynamic> _unwrap(Response<dynamic> response) {
    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw ProfileApiException('অপ্রত্যাশিত উত্তর');
    }
    if (data['ok'] != true) {
      final err = data['error'];
      final msg = err is Map && err['message'] is String
          ? err['message'] as String
          : 'অনুরোধ ব্যর্থ হয়েছে';
      final code = err is Map && err['code'] is String
          ? err['code'] as String
          : null;
      throw ProfileApiException(msg, code: code);
    }
    final inner = data['data'];
    if (inner is! Map<String, dynamic>) {
      throw ProfileApiException('অপ্রত্যাশিত উত্তর');
    }
    return inner;
  }

  @override
  Future<MobileUser> fetchMe() async {
    try {
      final res = await _client.get<dynamic>(_path);
      final inner = _unwrap(res);
      return MobileUser.fromJson(inner);
    } on DioException catch (e, st) {
      assert(() {
        debugPrint('MobileUserRepository.fetchMe DioException: $e\n$st');
        return true;
      }());
      final code = e.response?.statusCode;
      if (code == 404) {
        return MobileUser.guestFallback(
          MobileProfileLoadStatus.fallbackEndpointMissing,
        );
      }
      return MobileUser.guestFallback(
        MobileProfileLoadStatus.fallbackUnavailable,
      );
    } on ProfileApiException catch (e, st) {
      assert(() {
        debugPrint('MobileUserRepository.fetchMe ProfileApiException: $e\n$st');
        return true;
      }());
      return MobileUser.guestFallback(
        MobileProfileLoadStatus.fallbackUnavailable,
      );
    }
  }

  @override
  Future<MobileUser> patchMe(MobileUserPatch patch) async {
    if (patch.isEmpty) {
      throw ProfileApiException('কোনো পরিবর্তন নেই।');
    }
    try {
      final res = await _client.patch<dynamic>(_path, data: patch.toJson());
      _unwrap(res);
      return fetchMe();
    } on DioException catch (e) {
      throw _mapDio(e);
    } on ProfileApiException {
      rethrow;
    }
  }

  ProfileApiException _mapDio(DioException e) {
    if (e.response?.data is Map<String, dynamic>) {
      final data = e.response!.data as Map<String, dynamic>;
      if (data['ok'] == false && data['error'] is Map) {
        final err = data['error'] as Map;
        final rawMsg = err['message'] is String
            ? err['message'] as String
            : 'নেটওয়ার্ক ত্রুটি';
        final code = err['code'] is String ? err['code'] as String : null;
        assert(() {
          debugPrint(
            'MobileUserRepository PATCH error: code=$code raw="$rawMsg" '
            'details=${err['details']}',
          );
          return true;
        }());
        return ProfileApiException(
          _patchMessageBn(code: code, rawEnglish: rawMsg),
          code: code,
        );
      }
    }
    final code = e.response?.statusCode;
    if (code == 401) {
      return ProfileApiException(
        'লগইন প্রয়োজন বা সেশন শেষ',
        code: 'UNAUTHORIZED',
      );
    }
    if (code == 403) {
      return ProfileApiException('অনুমতি নেই', code: 'FORBIDDEN');
    }
    if (code == 404) {
      return ProfileApiException(
        'প্রোফাইল সেবা এখনো সক্রিয় নয় বা খুঁজে পাওয়া যায়নি',
        code: 'NOT_FOUND',
      );
    }
    return ProfileApiException(bnUserFacingDioNetworkMessage(e), code: 'NETWORK');
  }

  /// Customer-facing Bengali; detailed validation stays in debug logs only.
  static String _patchMessageBn({
    required String? code,
    required String rawEnglish,
  }) {
    switch (code) {
      case 'VALIDATION_ERROR':
        return 'তথ্য গ্রহণযোগ্য নয়। নাম, ইমেইল ও এলাকা পরীক্ষা করুন।';
      case 'EMAIL_IN_USE':
        return 'এই ইমেইলটি ইতিমধ্যে অন্য অ্যাকাউন্টে ব্যবহৃত। অন্য ইমেইল দিন।';
      case 'NOT_FOUND':
        return 'গ্রাহক প্রোফাইল খুঁজে পাওয়া যায়নি। আবার লগইন করে চেষ্টা করুন।';
      case 'UNAUTHORIZED':
        return 'লগইন প্রয়োজন বা সেশন শেষ। আবার প্রবেশ করুন।';
      case 'DATABASE_ERROR':
        return 'সংরক্ষণ করা যায়নি। পরে আবার চেষ্টা করুন।';
      default:
        break;
    }
    final lower = rawEnglish.toLowerCase();
    if (lower.contains('invalid body') ||
        lower.contains('validation') ||
        lower.contains('invalid')) {
      return 'সংরক্ষিত তথ্য গ্রহণযোগ্য নয়। ইমেইল ফর্ম্যাট ও নাম পরীক্ষা করুন।';
    }
    if (lower.contains('email') && lower.contains('registered')) {
      return 'এই ইমেইলটি ইতিমধ্যে নিবন্ধিত।';
    }
    return 'পরিবর্তন সংরক্ষণ করা যায়নি। আবার চেষ্টা করুন।';
  }
}

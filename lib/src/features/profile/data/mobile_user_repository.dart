import 'package:dio/dio.dart';

import 'package:pranidoctor_mobile/src/core/network/api_client.dart';
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
    } on DioException catch (e) {
      throw _mapDio(e);
    } on ProfileApiException {
      rethrow;
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
        final msg = err['message'] is String
            ? err['message'] as String
            : 'নেটওয়ার্ক ত্রুটি';
        final code = err['code'] is String ? err['code'] as String : null;
        return ProfileApiException(msg, code: code);
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
    return ProfileApiException(e.message ?? 'সংযোগ ত্রুটি', code: 'NETWORK');
  }
}

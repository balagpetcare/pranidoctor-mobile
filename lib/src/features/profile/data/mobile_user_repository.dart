import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:pranidoctor_mobile/src/core/network/api_client.dart';
import 'package:pranidoctor_mobile/src/core/network/dio_user_message.dart';
import 'package:pranidoctor_mobile/src/core/network/mobile_api_envelope.dart';
import 'package:pranidoctor_mobile/src/features/profile/data/mobile_profile_api_contract.dart';
import 'package:pranidoctor_mobile/src/features/profile/data/mobile_user_model.dart';
import 'package:pranidoctor_mobile/src/features/profile/data/profile_api_exception.dart';

abstract class MobileUserRepository {
  Future<MobileUser> fetchMe();

  Future<MobileUser> patchMe(MobileUserPatch patch);

  /// Name and/or email only (never phone). Uses split or legacy path per flags.
  Future<MobileUser> updateBasicProfile({String? name, String? email});

  /// Structured location + optional [area] label.
  Future<MobileUser> updateLocation(MobileUserLocationUpdate update);

  /// Multipart `file` field — see [MobileProfileApiPaths.postProfilePhoto].
  Future<MobileProfilePhotoUploadResult> uploadProfilePhoto(String filePath);

  /// Multipart `file` field — see [MobileProfileApiPaths.postCoverPhoto].
  Future<MobileProfilePhotoUploadResult> uploadCoverPhoto(String filePath);
}

class MobileUserRepositoryLive implements MobileUserRepository {
  MobileUserRepositoryLive(this._client);

  final ApiClient _client;

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
      final res = await _client.get<dynamic>(MobileProfileApiPaths.getMe);
      assert(() {
        debugPrint('[PraniDoctor][auth] GET /me HTTP ${res.statusCode ?? '?'}');
        return true;
      }());
      final inner = _unwrap(res);
      return MobileUser.fromJson(inner);
    } on DioException catch (e, st) {
      assert(() {
        debugPrint(
          '[PraniDoctor][auth] GET /me DioException '
          'status=${e.response?.statusCode}',
        );
        return true;
      }());
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
      final res = await _client.patch<dynamic>(
        MobileProfileApiPaths.patchMeLegacy,
        data: patch.toJson(),
      );
      _unwrap(res);
      return fetchMe();
    } on DioException catch (e) {
      throw _mapDio(e);
    } on ProfileApiException {
      rethrow;
    }
  }

  @override
  Future<MobileUser> updateBasicProfile({String? name, String? email}) async {
    final body = <String, dynamic>{};
    if (name != null && name.trim().isNotEmpty) {
      body['name'] = name.trim();
    }
    if (email != null && email.trim().isNotEmpty) {
      body['email'] = email.trim();
    }
    if (body.isEmpty) {
      throw ProfileApiException('কোনো পরিবর্তন নেই।');
    }
    final path = kMobileProfileUseSplitProfileLocationPatch
        ? MobileProfileApiPaths.patchProfile
        : MobileProfileApiPaths.patchMeLegacy;
    try {
      final res = await _client.patch<dynamic>(path, data: body);
      _unwrap(res);
      return fetchMe();
    } on DioException catch (e) {
      throw _mapDio(e);
    } on ProfileApiException {
      rethrow;
    }
  }

  @override
  Future<MobileUser> updateLocation(MobileUserLocationUpdate update) async {
    if (update.isEmpty) {
      throw ProfileApiException('কোনো পরিবর্তন নেই।');
    }
    final path = kMobileProfileUseSplitProfileLocationPatch
        ? MobileProfileApiPaths.patchLocation
        : MobileProfileApiPaths.patchMeLegacy;
    final body = kMobileProfileUseSplitProfileLocationPatch
        ? update.toJsonSplit()
        : update.toJsonLegacy();
    if (body.isEmpty) {
      throw ProfileApiException('কোনো পরিবর্তন নেই।');
    }
    try {
      final res = await _client.patch<dynamic>(path, data: body);
      _unwrap(res);
      return fetchMe();
    } on DioException catch (e) {
      throw _mapDio(e);
    } on ProfileApiException {
      rethrow;
    }
  }

  static String _basename(String path) {
    final norm = path.replaceAll('\\', '/');
    final i = norm.lastIndexOf('/');
    return i >= 0 ? norm.substring(i + 1) : norm;
  }

  @override
  Future<MobileProfilePhotoUploadResult> uploadProfilePhoto(
    String filePath,
  ) async {
    return _uploadPhoto(
      filePath,
      MobileProfileApiPaths.postProfilePhoto,
      'প্রোফাইল ছবি',
    );
  }

  @override
  Future<MobileProfilePhotoUploadResult> uploadCoverPhoto(
    String filePath,
  ) async {
    return _uploadPhoto(
      filePath,
      MobileProfileApiPaths.postCoverPhoto,
      'কভার ছবি',
    );
  }

  Future<MobileProfilePhotoUploadResult> _uploadPhoto(
    String filePath,
    String path,
    String labelBn,
  ) async {
    if (kIsWeb) {
      return MobileProfilePhotoUploadResult.failed(
        'ছবি আপলোড এই প্ল্যাটফর্মে উপলব্ধ নয়।',
      );
    }
    if (!kMobileProfilePhotoPostEndpointsEnabled) {
      return MobileProfilePhotoUploadResult.notDeployed();
    }
    try {
      final form = FormData.fromMap(<String, dynamic>{
        'file': await MultipartFile.fromFile(
          filePath,
          filename: _basename(filePath),
        ),
      });
      final res = await _client.dio.post<dynamic>(
        path,
        data: form,
        options: Options(
          headers: <String, dynamic>{Headers.acceptHeader: 'application/json'},
        ),
      );
      unwrapOkDataMap(res.data);
      return MobileProfilePhotoUploadResult.success;
    } on MobileApiEnvelopeException catch (e) {
      return MobileProfilePhotoUploadResult.failed(
        e.message.trim().isNotEmpty ? e.message : '$labelBn আপলোড ব্যর্থ।',
      );
    } on DioException catch (e, st) {
      assert(() {
        debugPrint('MobileUserRepository photo upload: $e\n$st');
        return true;
      }());
      final code = e.response?.statusCode;
      if (code == 404 || code == 405) {
        return MobileProfilePhotoUploadResult.notDeployed(
          messageBn:
              'সার্ভারে $labelBn আপলোড এন্ডপয়েন্ট এখনো চালু নয়। পরে আবার চেষ্টা করুন।',
        );
      }
      if (code == 413) {
        return MobileProfilePhotoUploadResult.failed(
          'ফাইলের আকার অনুমোদিত সীমার চেয়ে বড়।',
        );
      }
      if (code == 415) {
        return MobileProfilePhotoUploadResult.failed(
          'এই ধরনের ছবি গ্রহণ করা হয় না।',
        );
      }
      return MobileProfilePhotoUploadResult.failed(userFacingDioMessageBn(e));
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
    return ProfileApiException(userFacingDioMessageBn(e), code: 'NETWORK');
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

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:pranidoctor_mobile/src/core/network/api_client.dart';
import 'package:pranidoctor_mobile/src/core/network/dio_user_message.dart';
import 'package:pranidoctor_mobile/src/core/network/mobile_api_envelope.dart';
import 'package:pranidoctor_mobile/src/features/locations/data/location_list_dedupe.dart';
import 'package:pranidoctor_mobile/src/features/locations/data/location_models.dart';

/// When `true`, [createVillage] calls `POST /api/mobile/locations/villages`.
/// Default `false` — UI still allows typing a new Bangla name and saves via
/// [MobileUserRepository.updateLocation]; server-side village row may be absent.
const bool kMobileLocationCreateVillageEnabled = false;

class LocationRepository {
  LocationRepository(this._client);

  final ApiClient _client;

  static const _divisions = '/api/mobile/locations/divisions';
  static const _districts = '/api/mobile/locations/districts';
  static const _upazilas = '/api/mobile/locations/upazilas';
  static const _unions = '/api/mobile/locations/unions';
  static const _villages = '/api/mobile/locations/villages';

  Future<List<MobileLocationDto>> fetchDivisions() async {
    try {
      final res = await _client.get<dynamic>(_divisions);
      final inner = unwrapOkDataMap(res.data);
      final raw = inner['items'];
      if (raw is! List<dynamic>) {
        throw MobileApiEnvelopeException('বিভাগের তালিকা পাওয়া যায়নি');
      }
      final mapped = raw
          .map((e) => MobileLocationDto.fromJson(e as Map<String, dynamic>))
          .toList();
      return dedupeMobileLocationsForParentScope(mapped, 'divisions');
    } on MobileApiEnvelopeException {
      rethrow;
    } on DioException catch (e, st) {
      assert(() {
        debugPrint(
          'LocationRepository.fetchDivisions: ${e.requestOptions.uri}\n$st',
        );
        return true;
      }());
      throw _mappedDio(e);
    }
  }

  Future<List<MobileLocationDto>> fetchDistricts({String? divisionId}) async {
    try {
      final res = await _client.get<dynamic>(
        _districts,
        queryParameters: <String, dynamic>{
          if (divisionId != null && divisionId.trim().isNotEmpty)
            'divisionId': divisionId.trim(),
        },
      );
      final inner = unwrapOkDataMap(res.data);
      final raw = inner['items'];
      if (raw is! List<dynamic>) {
        throw MobileApiEnvelopeException('জেলার তালিকা পাওয়া যায়নি');
      }
      final mapped = raw
          .map((e) => MobileLocationDto.fromJson(e as Map<String, dynamic>))
          .toList();
      final scope =
          'districts|${divisionId?.trim().isNotEmpty == true ? divisionId!.trim() : 'all'}';
      return dedupeMobileLocationsForParentScope(mapped, scope);
    } on MobileApiEnvelopeException {
      rethrow;
    } on DioException catch (e, st) {
      assert(() {
        debugPrint(
          'LocationRepository.fetchDistricts: ${e.requestOptions.uri}\n$st',
        );
        return true;
      }());
      throw _mappedDio(e);
    }
  }

  Future<List<MobileLocationDto>> fetchUpazilas({
    required String districtId,
  }) async {
    try {
      final res = await _client.get<dynamic>(
        _upazilas,
        queryParameters: <String, dynamic>{'districtId': districtId},
      );
      final inner = unwrapOkDataMap(res.data);
      final raw = inner['items'];
      if (raw is! List<dynamic>) {
        throw MobileApiEnvelopeException('উপজেলার তালিকা পাওয়া যায়নি');
      }
      final mapped = raw
          .map((e) => MobileLocationDto.fromJson(e as Map<String, dynamic>))
          .toList();
      return dedupeMobileLocationsForParentScope(
        mapped,
        'upazilas|$districtId',
      );
    } on MobileApiEnvelopeException {
      rethrow;
    } on DioException catch (e, st) {
      assert(() {
        debugPrint(
          'LocationRepository.fetchUpazilas: ${e.requestOptions.uri}\n$st',
        );
        return true;
      }());
      throw _mappedDio(e);
    }
  }

  Future<List<MobileLocationDto>> fetchUnions({
    required String districtId,
    required String upazilaId,
  }) async {
    try {
      final res = await _client.get<dynamic>(
        _unions,
        queryParameters: <String, dynamic>{
          'districtId': districtId,
          'upazilaId': upazilaId,
        },
      );
      final inner = unwrapOkDataMap(res.data);
      final raw = inner['items'];
      if (raw is! List<dynamic>) {
        throw MobileApiEnvelopeException('ইউনিয়নের তালিকা পাওয়া যায়নি');
      }
      final mapped = raw
          .map((e) => MobileLocationDto.fromJson(e as Map<String, dynamic>))
          .toList();
      return dedupeMobileLocationsForParentScope(
        mapped,
        'unions|$districtId|$upazilaId',
      );
    } on MobileApiEnvelopeException {
      rethrow;
    } on DioException catch (e, st) {
      assert(() {
        debugPrint(
          'LocationRepository.fetchUnions: ${e.requestOptions.uri}\n$st',
        );
        return true;
      }());
      throw _mappedDio(e);
    }
  }

  Future<List<MobileLocationDto>> fetchVillages({
    required String unionId,
    String? searchQuery,
  }) async {
    try {
      final q = searchQuery?.trim();
      final res = await _client.get<dynamic>(
        _villages,
        queryParameters: <String, dynamic>{
          'unionId': unionId,
          if (q != null && q.isNotEmpty) 'q': q,
        },
      );
      final inner = unwrapOkDataMap(res.data);
      final raw = inner['items'];
      if (raw is! List<dynamic>) {
        throw MobileApiEnvelopeException('গ্রামের তালিকা পাওয়া যায়নি');
      }
      final mapped = raw
          .map((e) => MobileLocationDto.fromJson(e as Map<String, dynamic>))
          .toList();
      return dedupeMobileLocationsForParentScope(mapped, 'villages|$unionId');
    } on MobileApiEnvelopeException {
      rethrow;
    } on DioException catch (e, st) {
      assert(() {
        debugPrint(
          'LocationRepository.fetchVillages: ${e.requestOptions.uri}\n$st',
        );
        return true;
      }());
      throw _mappedDio(e);
    }
  }

  /// Register a new village under [unionId] (forward-looking contract).
  ///
  /// Body: `{ "unionId", "nameBn" }` → envelope `{ ok, data: { item: MobileLocationDto } }`
  /// (or `data` as the DTO map — we accept both shapes when enabled).
  Future<MobileLocationDto> createVillage({
    required String unionId,
    required String nameBn,
  }) async {
    if (!kMobileLocationCreateVillageEnabled) {
      throw MobileApiEnvelopeException(
        'নতুন গ্রাম সার্ভারে নিবন্ধন এখনো চালু নয়। ঠিকানা টেক্সট হিসেবে সংরক্ষণ হবে।',
        code: 'ENDPOINT_NOT_READY',
      );
    }
    try {
      final res = await _client.post<dynamic>(
        _villages,
        data: <String, dynamic>{
          'unionId': unionId.trim(),
          'nameBn': nameBn.trim(),
        },
      );
      final inner = unwrapOkDataMap(res.data);
      final raw = inner['item'] ?? inner['village'] ?? inner;
      if (raw is! Map<String, dynamic>) {
        throw MobileApiEnvelopeException('অপ্রত্যাশিত উত্তর');
      }
      return MobileLocationDto.fromJson(raw);
    } on MobileApiEnvelopeException {
      rethrow;
    } on DioException catch (e, st) {
      assert(() {
        debugPrint('LocationRepository.createVillage: $e\n$st');
        return true;
      }());
      throw _mappedDio(e);
    }
  }

  /// Prefer server envelope message when present; otherwise safe Bengali Dio copy.
  Never _mappedDio(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic> &&
        data['ok'] == false &&
        data['error'] is Map) {
      final err = data['error'] as Map;
      final rawMsg = err['message'] is String ? err['message'] as String : '';
      final code = err['code'] is String ? err['code'] as String : null;
      throw MobileApiEnvelopeException(_serverBn(code, rawMsg), code: code);
    }
    throw MobileApiEnvelopeException(
      userFacingDioMessageBn(e, debugLabel: 'locations'),
      code: 'DIO',
    );
  }

  static String _serverBn(String? code, String raw) {
    switch (code) {
      case 'LOCATION_MISMATCH':
        return 'নির্বাচিত জেলা ও উপজেলা মিলছে না।';
      case 'VALIDATION_ERROR':
        return 'অনুরোধ সঠিক নয়।';
      case 'DATABASE_ERROR':
        return 'সার্ভার থেকে তালিকা আনা যায়নি।';
      default:
        break;
    }
    final t = raw.trim();
    return t.isNotEmpty ? t : 'লোকেশন লোড করা যায়নি।';
  }
}

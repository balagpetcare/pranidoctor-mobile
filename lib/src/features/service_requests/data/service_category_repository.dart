import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:pranidoctor_mobile/src/core/network/api_client.dart';
import 'package:pranidoctor_mobile/src/features/service_requests/data/service_request_model.dart';

class ServiceCategoryApiException implements Exception {
  ServiceCategoryApiException(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => message;
}

class ServiceCategoryRepository {
  ServiceCategoryRepository(this._client);

  final ApiClient _client;

  Map<String, dynamic> _unwrap(Response<dynamic> response) {
    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw ServiceCategoryApiException('অপ্রত্যাশিত উত্তর');
    }
    if (data['ok'] != true) {
      final err = data['error'];
      final msg = err is Map && err['message'] is String
          ? err['message'] as String
          : 'অনুরোধ ব্যর্থ হয়েছে';
      final code = err is Map && err['code'] is String
          ? err['code'] as String
          : null;
      throw ServiceCategoryApiException(msg, code: code);
    }
    final inner = data['data'];
    if (inner is! Map<String, dynamic>) {
      throw ServiceCategoryApiException('অপ্রত্যাশিত উত্তর');
    }
    return inner;
  }

  Future<List<ServiceCategoryOption>> list() async {
    try {
      final res = await _client.get<dynamic>('/api/mobile/service-categories');
      final inner = _unwrap(res);
      final raw = inner['categories'];
      if (raw is! List<dynamic>) {
        throw ServiceCategoryApiException('অপ্রত্যাশিত উত্তর');
      }
      return raw
          .map((e) => ServiceCategoryOption.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e, st) {
      if (e.response?.statusCode == 404) {
        assert(() {
          debugPrint('ServiceCategoryRepository.list 404 -> []\n$st');
          return true;
        }());
        return [];
      }
      throw _mapDio(e);
    }
  }

  ServiceCategoryApiException _mapDio(DioException e) {
    if (e.response?.data is Map<String, dynamic>) {
      final data = e.response!.data as Map<String, dynamic>;
      if (data['ok'] == false && data['error'] is Map) {
        final err = data['error'] as Map;
        final msg = err['message'] is String
            ? err['message'] as String
            : 'নেটওয়ার্ক ত্রুটি';
        final code = err['code'] is String ? err['code'] as String : null;
        return ServiceCategoryApiException(msg, code: code);
      }
    }
    final code = e.response?.statusCode;
    if (code == 401) {
      return ServiceCategoryApiException(
        'লগইন প্রয়োজন বা সেশন শেষ',
        code: 'UNAUTHORIZED',
      );
    }
    return ServiceCategoryApiException(
      e.message ?? 'সংযোগ ত্রুটি',
      code: 'NETWORK',
    );
  }
}

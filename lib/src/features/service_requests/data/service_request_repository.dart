import 'package:dio/dio.dart';

import 'package:pranidoctor_mobile/src/core/network/api_client.dart';
import 'package:pranidoctor_mobile/src/features/service_requests/data/service_request_model.dart';

class ServiceRequestApiException implements Exception {
  ServiceRequestApiException(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => message;
}

class ServiceRequestRepository {
  ServiceRequestRepository(this._client);

  final ApiClient _client;

  Map<String, dynamic> _unwrap(Response<dynamic> response) {
    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw ServiceRequestApiException('অপ্রত্যাশিত উত্তর');
    }
    if (data['ok'] != true) {
      final err = data['error'];
      final msg = err is Map && err['message'] is String
          ? err['message'] as String
          : 'অনুরোধ ব্যর্থ হয়েছে';
      final code = err is Map && err['code'] is String
          ? err['code'] as String
          : null;
      throw ServiceRequestApiException(msg, code: code);
    }
    final inner = data['data'];
    if (inner is! Map<String, dynamic>) {
      throw ServiceRequestApiException('অপ্রত্যাশিত উত্তর');
    }
    return inner;
  }

  Future<ServiceRequest> create(Map<String, dynamic> body) async {
    try {
      final res = await _client.post<dynamic>(
        '/api/mobile/service-requests',
        data: body,
      );
      final inner = _unwrap(res);
      final raw = inner['request'];
      if (raw is! Map<String, dynamic>) {
        throw ServiceRequestApiException('অপ্রত্যাশিত উত্তর');
      }
      return ServiceRequest.fromJson(raw);
    } on DioException catch (e) {
      throw _mapDio(e);
    }
  }

  Future<({List<ServiceRequest> requests, int total})> list({
    int limit = 20,
    int offset = 0,
    ServiceRequestStatus? status,
  }) async {
    try {
      final qp = <String, dynamic>{
        'limit': limit.toString(),
        'offset': offset.toString(),
      };
      if (status != null) {
        qp['status'] = status.name;
      }
      final res = await _client.get<dynamic>(
        '/api/mobile/service-requests',
        queryParameters: qp,
      );
      final inner = _unwrap(res);
      final raw = inner['requests'];
      if (raw is! List<dynamic>) {
        throw ServiceRequestApiException('অপ্রত্যাশিত উত্তর');
      }
      final total = (inner['total'] as num?)?.toInt() ?? raw.length;
      final list = raw
          .map((e) => ServiceRequest.fromJson(e as Map<String, dynamic>))
          .toList();
      return (requests: list, total: total);
    } on DioException catch (e) {
      throw _mapDio(e);
    }
  }

  Future<ServiceRequest> getById(String id) async {
    try {
      final res = await _client.get<dynamic>(
        '/api/mobile/service-requests/$id',
      );
      final inner = _unwrap(res);
      final raw = inner['request'];
      if (raw is! Map<String, dynamic>) {
        throw ServiceRequestApiException('অপ্রত্যাশিত উত্তর');
      }
      return ServiceRequest.fromJson(raw);
    } on DioException catch (e) {
      throw _mapDio(e);
    }
  }

  Future<ServiceRequest> cancel(String id, {String? cancelReason}) async {
    try {
      final res = await _client.patch<dynamic>(
        '/api/mobile/service-requests/$id/cancel',
        data: {
          if (cancelReason != null && cancelReason.trim().isNotEmpty)
            'cancelReason': cancelReason.trim(),
        },
      );
      final inner = _unwrap(res);
      final raw = inner['request'];
      if (raw is! Map<String, dynamic>) {
        throw ServiceRequestApiException('অপ্রত্যাশিত উত্তর');
      }
      return ServiceRequest.fromJson(raw);
    } on DioException catch (e) {
      throw _mapDio(e);
    }
  }

  ServiceRequestApiException _mapDio(DioException e) {
    if (e.response?.data is Map<String, dynamic>) {
      final data = e.response!.data as Map<String, dynamic>;
      if (data['ok'] == false && data['error'] is Map) {
        final err = data['error'] as Map;
        final msg = err['message'] is String
            ? err['message'] as String
            : 'নেটওয়ার্ক ত্রুটি';
        final code = err['code'] is String ? err['code'] as String : null;
        return ServiceRequestApiException(msg, code: code);
      }
    }
    final code = e.response?.statusCode;
    if (code == 401) {
      return ServiceRequestApiException(
        'লগইন প্রয়োজন বা সেশন শেষ',
        code: 'UNAUTHORIZED',
      );
    }
    if (code == 403) {
      return ServiceRequestApiException('অনুমতি নেই', code: 'FORBIDDEN');
    }
    if (code == 404) {
      return ServiceRequestApiException(
        'খুঁজে পাওয়া যায়নি',
        code: 'NOT_FOUND',
      );
    }
    if (code == 409) {
      return ServiceRequestApiException(
        'এই অবস্থায় বাতিল করা যাবে না',
        code: 'INVALID_STATE',
      );
    }
    return ServiceRequestApiException(
      e.message ?? 'সংযোগ ত্রুটি',
      code: 'NETWORK',
    );
  }
}

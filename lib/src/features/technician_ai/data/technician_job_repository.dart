import 'package:dio/dio.dart';

import 'package:pranidoctor_mobile/src/core/network/api_client.dart';
import 'package:pranidoctor_mobile/src/core/network/dio_user_message.dart';
import 'package:pranidoctor_mobile/src/features/technician_ai/data/technician_api_exception.dart';
import 'package:pranidoctor_mobile/src/features/technician_ai/data/technician_job_models.dart';

/// Mobile AI technician workflow — swap with [TechnicianJobRepositoryMock] via [AppConfig].
abstract class TechnicianJobRepository {
  Future<({List<TechnicianIncomingRequest> requests, int total})> listRequests({
    int limit,
    int offset,
  });

  Future<({List<TechnicianJobSummary> jobs, int total})> listJobs({
    int limit,
    int offset,
  });

  Future<TechnicianJobDetail> getJob(String id);

  Future<TechnicianJobDetail> acceptJob(String id);

  Future<TechnicianJobDetail> rejectJob(String id, {String? reason});

  Future<TechnicianJobDetail> saveAiRecord(
    String id,
    TechnicianAiRecordInput input,
  );

  Future<TechnicianJobDetail> completeJob(String id);
}

class TechnicianJobRepositoryLive implements TechnicianJobRepository {
  TechnicianJobRepositoryLive(this._client);

  final ApiClient _client;

  Map<String, dynamic> _unwrap(Response<dynamic> response) {
    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw TechnicianApiException('অপ্রত্যাশিত উত্তর');
    }
    if (data['ok'] != true) {
      final err = data['error'];
      final msg = err is Map && err['message'] is String
          ? err['message'] as String
          : 'অনুরোধ ব্যর্থ হয়েছে';
      final code = err is Map && err['code'] is String
          ? err['code'] as String
          : null;
      throw TechnicianApiException(msg, code: code);
    }
    final inner = data['data'];
    if (inner is! Map<String, dynamic>) {
      throw TechnicianApiException('অপ্রত্যাশিত উত্তর');
    }
    return inner;
  }

  List<Map<String, dynamic>> _listOfMaps(dynamic raw) {
    if (raw is! List<dynamic>) return const [];
    return raw
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  @override
  Future<({List<TechnicianIncomingRequest> requests, int total})> listRequests({
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final res = await _client.get<dynamic>(
        '/api/mobile/technician/requests',
        queryParameters: {
          'limit': limit.toString(),
          'offset': offset.toString(),
        },
      );
      final inner = _unwrap(res);
      final raw = inner['requests'] ?? inner['items'];
      final list = _listOfMaps(raw);
      final total = (inner['total'] as num?)?.toInt() ?? list.length;
      return (
        requests: list.map(TechnicianIncomingRequest.fromJson).toList(),
        total: total,
      );
    } on DioException catch (e) {
      throw _mapDio(e);
    }
  }

  @override
  Future<({List<TechnicianJobSummary> jobs, int total})> listJobs({
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final res = await _client.get<dynamic>(
        '/api/mobile/technician/jobs',
        queryParameters: {
          'limit': limit.toString(),
          'offset': offset.toString(),
        },
      );
      final inner = _unwrap(res);
      final raw = inner['jobs'] ?? inner['items'];
      final list = _listOfMaps(raw);
      final total = (inner['total'] as num?)?.toInt() ?? list.length;
      return (
        jobs: list.map(TechnicianJobSummary.fromJson).toList(),
        total: total,
      );
    } on DioException catch (e) {
      throw _mapDio(e);
    }
  }

  @override
  Future<TechnicianJobDetail> getJob(String id) async {
    try {
      final res = await _client.get<dynamic>('/api/mobile/technician/jobs/$id');
      final inner = _unwrap(res);
      final raw = inner['job'] ?? inner['request'];
      if (raw is! Map<String, dynamic>) {
        throw TechnicianApiException('অপ্রত্যাশিত উত্তর');
      }
      return TechnicianJobDetail.fromJson(raw);
    } on DioException catch (e) {
      throw _mapDio(e);
    }
  }

  @override
  Future<TechnicianJobDetail> acceptJob(String id) async {
    try {
      final res = await _client.patch<dynamic>(
        '/api/mobile/technician/jobs/$id',
        data: {'action': 'accept'},
      );
      final inner = _unwrap(res);
      final raw = inner['job'] ?? inner;
      if (raw is! Map<String, dynamic>) {
        throw TechnicianApiException('অপ্রত্যাশিত উত্তর');
      }
      return TechnicianJobDetail.fromJson(raw);
    } on DioException catch (e) {
      throw _mapDio(e);
    }
  }

  @override
  Future<TechnicianJobDetail> rejectJob(String id, {String? reason}) async {
    try {
      final res = await _client.patch<dynamic>(
        '/api/mobile/technician/jobs/$id',
        data: {
          'action': 'reject',
          if (reason != null && reason.trim().isNotEmpty)
            'reason': reason.trim(),
        },
      );
      final inner = _unwrap(res);
      final raw = inner['job'] ?? inner;
      if (raw is! Map<String, dynamic>) {
        throw TechnicianApiException('অপ্রত্যাশিত উত্তর');
      }
      return TechnicianJobDetail.fromJson(raw);
    } on DioException catch (e) {
      throw _mapDio(e);
    }
  }

  @override
  Future<TechnicianJobDetail> saveAiRecord(
    String id,
    TechnicianAiRecordInput input,
  ) async {
    try {
      final res = await _client.patch<dynamic>(
        '/api/mobile/technician/jobs/$id/ai-record',
        data: input.toJson(),
      );
      final inner = _unwrap(res);
      final raw = inner['job'] ?? inner;
      if (raw is! Map<String, dynamic>) {
        throw TechnicianApiException('অপ্রত্যাশিত উত্তর');
      }
      return TechnicianJobDetail.fromJson(raw);
    } on DioException catch (e) {
      throw _mapDio(e);
    }
  }

  @override
  Future<TechnicianJobDetail> completeJob(String id) async {
    try {
      final res = await _client.patch<dynamic>(
        '/api/mobile/technician/jobs/$id/complete',
        data: const <String, dynamic>{},
      );
      final inner = _unwrap(res);
      final raw = inner['job'] ?? inner;
      if (raw is! Map<String, dynamic>) {
        throw TechnicianApiException('অপ্রত্যাশিত উত্তর');
      }
      return TechnicianJobDetail.fromJson(raw);
    } on DioException catch (e) {
      throw _mapDio(e);
    }
  }

  TechnicianApiException _mapDio(DioException e) {
    if (e.response?.data is Map<String, dynamic>) {
      final data = e.response!.data as Map<String, dynamic>;
      if (data['ok'] == false && data['error'] is Map) {
        final err = data['error'] as Map;
        final msg = err['message'] is String
            ? err['message'] as String
            : 'নেটওয়ার্ক ত্রুটি';
        final code = err['code'] is String ? err['code'] as String : null;
        return TechnicianApiException(msg, code: code);
      }
    }
    final code = e.response?.statusCode;
    if (code == 401) {
      return TechnicianApiException(
        'লগইন প্রয়োজন বা সেশন শেষ',
        code: 'UNAUTHORIZED',
      );
    }
    if (code == 403) {
      return TechnicianApiException('অনুমতি নেই', code: 'FORBIDDEN');
    }
    if (code == 404) {
      return TechnicianApiException(
        'খুঁজে পাওয়া যায়নি বা সেবাটি এখনও চালু হয়নি',
        code: 'NOT_FOUND',
      );
    }
    return TechnicianApiException(userFacingDioMessageBn(e), code: 'NETWORK');
  }
}

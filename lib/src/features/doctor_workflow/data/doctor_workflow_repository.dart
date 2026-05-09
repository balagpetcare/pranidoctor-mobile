import 'package:dio/dio.dart';

import 'package:pranidoctor_mobile/src/core/network/api_client.dart';
import 'package:pranidoctor_mobile/src/features/doctor_workflow/data/doctor_case_models.dart';

class DoctorWorkflowApiException implements Exception {
  DoctorWorkflowApiException(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => message;
}

/// Mobile doctor workflow — paths match product spec; adjust private constants if backend differs.
class DoctorWorkflowRepository {
  DoctorWorkflowRepository(this._client);

  final ApiClient _client;

  static const _pathRequests = '/api/mobile/doctor/requests';
  static const _pathCases = '/api/mobile/doctor/cases';

  Map<String, dynamic> _unwrap(Response<dynamic> response) {
    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw DoctorWorkflowApiException('অপ্রত্যাশিত উত্তর');
    }
    if (data['ok'] != true) {
      final err = data['error'];
      final msg = err is Map && err['message'] is String
          ? err['message'] as String
          : 'অনুরোধ ব্যর্থ হয়েছে';
      final code = err is Map && err['code'] is String
          ? err['code'] as String
          : null;
      throw DoctorWorkflowApiException(msg, code: code);
    }
    final inner = data['data'];
    if (inner is! Map<String, dynamic>) {
      throw DoctorWorkflowApiException('অপ্রত্যাশিত উত্তর');
    }
    return inner;
  }

  List<Map<String, dynamic>> _listOfMaps(dynamic raw) {
    if (raw is! List<dynamic>) return const [];
    return raw
        .map((e) => e is Map<String, dynamic> ? e : null)
        .whereType<Map<String, dynamic>>()
        .toList();
  }

  Future<List<DoctorIncomingRequest>> listIncomingRequests() async {
    try {
      final res = await _client.get<dynamic>(_pathRequests);
      final inner = _unwrap(res);
      final raw = inner['requests'] ?? inner['items'] ?? inner['data'];
      return _listOfMaps(raw).map(DoctorIncomingRequest.fromJson).toList();
    } on DioException catch (e) {
      throw _mapDio(e);
    }
  }

  Future<List<DoctorCaseListItem>> listCases({bool activeOnly = false}) async {
    try {
      final res = await _client.get<dynamic>(
        _pathCases,
        queryParameters: activeOnly ? {'active': 'true'} : null,
      );
      final inner = _unwrap(res);
      final raw = inner['cases'] ?? inner['requests'] ?? inner['items'];
      var list = _listOfMaps(raw).map(DoctorCaseListItem.fromJson).toList();
      if (activeOnly) {
        list = list.where((e) => e.isActiveBn).toList();
      }
      return list;
    } on DioException catch (e) {
      throw _mapDio(e);
    }
  }

  Future<DoctorCaseDetail> getCaseById(String id) async {
    try {
      final res = await _client.get<dynamic>('$_pathCases/$id');
      final inner = _unwrap(res);
      final raw =
          inner['case'] ?? inner['detail'] ?? inner['doctorCase'] ?? inner;
      if (raw is! Map<String, dynamic>) {
        throw DoctorWorkflowApiException('অপ্রত্যাশিত উত্তর');
      }
      return DoctorCaseDetail.fromJson(raw);
    } on DioException catch (e) {
      throw _mapDio(e);
    }
  }

  /// Accept pending assignment for [requestId].
  Future<void> acceptRequest(
    String requestId, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final res = await _client.patch<dynamic>(
        '$_pathRequests/$requestId/accept',
        data: body ?? const <String, dynamic>{},
      );
      _unwrap(res);
    } on DioException catch (e) {
      throw _mapDio(e);
    }
  }

  /// Reject pending assignment for [requestId].
  Future<void> rejectRequest(String requestId, {String? reason}) async {
    try {
      final res = await _client.patch<dynamic>(
        '$_pathRequests/$requestId/reject',
        data: {
          if (reason != null && reason.trim().isNotEmpty)
            'rejectReason': reason.trim(),
        },
      );
      _unwrap(res);
    } on DioException catch (e) {
      throw _mapDio(e);
    }
  }

  /// Save treatment / clinical note for a case.
  Future<void> saveTreatmentNote(
    String caseId,
    Map<String, dynamic> body,
  ) async {
    try {
      final res = await _client.patch<dynamic>(
        '$_pathCases/$caseId/treatment',
        data: body,
      );
      _unwrap(res);
    } on DioException catch (e) {
      throw _mapDio(e);
    }
  }

  /// Create or update prescription for a case.
  Future<void> savePrescription(
    String caseId,
    Map<String, dynamic> body,
  ) async {
    try {
      final res = await _client.patch<dynamic>(
        '$_pathCases/$caseId/prescription',
        data: body,
      );
      _unwrap(res);
    } on DioException catch (e) {
      throw _mapDio(e);
    }
  }

  /// Mark case completed.
  Future<void> completeCase(String caseId, {Map<String, dynamic>? body}) async {
    try {
      final res = await _client.patch<dynamic>(
        '$_pathCases/$caseId/complete',
        data: body ?? const <String, dynamic>{},
      );
      _unwrap(res);
    } on DioException catch (e) {
      throw _mapDio(e);
    }
  }

  DoctorWorkflowApiException _mapDio(DioException e) {
    if (e.response?.data is Map<String, dynamic>) {
      final data = e.response!.data as Map<String, dynamic>;
      if (data['ok'] == false && data['error'] is Map) {
        final err = data['error'] as Map;
        final msg = err['message'] is String
            ? err['message'] as String
            : 'নেটওয়ার্ক ত্রুটি';
        final code = err['code'] is String ? err['code'] as String : null;
        return DoctorWorkflowApiException(msg, code: code);
      }
    }
    final code = e.response?.statusCode;
    if (code == 401) {
      return DoctorWorkflowApiException(
        'লগইন প্রয়োজন বা সেশন শেষ',
        code: 'UNAUTHORIZED',
      );
    }
    if (code == 403) {
      return DoctorWorkflowApiException('অনুমতি নেই', code: 'FORBIDDEN');
    }
    if (code == 404) {
      return DoctorWorkflowApiException(
        'খুঁজে পাওয়া যায়নি',
        code: 'NOT_FOUND',
      );
    }
    return DoctorWorkflowApiException(
      e.message ?? 'সংযোগ ত্রুটি',
      code: 'NETWORK',
    );
  }
}

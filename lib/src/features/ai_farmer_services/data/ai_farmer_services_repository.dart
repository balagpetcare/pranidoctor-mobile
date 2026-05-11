import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:pranidoctor_mobile/src/core/network/api_client.dart';
import 'package:pranidoctor_mobile/src/features/ai_farmer_services/data/ai_digital_service_record_dto.dart';
import 'package:pranidoctor_mobile/src/features/ai_farmer_services/data/ai_farmer_services_models.dart';
import 'package:pranidoctor_mobile/src/features/providers/data/provider_models.dart';

class AiFarmerServicesApiException implements Exception {
  AiFarmerServicesApiException(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => message;
}

class AiFarmerServicesRepository {
  AiFarmerServicesRepository(this._client);

  final ApiClient _client;

  static const _technicians = '/api/mobile/ai-services/technicians';
  static const _requests = '/api/mobile/ai-services/requests';
  static const _myRequests = '/api/mobile/ai-services/requests/me';

  Map<String, dynamic> _unwrapMap(Response<dynamic> response) {
    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw AiFarmerServicesApiException('অপ্রত্যাশিত উত্তর');
    }
    if (data['ok'] != true) {
      final err = data['error'];
      final msg = err is Map && err['message'] is String
          ? err['message'] as String
          : 'অনুরোধ ব্যর্থ হয়েছে';
      final code = err is Map && err['code'] is String
          ? err['code'] as String
          : null;
      throw AiFarmerServicesApiException(msg, code: code);
    }
    final inner = data['data'];
    if (inner is! Map<String, dynamic>) {
      throw AiFarmerServicesApiException('অপ্রত্যাশিত উত্তর');
    }
    return inner;
  }

  Future<
    ({
      List<AiTechnicianForServiceSummary> technicians,
      PaginationInfo pagination,
    })
  >
  listTechniciansForAiService({
    required String district,
    required String upazila,
    String? unionOrArea,
    String? animalType,
    bool? emergency,
    int limit = 20,
    int offset = 0,
  }) async {
    final qp = <String, dynamic>{
      'district': district.trim(),
      'upazila': upazila.trim(),
      'limit': limit,
      'offset': offset,
    };
    if (unionOrArea != null && unionOrArea.trim().isNotEmpty) {
      qp['unionOrArea'] = unionOrArea.trim();
    }
    if (animalType != null && animalType.trim().isNotEmpty) {
      qp['animalType'] = animalType.trim();
    }
    if (emergency == true) {
      qp['emergency'] = 'true';
    }

    try {
      final res = await _client.get<dynamic>(_technicians, queryParameters: qp);
      final inner = _unwrapMap(res);
      final rawList = inner['technicians'];
      final rawPag = inner['pagination'];
      if (rawList is! List<dynamic>) {
        throw AiFarmerServicesApiException('অপ্রত্যাশিত উত্তর');
      }
      final technicians = rawList
          .map(
            (e) => AiTechnicianForServiceSummary.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList();
      final pagination = rawPag is Map<String, dynamic>
          ? PaginationInfo.fromJson(rawPag)
          : const PaginationInfo(
              limit: 20,
              offset: 0,
              total: 0,
              hasMore: false,
            );
      return (technicians: technicians, pagination: pagination);
    } on AiFarmerServicesApiException {
      rethrow;
    } on DioException catch (e, st) {
      assert(() {
        debugPrint('AiFarmerServicesRepository.listTechnicians $e\n$st');
        return true;
      }());
      throw _mapDio(e);
    }
  }

  Future<AiTechnicianPublicDetail> getTechnicianPublic(String id) async {
    try {
      final res = await _client.get<dynamic>('$_technicians/$id');
      final inner = _unwrapMap(res);
      final raw = inner['technician'];
      if (raw is! Map<String, dynamic>) {
        throw AiFarmerServicesApiException('অপ্রত্যাশিত উত্তর');
      }
      return AiTechnicianPublicDetail.fromJson(raw);
    } on AiFarmerServicesApiException {
      rethrow;
    } on DioException catch (e) {
      throw _mapDio(e);
    }
  }

  Future<AiFarmerServiceRequestRow> createRequest(
    Map<String, dynamic> body,
  ) async {
    try {
      final res = await _client.post<dynamic>(_requests, data: body);
      final inner = _unwrapMap(res);
      final raw = inner['request'];
      if (raw is! Map<String, dynamic>) {
        throw AiFarmerServicesApiException('অপ্রত্যাশিত উত্তর');
      }
      return AiFarmerServiceRequestRow.fromJson(raw);
    } on AiFarmerServicesApiException {
      rethrow;
    } on DioException catch (e) {
      throw _mapDio(e);
    }
  }

  Future<AiFarmerServiceRequestRow> getMyRequest(String id) async {
    try {
      final res = await _client.get<dynamic>('$_requests/$id');
      final inner = _unwrapMap(res);
      final raw = inner['request'];
      if (raw is! Map<String, dynamic>) {
        throw AiFarmerServicesApiException('অপ্রত্যাশিত উত্তর');
      }
      return AiFarmerServiceRequestRow.fromJson(raw);
    } on AiFarmerServicesApiException {
      rethrow;
    } on DioException catch (e) {
      throw _mapDio(e);
    }
  }

  Future<AiDigitalServiceRecord> fetchServiceRecord(String requestId) async {
    try {
      final res = await _client.get<dynamic>('$_requests/$requestId/record');
      final inner = _unwrapMap(res);
      final raw = inner['record'];
      if (raw is! Map<String, dynamic>) {
        throw AiFarmerServicesApiException('অপ্রত্যাশিত উত্তর');
      }
      return AiDigitalServiceRecord.fromJson(raw);
    } on AiFarmerServicesApiException {
      rethrow;
    } on DioException catch (e) {
      throw _mapDio(e);
    }
  }

  Future<
    ({List<AiFarmerServiceRequestRow> requests, PaginationInfo pagination})
  >
  listMyRequests({int limit = 20, int offset = 0}) async {
    try {
      final res = await _client.get<dynamic>(
        _myRequests,
        queryParameters: <String, dynamic>{'limit': limit, 'offset': offset},
      );
      final inner = _unwrapMap(res);
      final rawList = inner['requests'];
      final rawPag = inner['pagination'];
      if (rawList is! List<dynamic>) {
        throw AiFarmerServicesApiException('অপ্রত্যাশিত উত্তর');
      }
      final requests = rawList
          .map(
            (e) =>
                AiFarmerServiceRequestRow.fromJson(e as Map<String, dynamic>),
          )
          .toList();
      final pagination = rawPag is Map<String, dynamic>
          ? PaginationInfo.fromJson(rawPag)
          : const PaginationInfo(
              limit: 20,
              offset: 0,
              total: 0,
              hasMore: false,
            );
      return (requests: requests, pagination: pagination);
    } on AiFarmerServicesApiException {
      rethrow;
    } on DioException catch (e) {
      throw _mapDio(e);
    }
  }

  Future<void> submitTechnicianReview(
    String requestId, {
    required int rating,
    String? comment,
  }) async {
    try {
      final body = <String, dynamic>{'rating': rating};
      final c = comment?.trim();
      if (c != null && c.isNotEmpty) {
        body['comment'] = c;
      }
      final res = await _client.post<dynamic>(
        '$_requests/$requestId/review',
        data: body,
      );
      _unwrapMap(res);
    } on AiFarmerServicesApiException {
      rethrow;
    } on DioException catch (e) {
      throw _mapDio(e);
    }
  }

  Future<void> submitTechnicianComplaint(
    String requestId, {
    required String category,
    required String message,
  }) async {
    try {
      final res = await _client.post<dynamic>(
        '$_requests/$requestId/complaint',
        data: <String, dynamic>{
          'category': category.trim(),
          'message': message.trim(),
        },
      );
      _unwrapMap(res);
    } on AiFarmerServicesApiException {
      rethrow;
    } on DioException catch (e) {
      throw _mapDio(e);
    }
  }

  AiFarmerServicesApiException _mapDio(DioException e) {
    if (e.response?.data is Map<String, dynamic>) {
      final data = e.response!.data as Map<String, dynamic>;
      if (data['ok'] == false && data['error'] is Map) {
        final err = data['error'] as Map;
        final rawMsg = err['message'] is String
            ? err['message'] as String
            : 'নেটওয়ার্ক ত্রুটি';
        final code = err['code'] is String ? err['code'] as String : null;
        return AiFarmerServicesApiException(rawMsg, code: code);
      }
    }
    final code = e.response?.statusCode;
    if (code == 401) {
      return AiFarmerServicesApiException(
        'লগইন প্রয়োজন',
        code: 'UNAUTHORIZED',
      );
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return AiFarmerServicesApiException('সংযোগ সময় শেষ। আবার চেষ্টা করুন।');
    }
    return AiFarmerServicesApiException('সার্ভারের সাথে যোগাযোগ করা যায়নি।');
  }
}

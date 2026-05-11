import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:pranidoctor_mobile/src/core/network/api_client.dart';
import 'package:pranidoctor_mobile/src/features/ai_farmer_services/data/ai_digital_service_record_dto.dart';
import 'package:pranidoctor_mobile/src/features/ai_farmer_services/data/ai_farmer_services_models.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/data/ai_technician_api_exception.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/data/ai_technician_models.dart';

class AiTechnicianRepository {
  AiTechnicianRepository(this._client);

  final ApiClient _client;

  static const _me = '/api/mobile/ai-technician/me';
  static const _apply = '/api/mobile/ai-technician/apply';
  static const _submit = '/api/mobile/ai-technician/submit';
  static const _documents = '/api/mobile/ai-technician/documents';
  static const _serviceAreas = '/api/mobile/ai-technician/service-areas';
  static const _dashboard = '/api/mobile/ai-technician/dashboard';
  static const _services = '/api/mobile/ai-technician/services';
  static const _settings = '/api/mobile/ai-technician/settings';
  static const _jobRequests = '/api/mobile/ai-technician/requests';

  Map<String, dynamic> _unwrap(Response<dynamic> response) {
    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw AiTechnicianApiException('অপ্রত্যাশিত উত্তর');
    }
    if (data['ok'] != true) {
      final err = data['error'];
      final msg = err is Map && err['message'] is String
          ? err['message'] as String
          : 'অনুরোধ ব্যর্থ হয়েছে';
      final code = err is Map && err['code'] is String
          ? err['code'] as String
          : null;
      throw AiTechnicianApiException(msg, code: code);
    }
    final inner = data['data'];
    if (inner is! Map<String, dynamic>) {
      throw AiTechnicianApiException('অপ্রত্যাশিত উত্তর');
    }
    return inner;
  }

  Future<AiTechnicianMeResult> fetchMe() async {
    try {
      final res = await _client.get<dynamic>(_me);
      final inner = _unwrap(res);
      final rawProfile = inner['profile'];
      final message = inner['message'] is String
          ? inner['message'] as String
          : null;
      if (rawProfile == null) {
        return AiTechnicianMeResult(profile: null, serverMessage: message);
      }
      if (rawProfile is! Map<String, dynamic>) {
        throw AiTechnicianApiException('অপ্রত্যাশিত প্রোফাইল উত্তর');
      }
      return AiTechnicianMeResult(
        profile: AiTechnicianProfile.fromJson(rawProfile),
        serverMessage: message,
      );
    } on AiTechnicianApiException catch (e) {
      /// Route/version mismatch or stale client — treat like “no application yet”.
      if (e.code == 'NOT_FOUND') {
        return AiTechnicianMeResult(profile: null, serverMessage: null);
      }
      rethrow;
    } on DioException catch (e, st) {
      assert(() {
        debugPrint('AiTechnicianRepository.fetchMe DioException: $e\n$st');
        return true;
      }());
      if (e.response?.statusCode == 404) {
        return AiTechnicianMeResult(profile: null, serverMessage: null);
      }
      throw _mapDio(e);
    }
  }

  Future<AiTechnicianProfile> apply(Map<String, dynamic> body) async {
    try {
      final res = await _client.post<dynamic>(_apply, data: body);
      final inner = _unwrap(res);
      final p = inner['profile'];
      if (p is! Map<String, dynamic>) {
        throw AiTechnicianApiException('অপ্রত্যাশিত উত্তর');
      }
      return AiTechnicianProfile.fromJson(p);
    } on AiTechnicianApiException {
      rethrow;
    } on DioException catch (e) {
      throw _mapDio(e);
    }
  }

  Future<AiTechnicianProfile> submit() async {
    try {
      final res = await _client.post<dynamic>(_submit);
      final inner = _unwrap(res);
      final p = inner['profile'];
      if (p is! Map<String, dynamic>) {
        throw AiTechnicianApiException('অপ্রত্যাশিত উত্তর');
      }
      return AiTechnicianProfile.fromJson(p);
    } on AiTechnicianApiException {
      rethrow;
    } on DioException catch (e) {
      throw _mapDio(e);
    }
  }

  Future<String> addDocument({
    required String type,
    required String title,
    String? uploadedFileId,
    String? fileUrl,
    String? storageKey,
    String? mimeType,
  }) async {
    try {
      final trimmedUpload = uploadedFileId?.trim();
      final hasUpload = trimmedUpload != null && trimmedUpload.isNotEmpty;
      final res = await _client.post<dynamic>(
        _documents,
        data: <String, dynamic>{
          'type': type,
          'title': title,
          if (hasUpload) 'uploadedFileId': trimmedUpload,
          if (!hasUpload && fileUrl != null && fileUrl.trim().isNotEmpty)
            'fileUrl': fileUrl.trim(),
          if (!hasUpload && storageKey != null && storageKey.trim().isNotEmpty)
            'storageKey': storageKey.trim(),
          if (mimeType != null && mimeType.trim().isNotEmpty)
            'mimeType': mimeType.trim(),
        },
      );
      final inner = _unwrap(res);
      final id = inner['documentId'];
      if (id is! String) {
        throw AiTechnicianApiException('নথি আইডি পাওয়া যায়নি');
      }
      return id;
    } on AiTechnicianApiException {
      rethrow;
    } on DioException catch (e) {
      throw _mapDio(e);
    }
  }

  Future<void> deleteDocument(String id) async {
    try {
      final res = await _client.delete<dynamic>('$_documents/$id');
      _unwrap(res);
    } on AiTechnicianApiException {
      rethrow;
    } on DioException catch (e) {
      throw _mapDio(e);
    }
  }

  Future<String> addDivisionServiceArea({
    String? district,
    String? upazila,
    String? unionOrArea,
    String? districtId,
    String? upazilaId,
    String? unionId,
    bool isActive = true,
  }) async {
    try {
      final res = await _client.post<dynamic>(
        _serviceAreas,
        data: <String, dynamic>{
          if (district != null && district.trim().isNotEmpty)
            'district': district.trim(),
          if (upazila != null && upazila.trim().isNotEmpty)
            'upazila': upazila.trim(),
          if (unionOrArea != null && unionOrArea.trim().isNotEmpty)
            'unionOrArea': unionOrArea.trim(),
          if (districtId != null && districtId.trim().isNotEmpty)
            'districtId': districtId.trim(),
          if (upazilaId != null && upazilaId.trim().isNotEmpty)
            'upazilaId': upazilaId.trim(),
          if (unionId != null && unionId.trim().isNotEmpty)
            'unionId': unionId.trim(),
          'isActive': isActive,
        },
      );
      final inner = _unwrap(res);
      final id = inner['areaId'];
      if (id is! String) {
        throw AiTechnicianApiException('এলাকা আইডি পাওয়া যায়নি');
      }
      return id;
    } on AiTechnicianApiException {
      rethrow;
    } on DioException catch (e) {
      throw _mapDio(e);
    }
  }

  Future<void> deleteDivisionServiceArea(String id) async {
    try {
      final res = await _client.delete<dynamic>('$_serviceAreas/$id');
      _unwrap(res);
    } on AiTechnicianApiException {
      rethrow;
    } on DioException catch (e) {
      throw _mapDio(e);
    }
  }

  Future<AiTechnicianDashboardData> fetchDashboard() async {
    try {
      final res = await _client.get<dynamic>(_dashboard);
      final inner = _unwrap(res);
      return AiTechnicianDashboardData.fromJson(inner);
    } on AiTechnicianApiException {
      rethrow;
    } on DioException catch (e) {
      throw _mapDio(e);
    }
  }

  Future<List<AiTechnicianServiceRow>> listServices() async {
    try {
      final res = await _client.get<dynamic>(_services);
      final inner = _unwrap(res);
      final raw = inner['services'];
      if (raw is! List<dynamic>) {
        throw AiTechnicianApiException('অপ্রত্যাশিত সার্ভিস তালিকা');
      }
      return raw
          .map(
            (e) => AiTechnicianServiceRow.fromJson(e as Map<String, dynamic>),
          )
          .toList();
    } on AiTechnicianApiException {
      rethrow;
    } on DioException catch (e) {
      throw _mapDio(e);
    }
  }

  Future<AiTechnicianServiceRow> createService(
    Map<String, dynamic> body,
  ) async {
    try {
      final res = await _client.post<dynamic>(_services, data: body);
      final inner = _unwrap(res);
      final s = inner['service'];
      if (s is! Map<String, dynamic>) {
        throw AiTechnicianApiException('অপ্রত্যাশিত উত্তর');
      }
      return AiTechnicianServiceRow.fromJson(s);
    } on AiTechnicianApiException {
      rethrow;
    } on DioException catch (e) {
      throw _mapDio(e);
    }
  }

  Future<AiTechnicianServiceRow> patchService(
    String id,
    Map<String, dynamic> body,
  ) async {
    try {
      final res = await _client.patch<dynamic>('$_services/$id', data: body);
      final inner = _unwrap(res);
      final s = inner['service'];
      if (s is! Map<String, dynamic>) {
        throw AiTechnicianApiException('অপ্রত্যাশিত উত্তর');
      }
      return AiTechnicianServiceRow.fromJson(s);
    } on AiTechnicianApiException {
      rethrow;
    } on DioException catch (e) {
      throw _mapDio(e);
    }
  }

  Future<AiTechnicianServiceRow> deactivateService(String id) async {
    try {
      final res = await _client.delete<dynamic>('$_services/$id');
      final inner = _unwrap(res);
      final s = inner['service'];
      if (s is! Map<String, dynamic>) {
        throw AiTechnicianApiException('অপ্রত্যাশিত উত্তর');
      }
      return AiTechnicianServiceRow.fromJson(s);
    } on AiTechnicianApiException {
      rethrow;
    } on DioException catch (e) {
      throw _mapDio(e);
    }
  }

  Future<
    ({
      List<AiFarmerServiceRequestRow> items,
      int limit,
      int offset,
      bool truncated,
    })
  >
  listTechnicianJobRequests({
    required String tab,
    int limit = 30,
    int offset = 0,
  }) async {
    try {
      final res = await _client.get<dynamic>(
        _jobRequests,
        queryParameters: <String, dynamic>{
          'tab': tab,
          'limit': limit,
          'offset': offset,
        },
      );
      final inner = _unwrap(res);
      final rawList = inner['items'];
      if (rawList is! List<dynamic>) {
        throw AiTechnicianApiException('অপ্রত্যাশিত তালিকা');
      }
      final items = rawList
          .map(
            (e) =>
                AiFarmerServiceRequestRow.fromJson(e as Map<String, dynamic>),
          )
          .toList();
      final lim = (inner['limit'] as num?)?.toInt() ?? limit;
      final off = (inner['offset'] as num?)?.toInt() ?? offset;
      final truncated = inner['truncated'] as bool? ?? false;
      return (items: items, limit: lim, offset: off, truncated: truncated);
    } on AiTechnicianApiException {
      rethrow;
    } on DioException catch (e) {
      throw _mapDio(e);
    }
  }

  Future<AiFarmerServiceRequestRow> getTechnicianJobRequest(String id) async {
    try {
      final res = await _client.get<dynamic>('$_jobRequests/$id');
      final inner = _unwrap(res);
      final raw = inner['request'];
      if (raw is! Map<String, dynamic>) {
        throw AiTechnicianApiException('অপ্রত্যাশিত উত্তর');
      }
      return AiFarmerServiceRequestRow.fromJson(raw);
    } on AiTechnicianApiException {
      rethrow;
    } on DioException catch (e) {
      throw _mapDio(e);
    }
  }

  Future<AiFarmerServiceRequestRow> acceptTechnicianJobRequest(
    String id,
  ) async {
    try {
      final res = await _client.post<dynamic>('$_jobRequests/$id/accept');
      final inner = _unwrap(res);
      final raw = inner['request'];
      if (raw is! Map<String, dynamic>) {
        throw AiTechnicianApiException('অপ্রত্যাশিত উত্তর');
      }
      return AiFarmerServiceRequestRow.fromJson(raw);
    } on AiTechnicianApiException {
      rethrow;
    } on DioException catch (e) {
      throw _mapDio(e);
    }
  }

  Future<AiFarmerServiceRequestRow> declineTechnicianJobRequest(
    String id, {
    String? reason,
  }) async {
    try {
      final res = await _client.post<dynamic>(
        '$_jobRequests/$id/decline',
        data: <String, dynamic>{
          if (reason != null && reason.trim().isNotEmpty)
            'reason': reason.trim(),
        },
      );
      final inner = _unwrap(res);
      final raw = inner['request'];
      if (raw is! Map<String, dynamic>) {
        throw AiTechnicianApiException('অপ্রত্যাশিত উত্তর');
      }
      return AiFarmerServiceRequestRow.fromJson(raw);
    } on AiTechnicianApiException {
      rethrow;
    } on DioException catch (e) {
      throw _mapDio(e);
    }
  }

  Future<AiFarmerServiceRequestRow> postTechnicianJobStatus(
    String id,
    String status,
  ) async {
    try {
      final res = await _client.post<dynamic>(
        '$_jobRequests/$id/status',
        data: <String, dynamic>{'status': status},
      );
      final inner = _unwrap(res);
      final raw = inner['request'];
      if (raw is! Map<String, dynamic>) {
        throw AiTechnicianApiException('অপ্রত্যাশিত উত্তর');
      }
      return AiFarmerServiceRequestRow.fromJson(raw);
    } on AiTechnicianApiException {
      rethrow;
    } on DioException catch (e) {
      throw _mapDio(e);
    }
  }

  Future<({AiFarmerServiceRequestRow request, AiDigitalServiceRecord record})>
  completeTechnicianJobRequest(String id, Map<String, dynamic> body) async {
    try {
      final res = await _client.post<dynamic>(
        '$_jobRequests/$id/complete',
        data: body,
      );
      final inner = _unwrap(res);
      final rawReq = inner['request'];
      final rawRec = inner['record'];
      if (rawReq is! Map<String, dynamic> || rawRec is! Map<String, dynamic>) {
        throw AiTechnicianApiException('অপ্রত্যাশিত উত্তর');
      }
      return (
        request: AiFarmerServiceRequestRow.fromJson(rawReq),
        record: AiDigitalServiceRecord.fromJson(rawRec),
      );
    } on AiTechnicianApiException {
      rethrow;
    } on DioException catch (e) {
      throw _mapDio(e);
    }
  }

  Future<void> patchSettings({required bool acceptsEmergency}) async {
    try {
      final res = await _client.patch<dynamic>(
        _settings,
        data: <String, dynamic>{'acceptsEmergency': acceptsEmergency},
      );
      _unwrap(res);
    } on AiTechnicianApiException {
      rethrow;
    } on DioException catch (e) {
      throw _mapDio(e);
    }
  }

  AiTechnicianApiException _mapDio(DioException e) {
    if (e.response?.data is Map<String, dynamic>) {
      final data = e.response!.data as Map<String, dynamic>;
      if (data['ok'] == false && data['error'] is Map) {
        final err = data['error'] as Map;
        final rawMsg = err['message'] is String
            ? err['message'] as String
            : 'নেটওয়ার্ক ত্রুটি';
        final code = err['code'] is String ? err['code'] as String : null;
        return AiTechnicianApiException(_messageBn(code, rawMsg), code: code);
      }
    }
    final code = e.response?.statusCode;
    if (code == 401) {
      return AiTechnicianApiException(
        'লগইন প্রয়োজন বা সেশন শেষ',
        code: 'UNAUTHORIZED',
      );
    }
    if (code == 403) {
      return AiTechnicianApiException('অনুমতি নেই', code: 'FORBIDDEN');
    }
    if (code == 404) {
      return AiTechnicianApiException(
        'সেবাটি খুঁজে পাওয়া যায়নি',
        code: 'NOT_FOUND',
      );
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return AiTechnicianApiException(
        'সংযোগ সময় শেষ। আবার চেষ্টা করুন।',
        code: 'TIMEOUT',
      );
    }
    return AiTechnicianApiException(
      'সার্ভারের সাথে যোগাযোগ করা যায়নি।',
      code: 'NETWORK',
    );
  }

  static String _messageBn(String? code, String rawEnglish) {
    switch (code) {
      case 'VALIDATION_ERROR':
        return 'তথ্য গ্রহণযোগ্য নয়। ফর্ম পরীক্ষা করুন।';
      case 'NOT_EDITABLE':
        return 'এই অবস্থায় পরিবর্তন করা যাবে না।';
      case 'NOT_ALLOWED':
        return 'এই ধাপে এই কাজটি করা যাবে না।';
      case 'NOT_PUBLISHED':
        return 'প্রকাশিত প্রোফাইলের পরেই সেটিং পরিবর্তন করা যাবে।';
      case 'EMAIL_IN_USE':
        return 'এই ইমেইলটি অন্য অ্যাকাউন্টে ব্যবহৃত।';
      case 'NO_PROFILE':
        return 'প্রথমে আবেদন শুরু করুন।';
      case 'UNAUTHORIZED':
        return 'লগইন প্রয়োজন বা সেশন শেষ।';
      case 'FORBIDDEN':
        return 'অনুমতি নেই।';
      case 'NOT_FOUND':
        return 'খুঁজে পাওয়া যায়নি।';
      case 'DATABASE_ERROR':
        return 'সংরক্ষণ করা যায়নি। পরে চেষ্টা করুন।';
      case 'AREA_MISMATCH':
        return 'এই এলাকার অনুরোধ নয়।';
      case 'INVALID_STATUS':
        return 'এই অবস্থায় কাজটি করা যাবে না।';
      case 'INVALID_TRANSITION':
        return 'পরবর্তী ধাপে যাওয়া যাবে না।';
      case 'ALREADY_COMPLETED':
        return 'ইতিমধ্যে সম্পন্ন।';
      case 'INVALID_FEE':
        return 'ফি সঠিক নয়।';
      case 'DISPLAY_NAME_REQUIRED':
        return 'প্রদর্শন নাম প্রয়োজন।';
      case 'DISTRICT_UPAZILA_REQUIRED':
        return 'জেলা ও উপজেলা পূরণ করুন।';
      case 'SERVICE_AREA_REQUIRED':
        return 'কমপক্ষে একটি সেবা এলাকা যোগ করুন।';
      case 'NID_DOCUMENTS_REQUIRED':
        return 'জাতীয় পরিচয়পত্রের সামনে ও পিছনের ছবি বা নথি প্রয়োজন।';
      case 'INVALID_LOCATION':
        return 'নির্বাচিত লোকেশন সঠিক নয়।';
      case 'UPLOAD_NOT_FOUND':
        return 'আপলোড করা ফাইল খুঁজে পাওয়া যায়নি।';
      case 'UPLOAD_PURPOSE_MISMATCH':
        return 'ফাইলের উদ্দেশ্য নথির ধরনের সাথে মিলছে না।';
      default:
        break;
    }
    return rawEnglish.trim().isNotEmpty ? rawEnglish : 'অনুরোধ ব্যর্থ হয়েছে';
  }
}

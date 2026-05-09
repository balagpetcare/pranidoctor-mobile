import 'package:dio/dio.dart';

import 'package:pranidoctor_mobile/src/core/network/api_client.dart';
import 'package:pranidoctor_mobile/src/features/providers/data/provider_list_query.dart';
import 'package:pranidoctor_mobile/src/features/providers/data/provider_models.dart';

class ProviderApiException implements Exception {
  ProviderApiException(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => message;
}

class ProviderFinderRepository {
  ProviderFinderRepository(this._client);

  final ApiClient _client;

  /// Drops unknown [areaSlug] values so API requests stay valid (matches filter UI).
  static const Set<String> _allowedAreaSlugs = {'ashulia-union-area'};

  static ProviderListQuery _coerceQuery(ProviderListQuery q) {
    final slug = q.areaSlug;
    if (slug != null && slug.isNotEmpty && !_allowedAreaSlugs.contains(slug)) {
      return q.withFilters(clearAreaSlug: true, keepOffset: true);
    }
    return q;
  }

  Map<String, dynamic> _unwrap(Response<dynamic> response) {
    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw ProviderApiException('অপ্রত্যাশিত উত্তর');
    }
    if (data['ok'] != true) {
      final err = data['error'];
      final msg = err is Map && err['message'] is String
          ? err['message'] as String
          : 'অনুরোধ ব্যর্থ হয়েছে';
      final code = err is Map && err['code'] is String
          ? err['code'] as String
          : null;
      throw ProviderApiException(msg, code: code);
    }
    final inner = data['data'];
    if (inner is! Map<String, dynamic>) {
      throw ProviderApiException('অপ্রত্যাশিত উত্তর');
    }
    return inner;
  }

  Future<({List<DoctorSummary> doctors, PaginationInfo pagination})>
  listDoctors(ProviderListQuery query) async {
    final q = ProviderFinderRepository._coerceQuery(query);
    try {
      final res = await _client.get<dynamic>(
        '/api/mobile/providers/doctors',
        queryParameters: q.toQueryParameters(),
      );
      final inner = _unwrap(res);
      final rawList = inner['doctors'];
      final rawPag = inner['pagination'];
      if (rawList is! List<dynamic>) {
        throw ProviderApiException('অপ্রত্যাশিত উত্তর');
      }
      final doctors = rawList
          .map((e) => DoctorSummary.fromJson(e as Map<String, dynamic>))
          .toList();
      final pagination = rawPag is Map<String, dynamic>
          ? PaginationInfo.fromJson(rawPag)
          : const PaginationInfo(
              limit: 20,
              offset: 0,
              total: 0,
              hasMore: false,
            );
      return (doctors: doctors, pagination: pagination);
    } on DioException catch (e) {
      throw _mapDio(e);
    }
  }

  Future<({List<TechnicianSummary> technicians, PaginationInfo pagination})>
  listTechnicians(ProviderListQuery query) async {
    final q = ProviderFinderRepository._coerceQuery(query);
    try {
      final res = await _client.get<dynamic>(
        '/api/mobile/providers/technicians',
        queryParameters: q.toQueryParameters(),
      );
      final inner = _unwrap(res);
      final rawList = inner['technicians'];
      final rawPag = inner['pagination'];
      if (rawList is! List<dynamic>) {
        throw ProviderApiException('অপ্রত্যাশিত উত্তর');
      }
      final technicians = rawList
          .map((e) => TechnicianSummary.fromJson(e as Map<String, dynamic>))
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
    } on DioException catch (e) {
      throw _mapDio(e);
    }
  }

  Future<DoctorDetail> getDoctor(String id) async {
    try {
      final res = await _client.get<dynamic>(
        '/api/mobile/providers/doctors/$id',
      );
      final inner = _unwrap(res);
      final raw = inner['doctor'];
      if (raw is! Map<String, dynamic>) {
        throw ProviderApiException('অপ্রত্যাশিত উত্তর');
      }
      return DoctorDetail.fromJson(raw);
    } on DioException catch (e) {
      throw _mapDio(e);
    }
  }

  Future<TechnicianDetail> getTechnician(String id) async {
    try {
      final res = await _client.get<dynamic>(
        '/api/mobile/providers/technicians/$id',
      );
      final inner = _unwrap(res);
      final raw = inner['technician'];
      if (raw is! Map<String, dynamic>) {
        throw ProviderApiException('অপ্রত্যাশিত উত্তর');
      }
      return TechnicianDetail.fromJson(raw);
    } on DioException catch (e) {
      throw _mapDio(e);
    }
  }

  ProviderApiException _mapDio(DioException e) {
    if (e.response?.data is Map<String, dynamic>) {
      final data = e.response!.data as Map<String, dynamic>;
      if (data['ok'] == false && data['error'] is Map) {
        final err = data['error'] as Map;
        final msg = err['message'] is String
            ? err['message'] as String
            : 'নেটওয়ার্ক ত্রুটি';
        final code = err['code'] is String ? err['code'] as String : null;
        return ProviderApiException(msg, code: code);
      }
    }
    final code = e.response?.statusCode;
    if (code == 401) {
      return ProviderApiException(
        'লগইন প্রয়োজন বা সেশন শেষ',
        code: 'UNAUTHORIZED',
      );
    }
    if (code == 403) {
      return ProviderApiException('অনুমতি নেই', code: 'FORBIDDEN');
    }
    if (code == 404) {
      return ProviderApiException('খুঁজে পাওয়া যায়নি', code: 'NOT_FOUND');
    }
    return ProviderApiException(e.message ?? 'সংযোগ ত্রুটি', code: 'NETWORK');
  }
}

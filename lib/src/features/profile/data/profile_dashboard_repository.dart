import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:pranidoctor_mobile/src/core/network/api_client.dart';
import 'package:pranidoctor_mobile/src/features/profile/data/dashboard_context_models.dart';
import 'package:pranidoctor_mobile/src/features/profile/data/profile_api_exception.dart';

const _kDashboardContextPath = '/api/mobile/profile/dashboard-context';

abstract class ProfileDashboardRepository {
  Future<DashboardContext> fetchDashboardContext();
}

class ProfileDashboardRepositoryLive implements ProfileDashboardRepository {
  ProfileDashboardRepositoryLive(this._client);

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
  Future<DashboardContext> fetchDashboardContext() async {
    try {
      final res = await _client.get<dynamic>(_kDashboardContextPath);
      assert(() {
        debugPrint(
          '[PraniDoctor][auth] GET $_kDashboardContextPath HTTP ${res.statusCode ?? '?'}',
        );
        return true;
      }());
      final inner = _unwrap(res);
      return DashboardContext.fromJson(inner);
    } on DioException catch (e, st) {
      assert(() {
        debugPrint(
          'ProfileDashboardRepository.fetchDashboardContext DioException: $e\n$st',
        );
        return true;
      }());
      final code = e.response?.statusCode;
      final body = e.response?.data;
      String? apiCode;
      String message = 'ড্যাশবোর্ড তথ্য লোড করা যায়নি';
      if (body is Map<String, dynamic> && body['ok'] == false) {
        final err = body['error'];
        if (err is Map && err['message'] is String) {
          message = err['message'] as String;
        }
        if (err is Map && err['code'] is String) {
          apiCode = err['code'] as String;
        }
      }
      throw ProfileApiException(message, code: apiCode ?? (code?.toString()));
    }
  }
}

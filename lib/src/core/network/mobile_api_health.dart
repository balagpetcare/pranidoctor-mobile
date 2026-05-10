import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_client.dart';

final mobileApiHealthProvider = Provider<MobileApiHealth>((ref) {
  return MobileApiHealth(ref.watch(apiClientProvider));
});

/// Lightweight [GET /api/mobile/health] helper for connectivity checks.
class MobileApiHealth {
  MobileApiHealth(this._client);

  final ApiClient _client;

  /// Returns `true` when the server responds successfully to the health route.
  Future<bool> checkHealth({
    Duration timeout = const Duration(seconds: 8),
  }) async {
    try {
      final res = await _client
          .get<dynamic>('/api/mobile/health')
          .timeout(timeout);
      final data = res.data;
      if (data is Map<String, dynamic>) {
        if (data['ok'] == true) return true;
        final inner = data['data'];
        if (inner is Map && inner['status'] == 'ok') return true;
      }
      final code = res.statusCode;
      return code != null && code >= 200 && code < 300;
    } on DioException {
      return false;
    } catch (_) {
      return false;
    }
  }
}

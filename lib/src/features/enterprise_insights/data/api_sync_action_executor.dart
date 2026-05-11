import 'dart:convert';

import 'package:dio/dio.dart';

import 'package:pranidoctor_mobile/src/core/network/api_client.dart';
import 'package:pranidoctor_mobile/src/features/enterprise_insights/application/sync_action_executor_port.dart';
import 'package:pranidoctor_mobile/src/features/enterprise_insights/domain/sync_outbox_action.dart';

/// Dispatches outbox payloads to REST using [ApiClient] (Dio).
///
/// Payload contract (JSON):
/// - `path` (required): absolute path on the mobile API host, e.g. `/api/mobile/me`
/// - `httpMethod` (optional): `GET` | `POST` | `PATCH` | `DELETE` (default `POST`)
/// - `body` (optional): JSON object for write verbs
///
/// Repositories should enqueue fully-formed payloads so execution stays stateless.
class ApiSyncActionExecutor implements SyncActionExecutorPort {
  ApiSyncActionExecutor(this._api);

  final ApiClient _api;

  @override
  Future<SyncExecutionResult> execute(SyncOutboxAction action) async {
    Map<String, dynamic>? map;
    try {
      final decoded = jsonDecode(action.payloadJson);
      if (decoded is Map<String, dynamic>) {
        map = decoded;
      } else if (decoded is Map) {
        map = Map<String, dynamic>.from(decoded);
      }
    } catch (_) {
      return const SyncExecutionResult.giveUp('payload_json_invalid');
    }
    if (map == null) {
      return const SyncExecutionResult.giveUp('payload_not_object');
    }

    final pathRaw = map['path'];
    final path = pathRaw is String ? pathRaw.trim() : '';
    if (path.isEmpty || !path.startsWith('/') || path.contains('..')) {
      return const SyncExecutionResult.giveUp('path_missing_or_unsafe');
    }

    final method =
        (map['httpMethod'] as String?)?.trim().toUpperCase() ?? 'POST';
    final body = map['body'];

    try {
      final Response<dynamic> res;
      switch (method) {
        case 'GET':
          res = await _api.get<dynamic>(path);
          break;
        case 'POST':
          res = await _api.post<dynamic>(path, data: body);
          break;
        case 'PATCH':
          res = await _api.patch<dynamic>(path, data: body);
          break;
        case 'DELETE':
          res = await _api.delete<dynamic>(path, data: body);
          break;
        default:
          return SyncExecutionResult.giveUp('unsupported_method_$method');
      }

      final ok = _responseAcceptable(res);
      if (ok) {
        return const SyncExecutionResult.ok();
      }
      final code = res.statusCode ?? 0;
      if (_retryableStatus(code)) {
        return SyncExecutionResult.retryLater('http_$code');
      }
      return SyncExecutionResult.giveUp('http_$code');
    } on DioException catch (e) {
      final code = e.response?.statusCode ?? 0;
      if (_dioRetryable(e)) {
        return SyncExecutionResult.retryLater(
          e.message ?? 'dio_retryable',
        );
      }
      if (code == 401 || code == 403) {
        return SyncExecutionResult.giveUp('auth_$code');
      }
      if (code == 404 || code == 405) {
        return SyncExecutionResult.giveUp('client_$code');
      }
      if (code >= 400 && code < 500) {
        return SyncExecutionResult.giveUp('client_$code');
      }
      return SyncExecutionResult.retryLater(e.message ?? 'dio_error');
    }
  }

  bool _responseAcceptable(Response<dynamic> res) {
    final code = res.statusCode ?? 0;
    if (code == 204) return true;
    if (code >= 200 && code < 300) {
      final data = res.data;
      if (data is Map && data['ok'] == false) {
        return false;
      }
      return true;
    }
    return false;
  }

  bool _retryableStatus(int code) {
    return code == 408 ||
        code == 429 ||
        code == 502 ||
        code == 503 ||
        code == 504 ||
        code == 0;
  }

  bool _dioRetryable(DioException e) {
    return e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.unknown;
  }
}

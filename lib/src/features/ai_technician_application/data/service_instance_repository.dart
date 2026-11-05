import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pranidoctor_mobile/src/core/network/api_client.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/data/ai_technician_api_exception.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/data/service_instance_models.dart';

final serviceInstanceRepositoryProvider = Provider<ServiceInstanceRepository>((ref) {
  return ServiceInstanceRepository(ref.watch(apiClientProvider));
});

class ServiceInstanceRepository {
  ServiceInstanceRepository(this._client);

  final ApiClient _client;

  static const _base = '/api/mobile/ai-technician/service-instances';

  Map<String, dynamic> _unwrap(Response<dynamic> response) {
    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw AiTechnicianApiException('অপ্রত্যাশিত উত্তর');
    }
    if (data['ok'] != true) {
      final err = data['error'];
      final msg = err is Map && err['message'] is String
          ? err['message'] as String
          : 'অনুরোধ ব্যর্থ';
      final code = err is Map && err['code'] is String ? err['code'] as String? : null;
      throw AiTechnicianApiException(msg, code: code);
    }
    final inner = data['data'];
    if (inner is! Map<String, dynamic>) {
      throw AiTechnicianApiException('অপ্রত্যাশিত উত্তর');
    }
    return inner;
  }

  Future<({List<ServiceInstanceListItem> items, String? nextCursor})> list({
    String? status,
    String? deploymentBranch,
    String? cursor,
  }) async {
    final qp = <String, dynamic>{};
    if (status != null) qp['status'] = status;
    if (deploymentBranch != null) qp['deploymentBranch'] = deploymentBranch;
    if (cursor != null) qp['cursor'] = cursor;
    final res = await _client.get<dynamic>(_base, queryParameters: qp);
    final inner = _unwrap(res);
    final raw = inner['items'] as List<dynamic>? ?? [];
    final items = raw
        .map((e) => ServiceInstanceListItem.fromJson(e as Map<String, dynamic>))
        .toList();
    final next = inner['nextCursor'] as String?;
    return (items: items, nextCursor: next);
  }

  Future<Map<String, dynamic>> detail(String id) async {
    final res = await _client.get<dynamic>('$_base/$id');
    return _unwrap(res);
  }

  Future<String> create({
    required String templateId,
    Map<String, dynamic>? payload,
    String? deploymentBranch,
  }) async {
    final res = await _client.post<dynamic>(
      _base,
      data: {
        'semenServiceTemplateId': templateId,
        if (payload != null) 'payload': payload,
        if (deploymentBranch != null) 'deploymentBranch': deploymentBranch,
      },
    );
    final inner = _unwrap(res);
    return inner['id'] as String;
  }

  Future<void> update(
    String id, {
    Map<String, dynamic>? payload,
    List<Map<String, dynamic>>? media,
    int? expectedVersion,
  }) async {
    final body = <String, dynamic>{};
    if (payload != null) body['payload'] = payload;
    if (media != null) body['media'] = media;
    if (expectedVersion != null) body['expectedVersion'] = expectedVersion;
    final res = await _client.put<dynamic>('$_base/$id', data: body);
    _unwrap(res);
  }

  Future<void> submit(String id) async {
    final res = await _client.post<dynamic>('$_base/$id/submit');
    _unwrap(res);
  }
}

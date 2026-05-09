import 'package:dio/dio.dart';

import 'package:pranidoctor_mobile/src/core/network/api_client.dart';
import 'package:pranidoctor_mobile/src/features/notifications/data/notification_model.dart';

class NotificationApiException implements Exception {
  NotificationApiException(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => message;
}

typedef NotificationsPageData = ({List<AppNotification> items, int total});

class NotificationRepository {
  NotificationRepository(this._client);

  final ApiClient _client;

  static const String _basePath = '/api/mobile/notifications';

  Map<String, dynamic> _unwrap(Response<dynamic> response) {
    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw NotificationApiException('অপ্রত্যাশিত উত্তর');
    }
    if (data['ok'] != true) {
      final err = data['error'];
      final msg = err is Map && err['message'] is String
          ? err['message'] as String
          : 'অনুরোধ ব্যর্থ হয়েছে';
      final code = err is Map && err['code'] is String
          ? err['code'] as String
          : null;
      throw NotificationApiException(msg, code: code);
    }
    final inner = data['data'];
    if (inner is! Map<String, dynamic>) {
      throw NotificationApiException('অপ্রত্যাশিত উত্তর');
    }
    return inner;
  }

  Future<NotificationsPageData> list({
    int limit = 50,
    int offset = 0,
    bool unreadOnly = false,
  }) async {
    try {
      final res = await _client.get<dynamic>(
        _basePath,
        queryParameters: <String, dynamic>{
          'limit': limit.toString(),
          'offset': offset.toString(),
          'unreadOnly': unreadOnly ? 'true' : 'false',
        },
      );
      final inner = _unwrap(res);
      final raw = inner['items'];
      if (raw is! List<dynamic>) {
        throw NotificationApiException('অপ্রত্যাশিত উত্তর');
      }
      final total = (inner['total'] as num?)?.toInt() ?? raw.length;
      final items = raw
          .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
          .toList();
      return (items: items, total: total);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return (items: <AppNotification>[], total: 0);
      }
      throw _mapDio(e);
    }
  }

  Future<void> markRead(String id) async {
    try {
      final res = await _client.patch<dynamic>('$_basePath/$id/read');
      _unwrap(res);
    } on DioException catch (e) {
      throw _mapDio(e);
    }
  }

  Future<int> markAllRead() async {
    try {
      final res = await _client.patch<dynamic>('$_basePath/read-all');
      final inner = _unwrap(res);
      final n = inner['updatedCount'];
      if (n is num) return n.toInt();
      return 0;
    } on DioException catch (e) {
      throw _mapDio(e);
    }
  }

  NotificationApiException _mapDio(DioException e) {
    if (e.response?.data is Map<String, dynamic>) {
      final data = e.response!.data as Map<String, dynamic>;
      if (data['ok'] == false && data['error'] is Map) {
        final err = data['error'] as Map;
        final msg = err['message'] is String
            ? err['message'] as String
            : 'নেটওয়ার্ক ত্রুটি';
        final code = err['code'] is String ? err['code'] as String : null;
        return NotificationApiException(msg, code: code);
      }
    }
    final code = e.response?.statusCode;
    if (code == 401) {
      return NotificationApiException(
        'লগইন প্রয়োজন বা সেশন শেষ',
        code: 'UNAUTHORIZED',
      );
    }
    if (code == 403) {
      return NotificationApiException('অনুমতি নেই', code: 'FORBIDDEN');
    }
    if (code == 404) {
      return NotificationApiException('খুঁজে পাওয়া যায়নি', code: 'NOT_FOUND');
    }
    return NotificationApiException(
      e.message ?? 'সংযোগ ত্রুটি',
      code: 'NETWORK',
    );
  }
}

import 'package:dio/dio.dart';

import 'package:pranidoctor_mobile/src/core/network/api_client.dart';
import 'package:pranidoctor_mobile/src/features/tutorials/data/tutorial_models.dart';

class TutorialApiException implements Exception {
  TutorialApiException(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => message;
}

class TutorialRepository {
  TutorialRepository(this._client);

  final ApiClient _client;

  Map<String, dynamic> _unwrap(Response<dynamic> response) {
    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw TutorialApiException('অপ্রত্যাশিত উত্তর');
    }
    if (data['ok'] != true) {
      final err = data['error'];
      final msg = err is Map && err['message'] is String
          ? err['message'] as String
          : 'অনুরোধ ব্যর্থ হয়েছে';
      final code = err is Map && err['code'] is String
          ? err['code'] as String
          : null;
      throw TutorialApiException(msg, code: code);
    }
    final inner = data['data'];
    if (inner is! Map<String, dynamic>) {
      throw TutorialApiException('অপ্রত্যাশিত উত্তর');
    }
    return inner;
  }

  Future<List<TutorialCategory>> listCategories() async {
    try {
      final res = await _client.get<dynamic>(
        '/api/mobile/tutorials/categories',
      );
      final inner = _unwrap(res);
      final raw = inner['categories'];
      if (raw is! List<dynamic>) {
        throw TutorialApiException('অপ্রত্যাশিত উত্তর');
      }
      return raw
          .map((e) => TutorialCategory.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _mapDio(e);
    }
  }

  Future<({List<TutorialListItem> tutorials, int total})>
  listPublishedTutorials({
    String? categoryId,
    String? categorySlug,
    int take = 50,
    int skip = 0,
  }) async {
    if (categoryId != null && categorySlug != null) {
      throw TutorialApiException(
        'ভুল অনুরোধ: একসাথে categoryId ও categorySlug পাঠানো যাবে না',
      );
    }
    final qp = <String, dynamic>{'take': take, 'skip': skip};
    if (categoryId != null) qp['categoryId'] = categoryId;
    if (categorySlug != null) qp['categorySlug'] = categorySlug;

    try {
      final res = await _client.get<dynamic>(
        '/api/mobile/tutorials',
        queryParameters: qp,
      );
      final inner = _unwrap(res);
      final rawList = inner['tutorials'];
      final total = inner['total'];
      if (rawList is! List<dynamic>) {
        throw TutorialApiException('অপ্রত্যাশিত উত্তর');
      }
      final tutorials = rawList
          .map((e) => TutorialListItem.fromJson(e as Map<String, dynamic>))
          .toList();
      final n = total is int
          ? total
          : int.tryParse('$total') ?? tutorials.length;
      return (tutorials: tutorials, total: n);
    } on DioException catch (e) {
      throw _mapDio(e);
    }
  }

  Future<TutorialDetail> getPublishedTutorial(String slugOrId) async {
    final encoded = Uri.encodeComponent(slugOrId);
    try {
      final res = await _client.get<dynamic>('/api/mobile/tutorials/$encoded');
      final inner = _unwrap(res);
      final raw = inner['tutorial'];
      if (raw is! Map<String, dynamic>) {
        throw TutorialApiException('অপ্রত্যাশিত উত্তর');
      }
      return TutorialDetail.fromJson(raw);
    } on DioException catch (e) {
      throw _mapDio(e);
    }
  }

  TutorialApiException _mapDio(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return TutorialApiException('সংযোগের সময় শেষ — আবার চেষ্টা করুন');
    }
    if (e.type == DioExceptionType.connectionError) {
      return TutorialApiException(
        'ইন্টারনেট সংযোগ নেই বা সার্ভার খুঁজে পাওয়া যায়নি',
      );
    }
    final status = e.response?.statusCode;
    if (status == 404) {
      return TutorialApiException(
        'টিউটোরিয়াল পাওয়া যায়নি',
        code: 'NOT_FOUND',
      );
    }
    return TutorialApiException('লোড করা যায়নি — আবার চেষ্টা করুন');
  }
}

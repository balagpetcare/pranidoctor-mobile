import 'package:dio/dio.dart';

import 'package:pranidoctor_mobile/src/core/network/api_client.dart';
import 'package:pranidoctor_mobile/src/features/knowledge_hub/data/knowledge_models.dart';

class KnowledgeApiException implements Exception {
  KnowledgeApiException(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => message;
}

/// Knowledge hub reads — tries `/api/mobile/content/*`, falls back to `/api/mobile/tutorials/*`.
abstract class KnowledgeRepository {
  Future<List<KnowledgeCategory>> listCategories();

  Future<({List<KnowledgePost> posts, int total})> listPosts({
    String? categoryId,
    String? categorySlug,
    int take,
    int skip,
  });

  Future<KnowledgePostDetail> getPost(String slugOrId);
}

class KnowledgeRepositoryLive implements KnowledgeRepository {
  KnowledgeRepositoryLive(this._client);

  final ApiClient _client;

  Map<String, dynamic> _unwrap(Response<dynamic> response) {
    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw KnowledgeApiException('অপ্রত্যাশিত উত্তর');
    }
    if (data['ok'] != true) {
      final err = data['error'];
      final msg = err is Map && err['message'] is String
          ? err['message'] as String
          : 'অনুরোধ ব্যর্থ হয়েছে';
      final code = err is Map && err['code'] is String
          ? err['code'] as String
          : null;
      throw KnowledgeApiException(msg, code: code);
    }
    final inner = data['data'];
    if (inner is! Map<String, dynamic>) {
      throw KnowledgeApiException('অপ্রত্যাশিত উত্তর');
    }
    return inner;
  }

  bool _is404(DioException e) => e.response?.statusCode == 404;

  @override
  Future<List<KnowledgeCategory>> listCategories() async {
    try {
      final res = await _client.get<dynamic>('/api/mobile/content/categories');
      final inner = _unwrap(res);
      final raw = inner['categories'];
      if (raw is! List<dynamic>) {
        throw KnowledgeApiException('অপ্রত্যাশিত উত্তর');
      }
      return raw
          .map((e) => KnowledgeCategory.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      if (_is404(e)) return _listCategoriesTutorials();
      throw _mapDio(e);
    } on KnowledgeApiException {
      rethrow;
    }
  }

  Future<List<KnowledgeCategory>> _listCategoriesTutorials() async {
    try {
      final res = await _client.get<dynamic>(
        '/api/mobile/tutorials/categories',
      );
      final inner = _unwrap(res);
      final raw = inner['categories'];
      if (raw is! List<dynamic>) {
        throw KnowledgeApiException('অপ্রত্যাশিত উত্তর');
      }
      return raw
          .map((e) => KnowledgeCategory.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _mapDio(e);
    }
  }

  @override
  Future<({List<KnowledgePost> posts, int total})> listPosts({
    String? categoryId,
    String? categorySlug,
    int take = 50,
    int skip = 0,
  }) async {
    if (categoryId != null && categorySlug != null) {
      throw KnowledgeApiException(
        'ভুল অনুরোধ: একসাথে categoryId ও categorySlug পাঠানো যাবে না',
      );
    }
    final qp = <String, dynamic>{'take': take, 'skip': skip};
    if (categoryId != null) qp['categoryId'] = categoryId;
    if (categorySlug != null) qp['categorySlug'] = categorySlug;

    try {
      final res = await _client.get<dynamic>(
        '/api/mobile/content/posts',
        queryParameters: qp,
      );
      final inner = _unwrap(res);
      return _parsePostPage(inner);
    } on DioException catch (e) {
      if (_is404(e)) return _listPostsTutorials(qp);
      throw _mapDio(e);
    }
  }

  Future<({List<KnowledgePost> posts, int total})> _listPostsTutorials(
    Map<String, dynamic> qp,
  ) async {
    try {
      final res = await _client.get<dynamic>(
        '/api/mobile/tutorials',
        queryParameters: qp,
      );
      final inner = _unwrap(res);
      return _parsePostPageFromTutorials(inner);
    } on DioException catch (e) {
      throw _mapDio(e);
    }
  }

  ({List<KnowledgePost> posts, int total}) _parsePostPage(
    Map<String, dynamic> inner,
  ) {
    final rawList = inner['posts'] ?? inner['items'] ?? inner['tutorials'];
    final total = inner['total'];
    if (rawList is! List<dynamic>) {
      throw KnowledgeApiException('অপ্রত্যাশিত উত্তর');
    }
    final posts = rawList
        .map((e) => KnowledgePost.fromJson(e as Map<String, dynamic>))
        .toList();
    final n = total is int ? total : int.tryParse('$total') ?? posts.length;
    return (posts: posts, total: n);
  }

  ({List<KnowledgePost> posts, int total}) _parsePostPageFromTutorials(
    Map<String, dynamic> inner,
  ) {
    final rawList = inner['tutorials'];
    final total = inner['total'];
    if (rawList is! List<dynamic>) {
      throw KnowledgeApiException('অপ্রত্যাশিত উত্তর');
    }
    final posts = rawList
        .map((e) => KnowledgePost.fromJson(e as Map<String, dynamic>))
        .toList();
    final n = total is int ? total : int.tryParse('$total') ?? posts.length;
    return (posts: posts, total: n);
  }

  @override
  Future<KnowledgePostDetail> getPost(String slugOrId) async {
    final encoded = Uri.encodeComponent(slugOrId);
    try {
      final res = await _client.get<dynamic>(
        '/api/mobile/content/posts/$encoded',
      );
      final inner = _unwrap(res);
      final raw = inner['post'] ?? inner['item'] ?? inner['tutorial'];
      if (raw is! Map<String, dynamic>) {
        throw KnowledgeApiException('অপ্রত্যাশিত উত্তর');
      }
      return KnowledgePostDetail.fromJson(raw);
    } on DioException catch (e) {
      if (_is404(e)) return _getPostTutorials(encoded);
      throw _mapDio(e);
    }
  }

  Future<KnowledgePostDetail> _getPostTutorials(String encoded) async {
    try {
      final res = await _client.get<dynamic>('/api/mobile/tutorials/$encoded');
      final inner = _unwrap(res);
      final raw = inner['tutorial'];
      if (raw is! Map<String, dynamic>) {
        throw KnowledgeApiException('অপ্রত্যাশিত উত্তর');
      }
      return KnowledgePostDetail.fromJson(raw);
    } on DioException catch (e) {
      throw _mapDio(e);
    }
  }

  KnowledgeApiException _mapDio(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return KnowledgeApiException('সংযোগের সময় শেষ — আবার চেষ্টা করুন');
    }
    if (e.type == DioExceptionType.connectionError) {
      return KnowledgeApiException(
        'ইন্টারনেট সংযোগ নেই বা সার্ভার খুঁজে পাওয়া যায়নি',
      );
    }
    final status = e.response?.statusCode;
    if (status == 404) {
      return KnowledgeApiException('লেখা পাওয়া যায়নি', code: 'NOT_FOUND');
    }
    return KnowledgeApiException('লোড করা যায়নি — আবার চেষ্টা করুন');
  }
}

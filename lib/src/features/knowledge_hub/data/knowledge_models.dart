String? _str(Map<String, dynamic> json, List<String> keys) {
  for (final k in keys) {
    final v = json[k];
    if (v is String && v.isNotEmpty) return v;
  }
  return null;
}

String _strReq(
  Map<String, dynamic> json,
  List<String> keys, [
  String fallback = '',
]) {
  return _str(json, keys) ?? fallback;
}

DateTime? _parseDate(dynamic v) {
  if (v == null) return null;
  if (v is String) return DateTime.tryParse(v);
  return null;
}

bool _bool(dynamic v) {
  if (v is bool) return v;
  if (v is String) return v.toLowerCase() == 'true';
  return false;
}

int? _int(dynamic v) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v);
  return null;
}

/// Accepts string body/content or numeric/other scalar (never throws on shape).
String _coerceBodyText(Map<String, dynamic> json) {
  const keys = ['body', 'content', 'htmlBody', 'text', 'markdown'];
  for (final k in keys) {
    final v = json[k];
    if (v == null) continue;
    if (v is String) return v;
    if (v is num || v is bool) return '$v';
  }
  return '';
}

/// Category for Knowledge Hub (flexible JSON from `/content` or `/tutorials`).
class KnowledgeCategory {
  const KnowledgeCategory({
    required this.id,
    required this.nameBn,
    this.nameEn,
    required this.slug,
    this.description,
    this.sortOrder,
    this.type,
  });

  final String id;
  final String nameBn;
  final String? nameEn;
  final String slug;
  final String? description;
  final int? sortOrder;
  final String? type;

  factory KnowledgeCategory.fromJson(Map<String, dynamic> json) {
    return KnowledgeCategory(
      id: _strReq(json, const ['id']),
      nameBn: _strReq(json, const [
        'nameBn',
        'name_bn',
        'titleBn',
        'title',
        'name',
      ]),
      nameEn: _str(json, const ['nameEn', 'name_en']),
      slug: _strReq(json, const ['slug'], 'item'),
      description: _str(json, const ['description', 'summary']),
      sortOrder: _int(json['sortOrder'] ?? json['sort_order']),
      type: _str(json, const ['type', 'contentType', 'content_type']),
    );
  }
}

/// Nested category on a post (minimal fields).
class KnowledgeCategoryRef {
  const KnowledgeCategoryRef({
    required this.id,
    required this.nameBn,
    this.nameEn,
    required this.slug,
  });

  final String id;
  final String nameBn;
  final String? nameEn;
  final String slug;

  factory KnowledgeCategoryRef.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const KnowledgeCategoryRef(id: '', nameBn: '—', slug: '');
    }
    return KnowledgeCategoryRef(
      id: _strReq(json, const ['id']),
      nameBn: _strReq(json, const ['nameBn', 'name_bn', 'name', 'title']),
      nameEn: _str(json, const ['nameEn', 'name_en']),
      slug: _strReq(json, const ['slug'], ''),
    );
  }

  factory KnowledgeCategoryRef.fromFlat(
    String? categoryId,
    String? categoryName,
  ) {
    final id = categoryId ?? '';
    final name = categoryName ?? '';
    return KnowledgeCategoryRef(
      id: id,
      nameBn: name.isNotEmpty ? name : '—',
      slug: id,
    );
  }
}

class KnowledgeAuthor {
  const KnowledgeAuthor({required this.userId, this.role, this.displayName});

  final String userId;
  final String? role;
  final String? displayName;

  factory KnowledgeAuthor.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const KnowledgeAuthor(userId: '');
    return KnowledgeAuthor(
      userId: _strReq(json, const ['userId', 'id']),
      role: _str(json, const ['role']),
      displayName: _str(json, const ['displayName', 'name', 'fullName']),
    );
  }
}

/// List row / card model for a knowledge post or tutorial.
class KnowledgePost {
  const KnowledgePost({
    required this.id,
    required this.title,
    required this.slug,
    this.summary,
    this.coverImageUrl,
    this.publishedAt,
    required this.category,
    required this.author,
    this.type,
    this.isFeatured = false,
    this.readTimeMinutes,
  });

  final String id;
  final String title;
  final String slug;
  final String? summary;
  final String? coverImageUrl;
  final DateTime? publishedAt;
  final KnowledgeCategoryRef category;
  final KnowledgeAuthor author;
  final String? type;
  final bool isFeatured;
  final int? readTimeMinutes;

  /// Route key: prefer slug when non-empty.
  String get navigationKey => slug.trim().isNotEmpty ? slug : id;

  factory KnowledgePost.fromJson(Map<String, dynamic> json) {
    final catMap = json['category'] is Map<String, dynamic>
        ? json['category'] as Map<String, dynamic>
        : null;
    final category = catMap != null
        ? KnowledgeCategoryRef.fromJson(catMap)
        : KnowledgeCategoryRef.fromFlat(
            _str(json, const ['categoryId', 'category_id']),
            _str(json, const [
              'categoryName',
              'category_name',
              'categoryTitle',
            ]),
          );

    final image = _str(json, const [
      'coverImageUrl',
      'cover_image_url',
      'thumbnailUrl',
      'thumbnail_url',
      'imageUrl',
      'image_url',
    ]);

    return KnowledgePost(
      id: _strReq(json, const ['id']),
      title: _strReq(json, const ['title']),
      slug: _strReq(json, const ['slug'], ''),
      summary: _str(json, const [
        'summary',
        'excerpt',
        'description',
        'subtitle',
      ]),
      coverImageUrl: image,
      publishedAt: _parseDate(
        json['publishedAt'] ??
            json['published_at'] ??
            json['createdAt'] ??
            json['created_at'],
      ),
      category: category,
      author: KnowledgeAuthor.fromJson(
        json['author'] is Map<String, dynamic>
            ? json['author'] as Map<String, dynamic>
            : null,
      ),
      type: _str(json, const ['type', 'contentType', 'content_type']),
      isFeatured: _bool(
        json['isFeatured'] ?? json['is_featured'] ?? json['featured'],
      ),
      readTimeMinutes: _int(
        json['readTimeMinutes'] ??
            json['read_time_minutes'] ??
            json['readTime'],
      ),
    );
  }
}

/// Full article for detail screen.
class KnowledgePostDetail {
  const KnowledgePostDetail({
    required this.id,
    required this.title,
    required this.slug,
    this.summary,
    required this.body,
    this.coverImageUrl,
    this.publishedAt,
    required this.category,
    required this.author,
    this.type,
    this.readTimeMinutes,
  });

  final String id;
  final String title;
  final String slug;
  final String? summary;
  final String body;
  final String? coverImageUrl;
  final DateTime? publishedAt;
  final KnowledgeCategoryRef category;
  final KnowledgeAuthor author;
  final String? type;
  final int? readTimeMinutes;

  String get navigationKey => slug.trim().isNotEmpty ? slug : id;

  factory KnowledgePostDetail.fromJson(Map<String, dynamic> json) {
    final body = _coerceBodyText(json);

    final catMap = json['category'] is Map<String, dynamic>
        ? json['category'] as Map<String, dynamic>
        : null;
    final category = catMap != null
        ? KnowledgeCategoryRef.fromJson(catMap)
        : KnowledgeCategoryRef.fromFlat(
            _str(json, const ['categoryId', 'category_id']),
            _str(json, const ['categoryName', 'category_name']),
          );

    final image = _str(json, const [
      'coverImageUrl',
      'cover_image_url',
      'thumbnailUrl',
      'thumbnail_url',
      'imageUrl',
      'image_url',
    ]);

    return KnowledgePostDetail(
      id: _strReq(json, const ['id']),
      title: _strReq(json, const ['title']),
      slug: _strReq(json, const ['slug'], ''),
      summary: _str(json, const ['summary', 'excerpt', 'description']),
      body: body,
      coverImageUrl: image,
      publishedAt: _parseDate(
        json['publishedAt'] ??
            json['published_at'] ??
            json['createdAt'] ??
            json['created_at'],
      ),
      category: category,
      author: KnowledgeAuthor.fromJson(
        json['author'] is Map<String, dynamic>
            ? json['author'] as Map<String, dynamic>
            : null,
      ),
      type: _str(json, const ['type', 'contentType', 'content_type']),
      readTimeMinutes: _int(
        json['readTimeMinutes'] ??
            json['read_time_minutes'] ??
            json['readTime'],
      ),
    );
  }
}

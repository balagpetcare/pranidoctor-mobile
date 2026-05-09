class TutorialCategory {
  const TutorialCategory({
    required this.id,
    required this.nameBn,
    this.nameEn,
    required this.slug,
    this.description,
    this.sortOrder,
  });

  final String id;
  final String nameBn;
  final String? nameEn;
  final String slug;
  final String? description;
  final int? sortOrder;

  factory TutorialCategory.fromJson(Map<String, dynamic> json) {
    return TutorialCategory(
      id: json['id'] as String,
      nameBn: json['nameBn'] as String? ?? '',
      nameEn: json['nameEn'] as String?,
      slug: json['slug'] as String? ?? '',
      description: json['description'] as String?,
      sortOrder: json['sortOrder'] as int?,
    );
  }
}

class TutorialCategoryRef {
  const TutorialCategoryRef({
    required this.id,
    required this.nameBn,
    this.nameEn,
    required this.slug,
  });

  final String id;
  final String nameBn;
  final String? nameEn;
  final String slug;

  factory TutorialCategoryRef.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const TutorialCategoryRef(id: '', nameBn: '—', slug: '');
    }
    return TutorialCategoryRef(
      id: json['id'] as String? ?? '',
      nameBn: json['nameBn'] as String? ?? '',
      nameEn: json['nameEn'] as String?,
      slug: json['slug'] as String? ?? '',
    );
  }
}

class TutorialAuthor {
  const TutorialAuthor({required this.userId, this.role, this.displayName});

  final String userId;
  final String? role;
  final String? displayName;

  factory TutorialAuthor.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const TutorialAuthor(userId: '');
    }
    return TutorialAuthor(
      userId: json['userId'] as String? ?? '',
      role: json['role'] as String?,
      displayName: json['displayName'] as String?,
    );
  }
}

class TutorialListItem {
  const TutorialListItem({
    required this.id,
    required this.title,
    required this.slug,
    this.summary,
    this.coverImageUrl,
    this.publishedAt,
    required this.category,
    required this.author,
  });

  final String id;
  final String title;
  final String slug;
  final String? summary;
  final String? coverImageUrl;
  final DateTime? publishedAt;
  final TutorialCategoryRef category;
  final TutorialAuthor author;

  factory TutorialListItem.fromJson(Map<String, dynamic> json) {
    return TutorialListItem(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      summary: json['summary'] as String?,
      coverImageUrl: json['coverImageUrl'] as String?,
      publishedAt: _parseDateTime(json['publishedAt']),
      category: TutorialCategoryRef.fromJson(
        json['category'] as Map<String, dynamic>?,
      ),
      author: TutorialAuthor.fromJson(json['author'] as Map<String, dynamic>?),
    );
  }
}

class TutorialDetail {
  const TutorialDetail({
    required this.id,
    required this.title,
    required this.slug,
    this.summary,
    required this.body,
    this.coverImageUrl,
    this.publishedAt,
    required this.category,
    required this.author,
  });

  final String id;
  final String title;
  final String slug;
  final String? summary;
  final String body;
  final String? coverImageUrl;
  final DateTime? publishedAt;
  final TutorialCategoryRef category;
  final TutorialAuthor author;

  factory TutorialDetail.fromJson(Map<String, dynamic> json) {
    return TutorialDetail(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      summary: json['summary'] as String?,
      body: json['body'] as String? ?? '',
      coverImageUrl: json['coverImageUrl'] as String?,
      publishedAt: _parseDateTime(json['publishedAt']),
      category: TutorialCategoryRef.fromJson(
        json['category'] as Map<String, dynamic>?,
      ),
      author: TutorialAuthor.fromJson(json['author'] as Map<String, dynamic>?),
    );
  }
}

DateTime? _parseDateTime(dynamic value) {
  if (value == null) return null;
  if (value is String) return DateTime.tryParse(value);
  return null;
}

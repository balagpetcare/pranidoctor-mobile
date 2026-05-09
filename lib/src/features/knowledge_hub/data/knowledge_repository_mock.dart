import 'package:pranidoctor_mobile/src/features/knowledge_hub/data/knowledge_models.dart';
import 'package:pranidoctor_mobile/src/features/knowledge_hub/data/knowledge_repository.dart';

/// Offline / demo posts when `USE_MOCK_KNOWLEDGE_API=true` or for QA without CMS.
class KnowledgeRepositoryMock implements KnowledgeRepository {
  static final List<KnowledgeCategory> _cats = [
    const KnowledgeCategory(
      id: 'mock-1',
      nameBn: 'প্রাণী পরিচর্যা',
      slug: 'animal-care',
      description: 'পোষা প্রাণীর দৈনন্দিন যত্ন ও পুষ্টি।',
    ),
    const KnowledgeCategory(
      id: 'mock-2',
      nameBn: 'জরুরি সেবা',
      slug: 'emergency',
      description: 'জরুরি অবস্থায় করণীয়।',
    ),
    const KnowledgeCategory(
      id: 'mock-3',
      nameBn: 'টিকা',
      slug: 'vaccination',
      description: 'টিকাকরণ সময়সূচি ও গুরুত্ব।',
    ),
    const KnowledgeCategory(
      id: 'mock-4',
      nameBn: 'রোগ সচেতনতা',
      slug: 'disease-awareness',
    ),
    const KnowledgeCategory(
      id: 'mock-5',
      nameBn: 'এআই সেবা শিক্ষা',
      slug: 'ai-service',
    ),
    const KnowledgeCategory(
      id: 'mock-6',
      nameBn: 'ডাক্তার/টেকনিশিয়ান টিউটোরিয়াল',
      slug: 'staff-tutorial',
    ),
    const KnowledgeCategory(
      id: 'mock-7',
      nameBn: 'প্ল্যাটফর্ম ব্যবহার গাইড',
      slug: 'platform-guide',
    ),
  ];

  static KnowledgePost _post(
    String id,
    String slug,
    String title,
    String catId,
    String catBn, {
    bool featured = false,
  }) {
    final cat = KnowledgeCategoryRef(id: catId, nameBn: catBn, slug: catId);
    return KnowledgePost(
      id: id,
      title: title,
      slug: slug,
      summary:
          'এটি নমুনা লেখা — সার্ভার থেকে প্রকৃত নিবন্ধ সংযুক্ত হলে স্বয়ংক্রিয়ভাবে প্রদর্শিত হবে।',
      coverImageUrl: null,
      publishedAt: DateTime(2026, 4, 1),
      category: cat,
      author: const KnowledgeAuthor(
        userId: 'mock',
        displayName: 'প্রাণি ডাক্তার সম্পাদনা',
      ),
      isFeatured: featured,
      readTimeMinutes: 3,
    );
  }

  static final List<KnowledgePost> _posts = [
    _post(
      'p1',
      'mock-featured-care',
      'গরুর শীতকালীন যত্ন — সংক্ষিপ্ত নির্দেশিকা',
      'mock-1',
      'প্রাণী পরিচর্যা',
      featured: true,
    ),
    _post(
      'p2',
      'mock-emergency-bloat',
      'জরুরি: গরুর পেট ফুলে ওঠা',
      'mock-2',
      'জরুরি সেবা',
    ),
    _post(
      'p3',
      'mock-vaccine-fmd',
      'খুরাপেকা রোগের টিকা — মনে রাখার তালিকা',
      'mock-3',
      'টিকা',
    ),
    _post(
      'p4',
      'mock-ai-intro',
      'এআই প্রজনন সেবা — গ্রাহকের জন্য পরিচিতি',
      'mock-5',
      'এআই সেবা শিক্ষা',
    ),
  ];

  static final Map<String, KnowledgePostDetail> _details = {
    for (final p in _posts)
      p.slug: KnowledgePostDetail(
        id: p.id,
        title: p.title,
        slug: p.slug,
        summary: p.summary,
        body:
            '''${p.title}

${p.summary}

এটি অ্যাপের নমুনা বিষয়বস্তু। প্রকৃত সার্ভার থেকে লেখা লোড হলে এই অংশ প্রতিস্থাপিত হবে।

• প্রাণির অবস্থা পর্যবেক্ষণ করুন
• প্রয়োজনে অভিজ্ঞ চিকিৎসকের সাথে যোগাযোগ করুন
• জরুরি ক্ষেত্রে নিকটস্থ ক্লিনিক খুঁজুন

ধন্যবাদ।''',
        coverImageUrl: p.coverImageUrl,
        publishedAt: p.publishedAt,
        category: p.category,
        author: p.author,
        readTimeMinutes: p.readTimeMinutes,
      ),
  };

  @override
  Future<List<KnowledgeCategory>> listCategories() async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    return List<KnowledgeCategory>.from(_cats);
  }

  @override
  Future<({List<KnowledgePost> posts, int total})> listPosts({
    String? categoryId,
    String? categorySlug,
    int take = 50,
    int skip = 0,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    var list = List<KnowledgePost>.from(_posts);
    if (categoryId != null) {
      list = list.where((p) => p.category.id == categoryId).toList();
    } else if (categorySlug != null) {
      KnowledgeCategory? match;
      for (final c in _cats) {
        if (c.slug == categorySlug) {
          match = c;
          break;
        }
      }
      final matched = match;
      if (matched != null) {
        list = list.where((p) => p.category.id == matched.id).toList();
      }
    }
    final slice = list.skip(skip).take(take).toList();
    return (posts: slice, total: list.length);
  }

  @override
  Future<KnowledgePostDetail> getPost(String slugOrId) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    final decoded = Uri.decodeComponent(slugOrId);
    final bySlug = _details[decoded];
    if (bySlug != null) return bySlug;
    for (final p in _posts) {
      if (p.id == decoded || p.slug == decoded) {
        return _details[p.slug]!;
      }
    }
    throw KnowledgeApiException('লেখা পাওয়া যায়নি', code: 'NOT_FOUND');
  }
}

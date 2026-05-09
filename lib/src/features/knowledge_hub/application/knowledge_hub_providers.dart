import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pranidoctor_mobile/src/core/config/app_config.dart';
import 'package:pranidoctor_mobile/src/core/network/api_client.dart';
import 'package:pranidoctor_mobile/src/features/knowledge_hub/data/knowledge_models.dart';
import 'package:pranidoctor_mobile/src/features/knowledge_hub/data/knowledge_repository.dart';
import 'package:pranidoctor_mobile/src/features/knowledge_hub/data/knowledge_repository_mock.dart';

final knowledgeRepositoryProvider = Provider<KnowledgeRepository>((ref) {
  if (AppConfig.useMockKnowledgeApi) {
    return KnowledgeRepositoryMock();
  }
  return KnowledgeRepositoryLive(ref.watch(apiClientProvider));
});

/// `null` = all posts.
final selectedKnowledgeCategoryIdProvider =
    NotifierProvider<SelectedKnowledgeCategoryIdNotifier, String?>(
      SelectedKnowledgeCategoryIdNotifier.new,
    );

class SelectedKnowledgeCategoryIdNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String? categoryId) => state = categoryId;
}

final knowledgeCategoriesProvider =
    FutureProvider.autoDispose<List<KnowledgeCategory>>((ref) async {
      final repo = ref.watch(knowledgeRepositoryProvider);
      return repo.listCategories();
    });

/// Unfiltered catalog slice — hub home / featured (ignores category chip filter).
final knowledgeCatalogPostsProvider =
    FutureProvider.autoDispose<({List<KnowledgePost> posts, int total})>((
      ref,
    ) async {
      final repo = ref.watch(knowledgeRepositoryProvider);
      return repo.listPosts(take: 30, skip: 0);
    });

/// Posts list on `/knowledge/posts` — respects [selectedKnowledgeCategoryIdProvider].
final knowledgePostsProvider =
    FutureProvider.autoDispose<({List<KnowledgePost> posts, int total})>((
      ref,
    ) async {
      final repo = ref.watch(knowledgeRepositoryProvider);
      final categoryId = ref.watch(selectedKnowledgeCategoryIdProvider);
      return repo.listPosts(categoryId: categoryId, take: 50, skip: 0);
    });

final knowledgePostDetailProvider = FutureProvider.autoDispose
    .family<KnowledgePostDetail, String>((ref, slugOrId) async {
      final repo = ref.watch(knowledgeRepositoryProvider);
      return repo.getPost(slugOrId);
    });

/// Featured = first `isFeatured`, else first post in catalog.
final knowledgeFeaturedPostProvider =
    FutureProvider.autoDispose<KnowledgePost?>((ref) async {
      final page = await ref.watch(knowledgeCatalogPostsProvider.future);
      for (final p in page.posts) {
        if (p.isFeatured) return p;
      }
      return page.posts.isNotEmpty ? page.posts.first : null;
    });

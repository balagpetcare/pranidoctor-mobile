import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pranidoctor_mobile/src/core/network/api_client.dart';
import 'package:pranidoctor_mobile/src/features/tutorials/data/tutorial_models.dart';
import 'package:pranidoctor_mobile/src/features/tutorials/data/tutorial_repository.dart';

final tutorialRepositoryProvider = Provider<TutorialRepository>((ref) {
  return TutorialRepository(ref.watch(apiClientProvider));
});

/// Active category filter: `null` = all published tutorials.
final selectedTutorialCategoryIdProvider =
    NotifierProvider<SelectedTutorialCategoryIdNotifier, String?>(
      SelectedTutorialCategoryIdNotifier.new,
    );

class SelectedTutorialCategoryIdNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String? categoryId) => state = categoryId;
}

final tutorialCategoriesProvider =
    FutureProvider.autoDispose<List<TutorialCategory>>((ref) async {
      final repo = ref.watch(tutorialRepositoryProvider);
      return repo.listCategories();
    });

final tutorialsListProvider =
    FutureProvider.autoDispose<({List<TutorialListItem> tutorials, int total})>(
      (ref) async {
        final repo = ref.watch(tutorialRepositoryProvider);
        final categoryId = ref.watch(selectedTutorialCategoryIdProvider);
        return repo.listPublishedTutorials(
          categoryId: categoryId,
          take: 50,
          skip: 0,
        );
      },
    );

final tutorialDetailProvider = FutureProvider.autoDispose
    .family<TutorialDetail, String>((ref, slugOrId) async {
      final repo = ref.watch(tutorialRepositoryProvider);
      return repo.getPublishedTutorial(slugOrId);
    });

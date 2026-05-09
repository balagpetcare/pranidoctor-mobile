import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pranidoctor_mobile/src/app/screen_padding.dart';
import 'package:pranidoctor_mobile/src/core/config/app_config.dart';
import 'package:pranidoctor_mobile/src/features/knowledge_hub/application/knowledge_hub_providers.dart';
import 'package:pranidoctor_mobile/src/features/knowledge_hub/data/knowledge_models.dart';
import 'package:pranidoctor_mobile/src/features/knowledge_hub/presentation/widgets/knowledge_hub_widgets.dart';

/// Paginated-style list (first page) with chips + article cards.
class KnowledgePostListScreen extends ConsumerWidget {
  const KnowledgePostListScreen({super.key});

  static const routePath = '/knowledge/posts';
  static const routeName = 'knowledgePosts';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(knowledgeCategoriesProvider);
    final postsAsync = ref.watch(knowledgePostsProvider);
    final selectedId = ref.watch(selectedKnowledgeCategoryIdProvider);
    final scheme = Theme.of(context).colorScheme;
    final hPad = pdScreenPadding(context).horizontal;
    final maxW = pdReadableMaxWidth(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('সব লেখা'),
        actions: [
          IconButton(
            tooltip: 'বিভাগ',
            onPressed: () => context.push('/knowledge/categories'),
            icon: const Icon(Icons.grid_view_outlined),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(knowledgeCategoriesProvider);
          ref.invalidate(knowledgePostsProvider);
          ref.invalidate(knowledgeCatalogPostsProvider);
          ref.invalidate(knowledgeFeaturedPostProvider);
          await ref.read(knowledgePostsProvider.future);
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 8),
              sliver: SliverToBoxAdapter(
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxW),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (AppConfig.useMockKnowledgeApi)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              'নমুনা মোড',
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(color: scheme.tertiary),
                            ),
                          ),
                        const KnowledgeSearchBarPlaceholder(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 12),
              sliver: SliverToBoxAdapter(
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxW),
                    child: categoriesAsync.when(
                      data: (cats) => _CategoryChipsRow(
                        categories: cats,
                        selectedId: selectedId,
                        onSelectAll: () => ref
                            .read(selectedKnowledgeCategoryIdProvider.notifier)
                            .select(null),
                        onSelect: (id) => ref
                            .read(selectedKnowledgeCategoryIdProvider.notifier)
                            .select(id),
                      ),
                      loading: () => const SizedBox(
                        height: 44,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      ),
                      error: (e, _) => _InlineError(
                        message: e.toString(),
                        onRetry: () =>
                            ref.invalidate(knowledgeCategoriesProvider),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            postsAsync.when(
              data: (page) {
                if (page.posts.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: _EmptyState(
                      message: selectedId == null
                          ? 'কোনো লেখা পাওয়া যায়নি।'
                          : 'এই বিভাগে কোনো লেখা পাওয়া যায়নি।',
                    ),
                  );
                }
                return SliverPadding(
                  padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final item = page.posts[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: maxW),
                            child: KnowledgeArticleCard(
                              post: item,
                              onTap: () {
                                context.push(
                                  '${KnowledgePostListScreen.routePath}/${Uri.encodeComponent(item.navigationKey)}',
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    }, childCount: page.posts.length),
                  ),
                );
              },
              loading: () => const SliverFillRemaining(
                hasScrollBody: false,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('তথ্য লোড হচ্ছে'),
                  ],
                ),
              ),
              error: (e, _) => SliverFillRemaining(
                hasScrollBody: false,
                child: _ErrorState(
                  message: e.toString(),
                  onRetry: () => ref.invalidate(knowledgePostsProvider),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryChipsRow extends StatelessWidget {
  const _CategoryChipsRow({
    required this.categories,
    required this.selectedId,
    required this.onSelectAll,
    required this.onSelect,
  });

  final List<KnowledgeCategory> categories;
  final String? selectedId;
  final VoidCallback onSelectAll;
  final void Function(String id) onSelect;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: const Text('সব'),
              selected: selectedId == null,
              onSelected: (_) => onSelectAll(),
              selectedColor: scheme.primaryContainer,
              checkmarkColor: scheme.onPrimaryContainer,
            ),
          ),
          for (final c in categories)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(
                  c.nameBn.isNotEmpty ? c.nameBn : (c.nameEn ?? c.slug),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                selected: selectedId == c.id,
                onSelected: (_) => onSelect(c.id),
                selectedColor: scheme.primaryContainer,
                checkmarkColor: scheme.onPrimaryContainer,
              ),
            ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.menu_book_outlined, size: 56, color: scheme.outline),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: scheme.onSurfaceVariant,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 20),
            FilledButton.tonal(
              onPressed: onRetry,
              child: const Text('আবার চেষ্টা করুন'),
            ),
          ],
        ),
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            message,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        TextButton(onPressed: onRetry, child: const Text('রিফ্রেশ')),
      ],
    );
  }
}

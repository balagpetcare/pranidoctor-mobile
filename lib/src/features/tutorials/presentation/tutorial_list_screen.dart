import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:pranidoctor_mobile/src/app/screen_padding.dart';
import 'package:pranidoctor_mobile/src/features/tutorials/application/tutorials_providers.dart';
import 'package:pranidoctor_mobile/src/features/tutorials/data/tutorial_models.dart';

/// Knowledge Hub — list of published tutorials (public API).
class TutorialListScreen extends ConsumerWidget {
  const TutorialListScreen({super.key});

  static const routePath = '/tutorials';
  static const routeName = 'tutorialsList';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(tutorialCategoriesProvider);
    final tutorialsAsync = ref.watch(tutorialsListProvider);
    final selectedId = ref.watch(selectedTutorialCategoryIdProvider);
    final scheme = Theme.of(context).colorScheme;
    final hPad = pdScreenPadding(context).horizontal;
    final maxW = pdReadableMaxWidth(context);

    return Scaffold(
      appBar: AppBar(title: const Text('নলেজ হাব')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(tutorialCategoriesProvider);
          ref.invalidate(tutorialsListProvider);
          await ref.read(tutorialsListProvider.future);
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 8),
              sliver: SliverToBoxAdapter(
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxW),
                    child: Text(
                      'প্রকাশিত টিউটোরিয়াল ও পরামর্শ — বিষয়ভিত্তিক ফিল্টার করুন।',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                        height: 1.45,
                      ),
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
                            .read(selectedTutorialCategoryIdProvider.notifier)
                            .select(null),
                        onSelect: (id) => ref
                            .read(selectedTutorialCategoryIdProvider.notifier)
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
                            ref.invalidate(tutorialCategoriesProvider),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            tutorialsAsync.when(
              data: (page) {
                if (page.tutorials.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: _EmptyState(
                      message: selectedId == null
                          ? 'এখনো কোনো প্রকাশিত টিউটোরিয়াল নেই। পরে আবার দেখুন।'
                          : 'এই বিভাগে এখনো কোনো প্রকাশিত টিউটোরিয়াল নেই।',
                    ),
                  );
                }
                return SliverPadding(
                  padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final item = page.tutorials[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: maxW),
                            child: _TutorialCard(
                              item: item,
                              onTap: () {
                                final key = item.slug.trim().isNotEmpty
                                    ? item.slug
                                    : item.id;
                                context.push(
                                  '${TutorialListScreen.routePath}/${Uri.encodeComponent(key)}',
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    }, childCount: page.tutorials.length),
                  ),
                );
              },
              loading: () => const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => SliverFillRemaining(
                hasScrollBody: false,
                child: _ErrorState(
                  message: e.toString(),
                  onRetry: () => ref.invalidate(tutorialsListProvider),
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

  final List<TutorialCategory> categories;
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

class _TutorialCard extends StatelessWidget {
  const _TutorialCard({required this.item, required this.onTap});

  final TutorialListItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dateLabel = _formatDate(context, item.publishedAt);

    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (item.coverImageUrl != null &&
                  item.coverImageUrl!.trim().isNotEmpty) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.network(
                      item.coverImageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: scheme.surfaceContainerHighest,
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              Text(item.title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _MetaChip(
                    icon: Icons.folder_outlined,
                    label: item.category.nameBn.isNotEmpty
                        ? item.category.nameBn
                        : (item.category.nameEn ?? item.category.slug),
                  ),
                  if (dateLabel != null)
                    _MetaChip(icon: Icons.event_outlined, label: dateLabel),
                ],
              ),
              if (item.summary != null && item.summary!.trim().isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  item.summary!,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                    height: 1.45,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: scheme.primary),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

String? _formatDate(BuildContext context, DateTime? d) {
  if (d == null) return null;
  final loc = Localizations.localeOf(context);
  try {
    return DateFormat.yMMMd(loc.toLanguageTag()).format(d.toLocal());
  } catch (_) {
    return '${d.day}/${d.month}/${d.year}';
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

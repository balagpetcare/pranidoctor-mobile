import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pranidoctor_mobile/src/app/screen_padding.dart';
import 'package:pranidoctor_mobile/src/features/knowledge_hub/application/knowledge_hub_providers.dart';
import 'package:pranidoctor_mobile/src/features/knowledge_hub/data/knowledge_models.dart';
import 'package:pranidoctor_mobile/src/features/knowledge_hub/presentation/knowledge_post_list_screen.dart';

/// Full-screen category grid; tap selects filter and opens post list.
class KnowledgeCategoriesScreen extends ConsumerWidget {
  const KnowledgeCategoriesScreen({super.key});

  static const routePath = '/knowledge/categories';
  static const routeName = 'knowledgeCategories';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(knowledgeCategoriesProvider);
    final hPad = pdScreenPadding(context).horizontal;

    return Scaffold(
      appBar: AppBar(title: const Text('বিভাগ')),
      body: async.when(
        data: (cats) {
          if (cats.isEmpty) {
            return const _CenterMessage(
              icon: Icons.category_outlined,
              message: 'কোনো বিভাগ পাওয়া যায়নি।',
            );
          }
          return GridView.builder(
            padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 24),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.05,
            ),
            itemCount: cats.length,
            itemBuilder: (context, i) {
              final c = cats[i];
              return _CategoryTile(
                category: c,
                onTap: () {
                  ref
                      .read(selectedKnowledgeCategoryIdProvider.notifier)
                      .select(c.id);
                  context.push(KnowledgePostListScreen.routePath);
                },
              );
            },
          );
        },
        loading: () => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('তথ্য লোড হচ্ছে'),
            ],
          ),
        ),
        error: (e, _) => _ErrorBody(
          message: e.toString(),
          onRetry: () => ref.invalidate(knowledgeCategoriesProvider),
        ),
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.category, required this.onTap});

  final KnowledgeCategory category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.folder_special_outlined, color: scheme.primary),
              const Spacer(),
              Text(
                category.nameBn.isNotEmpty
                    ? category.nameBn
                    : (category.nameEn ?? category.slug),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(height: 1.25),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CenterMessage extends StatelessWidget {
  const _CenterMessage({required this.icon, required this.message});

  final IconData icon;
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
            Icon(icon, size: 56, color: scheme.outline),
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

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.message, required this.onRetry});

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

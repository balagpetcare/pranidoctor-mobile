import 'package:flutter/material.dart';

import 'package:pranidoctor_mobile/src/features/knowledge_hub/data/knowledge_models.dart';

/// Non-functional search UI until backend supports query.
class KnowledgeSearchBarPlaceholder extends StatelessWidget {
  const KnowledgeSearchBarPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'খোঁজার সুবিধা শীঘ্রই যুক্ত হবে। এখন বিভাগ বা তালিকা থেকে বেছে নিন।',
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(Icons.search, color: scheme.onSurfaceVariant),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'খুঁজুন',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
              Icon(Icons.tune, size: 20, color: scheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

/// Hero-style card for [KnowledgePost.isFeatured] or pinned item.
class KnowledgeFeaturedCard extends StatelessWidget {
  const KnowledgeFeaturedCard({
    super.key,
    required this.post,
    required this.onTap,
  });

  final KnowledgePost post;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (post.coverImageUrl != null &&
                post.coverImageUrl!.trim().isNotEmpty)
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  post.coverImageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, Object error, StackTrace? stackTrace) =>
                          ColoredBox(
                            color: scheme.primaryContainer,
                            child: Icon(
                              Icons.menu_book_rounded,
                              size: 48,
                              color: scheme.onPrimaryContainer,
                            ),
                          ),
                ),
              )
            else
              ColoredBox(
                color: scheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 28),
                  child: Icon(
                    Icons.health_and_safety_outlined,
                    size: 44,
                    color: scheme.onPrimaryContainer,
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'জনপ্রিয়/ফিচার্ড লেখা',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: scheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    post.title,
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge?.copyWith(height: 1.25),
                  ),
                  if (post.summary != null &&
                      post.summary!.trim().isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      post.summary!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                        height: 1.45,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        'বিস্তারিত পড়ুন',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: scheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward,
                        size: 18,
                        color: scheme.primary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Standard list card for a knowledge post.
class KnowledgeArticleCard extends StatelessWidget {
  const KnowledgeArticleCard({
    super.key,
    required this.post,
    required this.onTap,
  });

  final KnowledgePost post;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (post.coverImageUrl != null &&
                  post.coverImageUrl!.trim().isNotEmpty) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.network(
                      post.coverImageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, Object error, StackTrace? stackTrace) =>
                              Container(
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
              Text(post.title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _MetaChip(
                    icon: Icons.folder_outlined,
                    label: post.category.nameBn.isNotEmpty
                        ? post.category.nameBn
                        : (post.category.nameEn ?? post.category.slug),
                  ),
                  if (post.readTimeMinutes != null)
                    _MetaChip(
                      icon: Icons.schedule_outlined,
                      label: '${post.readTimeMinutes} মি.',
                    ),
                ],
              ),
              if (post.summary != null && post.summary!.trim().isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  post.summary!,
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

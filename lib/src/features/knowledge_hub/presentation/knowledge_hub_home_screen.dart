import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pranidoctor_mobile/src/app/screen_padding.dart';
import 'package:pranidoctor_mobile/src/core/config/app_config.dart';
import 'package:pranidoctor_mobile/src/features/knowledge_hub/application/knowledge_hub_providers.dart';
import 'package:pranidoctor_mobile/src/features/knowledge_hub/presentation/knowledge_categories_screen.dart';
import 'package:pranidoctor_mobile/src/features/knowledge_hub/presentation/knowledge_post_list_screen.dart';
import 'package:pranidoctor_mobile/src/features/knowledge_hub/presentation/widgets/knowledge_hub_widgets.dart';

/// Knowledge hub landing — shortcuts, featured, search placeholder.
class KnowledgeHubHomeScreen extends ConsumerWidget {
  const KnowledgeHubHomeScreen({super.key});

  static const routePath = '/knowledge';
  static const routeName = 'knowledgeHubHome';

  static const _topicLabels = <String>[
    'প্রাণী পরিচর্যা',
    'জরুরি সেবা',
    'টিকা',
    'রোগ সচেতনতা',
    'এআই সেবা শিক্ষা',
    'ডাক্তার/টেকনিশিয়ান টিউটোরিয়াল',
    'প্ল্যাটফর্ম ব্যবহার গাইড',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final hPad = pdScreenPadding(context).horizontal;
    final maxW = pdReadableMaxWidth(context);
    final featuredAsync = ref.watch(knowledgeFeaturedPostProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(title: const Text('জ্ঞানকেন্দ্র')),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 24),
            sliver: SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxW),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (AppConfig.useMockKnowledgeApi) ...[
                        Card(
                          color: scheme.tertiaryContainer,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.menu_book_outlined,
                                  color: scheme.onTertiaryContainer,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'নমুনা বিষয়বস্তু চালু (USE_MOCK_KNOWLEDGE_API)',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      Text(
                        'প্রাণিসম্পদ স্বাস্থ্য, জরুরি সেবা ও প্ল্যাটফর্ম ব্যবহার — বিশ্বাসযোগ্য নির্দেশনা।',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: scheme.onSurfaceVariant,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const KnowledgeSearchBarPlaceholder(),
                      const SizedBox(height: 24),
                      featuredAsync.when(
                        data: (post) {
                          if (post == null) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: KnowledgeFeaturedCard(
                              post: post,
                              onTap: () => context.push(
                                '${KnowledgePostListScreen.routePath}/${Uri.encodeComponent(post.navigationKey)}',
                              ),
                            ),
                          );
                        },
                        loading: () => const Padding(
                          padding: EdgeInsets.only(bottom: 20),
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.all(24),
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        ),
                        error: (Object error, StackTrace stackTrace) =>
                            const SizedBox.shrink(),
                      ),
                      Text(
                        'শিখনের বিষয়সমূহ',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _topicLabels
                            .map(
                              (t) => ActionChip(
                                label: Text(t),
                                onPressed: () {
                                  context.push(
                                    KnowledgeCategoriesScreen.routePath,
                                  );
                                },
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: () {
                          ref
                              .read(
                                selectedKnowledgeCategoryIdProvider.notifier,
                              )
                              .select(null);
                          context.push(KnowledgePostListScreen.routePath);
                        },
                        icon: const Icon(Icons.article_outlined),
                        label: const Text('সব লেখা'),
                      ),
                      const SizedBox(height: 10),
                      OutlinedButton.icon(
                        onPressed: () =>
                            context.push(KnowledgeCategoriesScreen.routePath),
                        icon: const Icon(Icons.grid_view_outlined),
                        label: const Text('বিভাগ অনুযায়ী দেখুন'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

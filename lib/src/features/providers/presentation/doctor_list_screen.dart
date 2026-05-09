import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pranidoctor_mobile/src/app/screen_padding.dart';
import 'package:pranidoctor_mobile/src/core/assets/prani_assets.dart';
import 'package:pranidoctor_mobile/src/features/providers/application/provider_finder_providers.dart';
import 'package:pranidoctor_mobile/src/features/providers/data/provider_finder_repository.dart';
import 'package:pranidoctor_mobile/src/features/providers/presentation/doctor_detail_screen.dart';
import 'package:pranidoctor_mobile/src/features/providers/presentation/widgets/doctor_summary_card.dart';
import 'package:pranidoctor_mobile/src/features/providers/presentation/widgets/provider_filter_panel.dart';

class DoctorListScreen extends ConsumerWidget {
  const DoctorListScreen({super.key});

  static const routePath = '/providers/doctors';
  static const routeName = 'doctorList';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(doctorsListProvider);
    final notifier = ref.read(doctorsListProvider.notifier);
    final query = ref.watch(doctorListQueryProvider);
    final scheme = Theme.of(context).colorScheme;
    final hPad = pdScreenPadding(context).horizontal;
    final maxW = pdReadableMaxWidth(context);

    return Scaffold(
      appBar: AppBar(title: const Text('ডাক্তার খুঁজুন')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(hPad, 10, hPad, 0),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxW),
                child: PraniBrandHero(
                  assetPath: PraniAssets.doctorVisitCow,
                  height: 148,
                  fit: BoxFit.cover,
                  semanticLabel: 'খামারে গরু ও ডাক্তার পরিদর্শনের চিত্রায়ণ',
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          ProviderFilterPanel(
            query: query,
            showOnlineConsultation: true,
            onQueryChanged: (q) {
              ref.read(doctorListQueryProvider.notifier).apply(q);
            },
          ),
          Expanded(
            child: async.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => _ErrorBody(
                message: e is ProviderApiException
                    ? e.message
                    : 'লোড করা যায়নি',
                onRetry: () => notifier.refresh(),
              ),
              data: (data) {
                if (data.doctors.isEmpty) {
                  return _EmptyBody(onRetry: () => notifier.refresh());
                }
                return RefreshIndicator(
                  onRefresh: () => notifier.refresh(),
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 24),
                        sliver: SliverToBoxAdapter(
                          child: Center(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(maxWidth: maxW),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    'মোট ${data.pagination.total} জন',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelLarge
                                        ?.copyWith(
                                          color: scheme.onSurfaceVariant,
                                        ),
                                  ),
                                  const SizedBox(height: 10),
                                  for (final d in data.doctors) ...[
                                    DoctorSummaryCard(
                                      doctor: d,
                                      onTap: () {
                                        context.push(
                                          DoctorDetailScreen.pathFor(d.id),
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 10),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyBody extends StatelessWidget {
  const _EmptyBody({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 56, color: scheme.outline),
            const SizedBox(height: 16),
            Text(
              'কোনো ডাক্তার পাওয়া যায়নি',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'ফিল্টার বদলে আবার চেষ্টা করুন।',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 20),
            FilledButton.tonal(
              onPressed: onRetry,
              child: const Text('রিফ্রেশ'),
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
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 56, color: scheme.error),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 20),
            FilledButton(onPressed: onRetry, child: const Text('আবার চেষ্টা')),
          ],
        ),
      ),
    );
  }
}

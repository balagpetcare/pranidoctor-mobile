import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pranidoctor_mobile/src/app/screen_padding.dart';
import 'package:pranidoctor_mobile/src/core/assets/prani_assets.dart';
import 'package:pranidoctor_mobile/src/features/animals/application/animals_providers.dart';
import 'package:pranidoctor_mobile/src/features/animals/data/animal_profile_repository.dart';
import 'package:pranidoctor_mobile/src/features/animals/presentation/animal_detail_screen.dart';
import 'package:pranidoctor_mobile/src/features/animals/presentation/animal_form_screen.dart';
import 'package:pranidoctor_mobile/src/features/animals/presentation/widgets/animal_card.dart';

class AnimalListScreen extends ConsumerWidget {
  const AnimalListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void openAdd() {
      Navigator.of(context).push<void>(
        MaterialPageRoute<void>(builder: (_) => AnimalFormScreen.create()),
      );
    }

    final asyncAnimals = ref.watch(animalsListProvider);
    final notifier = ref.read(animalsListProvider.notifier);
    final scheme = Theme.of(context).colorScheme;
    final hPad = pdScreenPadding(context).horizontal;
    final maxW = pdReadableMaxWidth(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('আমার পশু'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'toggle') {
                notifier.setIncludeInactive(!notifier.includeInactive);
              }
            },
            itemBuilder: (context) => [
              CheckedPopupMenuItem<String>(
                value: 'toggle',
                checked: notifier.includeInactive,
                child: const Text('নিষ্ক্রিয় গুলো দেখান'),
              ),
            ],
          ),
        ],
      ),
      body: asyncAnimals.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorBody(
          message: e is AnimalApiException ? e.message : 'লোড করা যায়নি',
          onRetry: () => notifier.refresh(),
        ),
        data: (animals) {
          if (animals.isEmpty) {
            return _EmptyBody(onAdd: openAdd);
          }
          return RefreshIndicator(
            onRefresh: () async {
              await notifier.refresh();
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 100),
                  sliver: SliverToBoxAdapter(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: maxW),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            for (final a in animals) ...[
                              AnimalCard(
                                animal: a,
                                onTap: () {
                                  Navigator.of(context).push<void>(
                                    MaterialPageRoute<void>(
                                      builder: (_) =>
                                          AnimalDetailScreen(animalId: a.id),
                                    ),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: openAdd,
        icon: const Icon(Icons.add),
        label: const Text('যোগ করুন'),
        backgroundColor: scheme.tertiaryContainer,
        foregroundColor: scheme.onTertiaryContainer,
      ),
    );
  }
}

class _EmptyBody extends StatelessWidget {
  const _EmptyBody({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: SizedBox(
                width: double.infinity,
                height: 188,
                child: Image.asset(
                  PraniAssets.animalEmptyState,
                  fit: BoxFit.contain,
                  gaplessPlayback: true,
                  semanticLabel: 'খামার ও গবাদি প্রাণীর খালি তালিকার চিত্রায়ণ',
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'কোনো প্রাণির তথ্য নেই',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 10),
            Text(
              'গরু, ছাগল, ভেড়া, হাঁস ও মুরগির মতো খামারের প্রাণির প্রোফাইল যোগ করুন — ডাক্তার বা টেকনিশিয়ান ডাকতে সুবিধা হবে।',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('প্রাণি যোগ করুন'),
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
        padding: const EdgeInsets.symmetric(horizontal: 24),
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
            FilledButton(
              onPressed: onRetry,
              child: const Text('আবার চেষ্টা করুন'),
            ),
          ],
        ),
      ),
    );
  }
}

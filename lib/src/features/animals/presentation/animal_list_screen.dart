import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pranidoctor_mobile/src/app/screen_padding.dart';
import 'package:pranidoctor_mobile/src/core/widgets/pd_async_states.dart';
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
        loading: () =>
            const PdLoadingBody(message: 'প্রাণির তালিকা লোড হচ্ছে…'),
        error: (e, _) => PdErrorBody(
          title: 'লোড করা যায়নি',
          message: e is AnimalApiException ? e.message : null,
          retryLabel: 'আবার চেষ্টা করুন',
          onRetry: () => notifier.refresh(),
        ),
        data: (animals) {
          if (animals.isEmpty) {
            return PdEmptyState(
              icon: Icons.pets_outlined,
              title: 'কোনো প্রাণির তথ্য নেই',
              subtitle:
                  'আপনার পোষা বা খামারের প্রাণি যোগ করে রাখুন — পরিষেবা নিতে সুবিধা হবে।',
              actionLabel: 'প্রাণি যোগ করুন',
              onAction: openAdd,
            );
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

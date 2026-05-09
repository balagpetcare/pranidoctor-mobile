import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pranidoctor_mobile/src/app/screen_padding.dart';
import 'package:pranidoctor_mobile/src/core/assets/prani_assets.dart';
import 'package:pranidoctor_mobile/src/features/animals/application/animals_providers.dart';
import 'package:pranidoctor_mobile/src/features/animals/data/animal_profile_repository.dart';
import 'package:pranidoctor_mobile/src/features/animals/presentation/animal_detail_screen.dart';
import 'package:pranidoctor_mobile/src/features/animals/presentation/animal_form_screen.dart';
import 'package:pranidoctor_mobile/src/features/animals/presentation/widgets/animal_card.dart';

const _kEmptyHeroAspectRatio = 1.95;

class AnimalListScreen extends ConsumerWidget {
  const AnimalListScreen({super.key});

  static const routePath = '/animals';
  static const routeName = 'animalsList';

  static const double _listBottomClearFab = 88;

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
    final textTheme = Theme.of(context).textTheme;
    final hPad = pdScreenPadding(context).horizontal;
    final maxW = pdReadableMaxWidth(context);
    final bottomFabPad =
        10.0 + MediaQuery.viewPaddingOf(context).bottom.clamp(0.0, 24.0);

    final showFab = asyncAnimals.when(
      data: (animals) => animals.isNotEmpty,
      loading: () => false,
      error: (e, st) => true,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('আমার পশু'),
        actions: [
          PopupMenuButton<String>(
            tooltip: 'আরও',
            icon: const Icon(Icons.more_vert),
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
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: showFab
          ? Padding(
              padding: EdgeInsets.only(bottom: bottomFabPad),
              child: FloatingActionButton.extended(
                elevation: 2,
                focusElevation: 4,
                hoverElevation: 4,
                highlightElevation: 2,
                backgroundColor: scheme.primary,
                foregroundColor: scheme.onPrimary,
                onPressed: openAdd,
                icon: const Icon(Icons.add),
                label: const Text('প্রাণি যোগ করুন'),
              ),
            )
          : null,
      body: RefreshIndicator(
        onRefresh: () => notifier.refresh(),
        child: asyncAnimals.when(
          loading: () => CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: CircularProgressIndicator(color: scheme.primary),
                ),
              ),
            ],
          ),
          error: (e, _) {
            assert(() {
              debugPrint('animalsListProvider error: $e');
              return true;
            }());
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 24 + bottomFabPad),
              children: [
                _ErrorBody(
                  message: e is AnimalApiException
                      ? e.message
                      : 'লোড করা যায়নি',
                  onRetry: () => notifier.refresh(),
                  maxWidth: maxW,
                  textTheme: textTheme,
                  scheme: scheme,
                ),
              ],
            );
          },
          data: (animals) {
            if (animals.isEmpty) {
              return _EmptyBody(
                onAdd: openAdd,
                maxWidth: maxW,
                horizontalPadding: hPad,
                bottomInset: bottomFabPad,
              );
            }
            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                hPad,
                8,
                hPad,
                _listBottomClearFab + bottomFabPad,
              ),
              itemCount: animals.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final a = animals[i];
                return AnimalCard(
                  animal: a,
                  onTap: () {
                    if (a.id.trim().isEmpty) return;
                    Navigator.of(context).push<void>(
                      MaterialPageRoute<void>(
                        builder: (_) => AnimalDetailScreen(animalId: a.id),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _EmptyBody extends StatelessWidget {
  const _EmptyBody({
    required this.onAdd,
    required this.maxWidth,
    required this.horizontalPadding,
    required this.bottomInset,
  });

  final VoidCallback onAdd;
  final double maxWidth;
  final double horizontalPadding;
  final double bottomInset;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                12,
                horizontalPadding,
                28 + bottomInset,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      PraniBrandHero(
                        assetPath: PraniAssets.animalEmptyState,
                        aspectRatio: _kEmptyHeroAspectRatio,
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                        borderRadius: BorderRadius.circular(16),
                        semanticLabel:
                            'খামার ও গবাদি প্রাণীর খালি তালিকার চিত্রায়ণ',
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'কোনো প্রাণির তথ্য নেই',
                        textAlign: TextAlign.center,
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'গরু, ছাগল, ভেড়া, হাঁস ও মুরগির মতো খামারের প্রাণির প্রোফাইল যোগ করুন। ডাক্তার বা টেকনিশিয়ান ডাকতে তালিকা থেকে পশু বেছে নিতে পারবেন।',
                        textAlign: TextAlign.center,
                        style: textTheme.bodyLarge?.copyWith(
                          color: scheme.onSurfaceVariant,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 22),
                      FilledButton.icon(
                        onPressed: onAdd,
                        icon: const Icon(Icons.add),
                        label: const Text('প্রাণি যোগ করুন'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({
    required this.message,
    required this.onRetry,
    required this.maxWidth,
    required this.textTheme,
    required this.scheme,
  });

  final String message;
  final VoidCallback onRetry;
  final double maxWidth;
  final TextTheme textTheme;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_outlined, size: 48, color: scheme.error),
            const SizedBox(height: 16),
            Text(
              'লোড করা যায়নি',
              textAlign: TextAlign.center,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 22),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('আবার চেষ্টা করুন'),
            ),
          ],
        ),
      ),
    );
  }
}

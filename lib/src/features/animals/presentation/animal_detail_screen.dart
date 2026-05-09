import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pranidoctor_mobile/src/app/screen_padding.dart';
import 'package:pranidoctor_mobile/src/features/animals/application/animals_providers.dart';
import 'package:pranidoctor_mobile/src/features/animals/data/animal_profile_model.dart';
import 'package:pranidoctor_mobile/src/features/animals/data/animal_profile_repository.dart';
import 'package:pranidoctor_mobile/src/features/animals/presentation/animal_form_screen.dart';
import 'package:pranidoctor_mobile/src/features/animals/presentation/widgets/animal_labels.dart';
import 'package:pranidoctor_mobile/src/features/animals/presentation/widgets/animal_photo_placeholder.dart';

class AnimalDetailScreen extends ConsumerWidget {
  const AnimalDetailScreen({super.key, required this.animalId});

  final String animalId;

  String _formatDate(DateTime d) => '${d.day}/${d.month}/${d.year}';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncAnimal = ref.watch(animalDetailProvider(animalId));
    final hPad = pdScreenPadding(context).horizontal;

    return Scaffold(
      appBar: AppBar(
        title: const Text('প্রাণির বিবরণ'),
        actions: [
          asyncAnimal.maybeWhen(
            data: (animal) => IconButton(
              tooltip: 'সম্পাদনা',
              icon: const Icon(Icons.edit_outlined),
              onPressed: animal.id.trim().isEmpty
                  ? null
                  : () async {
                      await Navigator.of(context).push<void>(
                        MaterialPageRoute<void>(
                          builder: (_) =>
                              AnimalFormScreen.edit(animalId: animal.id),
                        ),
                      );
                      if (context.mounted) {
                        ref.invalidate(animalDetailProvider(animalId));
                        ref.invalidate(animalsListProvider);
                      }
                    },
            ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: asyncAnimal.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: hPad),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  e is AnimalApiException ? e.message : 'লোড করা যায়নি',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () =>
                      ref.invalidate(animalDetailProvider(animalId)),
                  child: const Text('আবার চেষ্টা করুন'),
                ),
              ],
            ),
          ),
        ),
        data: (animal) => _DetailBody(
          animal: animal,
          animalId: animalId,
          formatDate: _formatDate,
          horizontalPadding: hPad,
        ),
      ),
    );
  }
}

class _DetailBody extends ConsumerWidget {
  const _DetailBody({
    required this.animal,
    required this.animalId,
    required this.formatDate,
    required this.horizontalPadding,
  });

  final AnimalProfile animal;
  final String animalId;
  final String Function(DateTime d) formatDate;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    Future<void> confirmDeactivate() async {
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('নিষ্ক্রিয় করবেন?'),
          content: const Text(
            'এই প্রাণির প্রোফাইল নিষ্ক্রিয় করা হবে। পরে আবার সম্পাদনা করে সক্রিয় করা যাবে।',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('বাতিল'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('নিষ্ক্রিয় করুন'),
            ),
          ],
        ),
      );
      if (ok != true || !context.mounted) return;
      if (animalId.trim().isEmpty) return;

      try {
        await ref.read(animalRepositoryProvider).deactivate(animalId);
        if (!context.mounted) return;
        ref.invalidate(animalsListProvider);
        ref.invalidate(animalDetailProvider(animalId));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('প্রোফাইল নিষ্ক্রিয় করা হয়েছে')),
        );
        Navigator.of(context).pop();
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e is AnimalApiException ? e.message : 'ব্যর্থ হয়েছে',
            ),
          ),
        );
      }
    }

    return ListView(
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        16,
        horizontalPadding,
        32,
      ),
      children: [
        Center(
          child: AnimalPhotoPlaceholder(photoUrl: animal.photoUrl, size: 120),
        ),
        const SizedBox(height: 20),
        Text(
          animal.name.isNotEmpty ? animal.name : 'বেনামী',
          style: textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        if (!animal.active)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Align(
              child: Chip(
                label: const Text('নিষ্ক্রিয়'),
                backgroundColor: scheme.errorContainer,
              ),
            ),
          ),
        const SizedBox(height: 24),
        _DetailRow(
          label: 'ধরন',
          value: animal.animalType != null
              ? animalTypeLabelBn(animal.animalType!)
              : animal.species,
        ),
        _DetailRow(
          label: 'বিভাগ',
          value: animalCategoryLabelBn(animal.category),
        ),
        if (animal.microchipOrTag?.isNotEmpty == true)
          _DetailRow(label: 'ট্যাগ', value: animal.microchipOrTag!),
        if (animal.breed?.trim().isNotEmpty == true)
          _DetailRow(label: 'জাত', value: animal.breed!.trim()),
        if (animal.dateOfBirth != null)
          _DetailRow(
            label: 'জন্ম তারিখ',
            value: formatDate(animal.dateOfBirth!.toLocal()),
          )
        else if (animal.ageYears != null)
          _DetailRow(
            label: 'বয়স (আনুমানিক)',
            value:
                '${animal.ageYears} বছর${animal.ageMonths != null ? ', ${animal.ageMonths} মাস' : ''}',
          ),
        _DetailRow(
          label: 'লিঙ্গ',
          value: animal.gender != null
              ? genderLabelBn(animal.gender!)
              : (animal.sex?.trim().isNotEmpty == true ? animal.sex! : '—'),
        ),
        if (animal.pregnancyStatus != null)
          _DetailRow(
            label: 'গর্ভাবস্থা',
            value: pregnancyLabelBn(animal.pregnancyStatus!),
          ),
        if (animal.weightKg?.isNotEmpty == true)
          _DetailRow(label: 'ওজন (কেজি)', value: animal.weightKg!),
        _DetailRow(
          label: 'নোট',
          value: animal.notes?.trim().isNotEmpty == true ? animal.notes! : '—',
        ),
        const SizedBox(height: 28),
        if (animal.active)
          FilledButton.tonal(
            onPressed: confirmDeactivate,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              foregroundColor: scheme.error,
            ),
            child: const Text('প্রোফাইল নিষ্ক্রিয় করুন'),
          ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyLarge),
          ),
        ],
      ),
    );
  }
}

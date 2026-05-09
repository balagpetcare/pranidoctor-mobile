import 'package:flutter/material.dart';

import 'package:pranidoctor_mobile/src/features/animals/data/animal_profile_model.dart';
import 'package:pranidoctor_mobile/src/features/animals/presentation/widgets/animal_labels.dart';
import 'package:pranidoctor_mobile/src/features/animals/presentation/widgets/animal_photo_placeholder.dart';

/// Leading icon for list cards (photo URL handled separately in [_AnimalListLeading]).
IconData _animalLeadingIconFor(AnimalProfile animal) {
  final t = animal.animalType;
  if (t != null) {
    return switch (t) {
      AnimalType.CATTLE => Icons.agriculture_outlined,
      AnimalType.GOAT => Icons.pets_outlined,
      AnimalType.POULTRY => Icons.egg_outlined,
      AnimalType.DOG => Icons.pets,
      AnimalType.CAT => Icons.cruelty_free_outlined,
      AnimalType.OTHER => Icons.pets_outlined,
    };
  }
  return _iconFromSpeciesText(animal.species);
}

IconData _iconFromSpeciesText(String species) {
  final x = species.toLowerCase().trim();
  if (x.isEmpty) return Icons.pets_outlined;
  if (x.contains('cattle') ||
      x.contains('cow') ||
      x.contains('buffalo') ||
      x.contains('গরু') ||
      x.contains('মহিষ')) {
    return Icons.agriculture_outlined;
  }
  if (x.contains('goat') || x.contains('ছাগল')) {
    return Icons.pets_outlined;
  }
  if (x.contains('sheep') || x.contains('lamb') || x.contains('ভেড়া')) {
    return Icons.grass_outlined;
  }
  if (x.contains('duck') ||
      x.contains('chicken') ||
      x.contains('poultry') ||
      x.contains('bird') ||
      x.contains('হাঁস') ||
      x.contains('মুরগি')) {
    return Icons.egg_outlined;
  }
  return Icons.pets_outlined;
}

bool _animalHasDisplayPhoto(AnimalProfile animal) {
  final u = animal.photoUrl?.trim();
  return u != null &&
      u.isNotEmpty &&
      (u.startsWith('http://') || u.startsWith('https://'));
}

class AnimalCard extends StatelessWidget {
  const AnimalCard({super.key, required this.animal, required this.onTap});

  final AnimalProfile animal;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final titleStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w600,
      height: 1.32,
    );
    final subtitleStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: scheme.onSurfaceVariant,
      height: 1.35,
    );

    final typeLabel = animal.animalType != null
        ? animalTypeLabelBn(animal.animalType!)
        : animal.species;

    final nameLine = animal.name.isNotEmpty
        ? animal.name
        : (animal.microchipOrTag ?? 'বেনামী');

    final tagSuffix =
        animal.microchipOrTag != null && animal.microchipOrTag!.isNotEmpty
        ? ' · ট্যাগ: ${animal.microchipOrTag}'
        : '';

    final breedLine = animal.breed?.trim().isNotEmpty == true
        ? animal.breed!.trim()
        : null;

    final sexLine = animal.gender != null
        ? genderLabelBn(animal.gender!)
        : (animal.sex?.trim().isNotEmpty == true ? animal.sex! : null);

    final ageLine = animal.dateOfBirth != null
        ? 'জন্ম: ${_formatSimpleDate(animal.dateOfBirth!.toLocal())}'
        : (animal.ageYears != null
              ? 'বয়স: প্রায় ${animal.ageYears} বছর'
              : null);

    String? sexAgeSummary;
    final bits = <String>[];
    if (sexLine != null) bits.add('লিঙ্গ: $sexLine');
    if (ageLine != null) bits.add(ageLine);
    if (bits.isNotEmpty) sexAgeSummary = bits.join(' · ');

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _AnimalListLeading(animal: animal),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            '$nameLine$tagSuffix',
                            style: titleStyle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!animal.active)
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Chip(
                              label: const Text(
                                'নিষ্ক্রিয়',
                                style: TextStyle(fontSize: 11),
                              ),
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      typeLabel,
                      style: subtitleStyle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (breedLine != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        breedLine,
                        style: subtitleStyle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (sexAgeSummary != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        sexAgeSummary,
                        style: subtitleStyle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                color: scheme.outline,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimalListLeading extends StatelessWidget {
  const _AnimalListLeading({required this.animal});

  final AnimalProfile animal;

  static const double _size = 56;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final icon = _animalLeadingIconFor(animal);

    if (_animalHasDisplayPhoto(animal)) {
      return SizedBox(
        width: _size,
        height: _size,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            AnimalPhotoPlaceholder(photoUrl: animal.photoUrl, size: _size),
            Positioned(
              right: -2,
              bottom: -2,
              child: Material(
                elevation: 1,
                color: scheme.primary,
                shape: const CircleBorder(),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(icon, size: 14, color: scheme.onPrimary),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return CircleAvatar(
      radius: _size / 2,
      backgroundColor: scheme.primaryContainer,
      child: Icon(icon, color: scheme.onPrimaryContainer, size: 28),
    );
  }
}

String _formatSimpleDate(DateTime d) {
  return '${d.day}/${d.month}/${d.year}';
}

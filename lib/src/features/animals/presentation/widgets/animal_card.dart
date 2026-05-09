import 'package:flutter/material.dart';

import 'package:pranidoctor_mobile/src/features/animals/data/animal_profile_model.dart';
import 'package:pranidoctor_mobile/src/features/animals/presentation/widgets/animal_labels.dart';
import 'package:pranidoctor_mobile/src/features/animals/presentation/widgets/animal_photo_placeholder.dart';

class AnimalCard extends StatelessWidget {
  const AnimalCard({super.key, required this.animal, required this.onTap});

  final AnimalProfile animal;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final titleStyle = Theme.of(context).textTheme.titleMedium;
    final subtitleStyle = Theme.of(
      context,
    ).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant);

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

    final weightLine = animal.weightKg?.trim().isNotEmpty == true
        ? 'ওজন: ${animal.weightKg!.trim()} কেজি'
        : null;

    String? metaLine;
    final metaBits = <String>[];
    if (sexAgeSummary != null) metaBits.add(sexAgeSummary);
    if (weightLine != null) metaBits.add(weightLine);
    if (metaBits.isNotEmpty) metaLine = metaBits.join(' · ');

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimalPhotoPlaceholder(photoUrl: animal.photoUrl, size: 56),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
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
                    Text(typeLabel, style: subtitleStyle),
                    if (breedLine != null) ...[
                      const SizedBox(height: 2),
                      Text(breedLine, style: subtitleStyle),
                    ],
                    if (metaLine != null) ...[
                      const SizedBox(height: 4),
                      Text(metaLine, style: subtitleStyle),
                    ],
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: scheme.primary),
            ],
          ),
        ),
      ),
    );
  }
}

String _formatSimpleDate(DateTime d) {
  return '${d.day}/${d.month}/${d.year}';
}

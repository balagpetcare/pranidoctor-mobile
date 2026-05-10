import 'package:flutter/material.dart';

import 'package:pranidoctor_mobile/src/design_system/widgets/prani_provider_card.dart';
import 'package:pranidoctor_mobile/src/features/providers/data/provider_models.dart';

class TechnicianSummaryCard extends StatelessWidget {
  const TechnicianSummaryCard({
    super.key,
    required this.technician,
    required this.onTap,
  });

  final TechnicianSummary technician;
  final VoidCallback onTap;

  void _snack(BuildContext context, String label) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$label — শীঘ্রই যুক্ত হবে')));
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final tags = <Widget>[
      if (technician.homeVisit)
        Chip(
          visualDensity: VisualDensity.compact,
          label: const Text('হোম ভিজিট'),
          labelStyle: textTheme.labelMedium,
        ),
      if (technician.emergency)
        Chip(
          visualDensity: VisualDensity.compact,
          label: const Text('জরুরি'),
          labelStyle: textTheme.labelMedium,
        ),
      if (technician.onlineConsultation)
        Chip(
          visualDensity: VisualDensity.compact,
          label: const Text('অনলাইন'),
          labelStyle: textTheme.labelMedium,
        ),
      ...technician.supportedAnimalTypes.map(
        (s) => Chip(
          visualDensity: VisualDensity.compact,
          label: Text(s),
          labelStyle: textTheme.labelSmall,
        ),
      ),
    ];

    final fee = technician.fee != null
        ? 'ফি: ${technician.fee} টাকা'
        : 'ফি: নির্ধারিত নয়';

    final rating =
        'রেটিং: ${technician.rating == null ? 'শীঘ্রই' : technician.rating.toString()}';

    return PraniProviderCard(
      name: technician.name,
      roleLine: technician.serviceType,
      areaLine: technician.areaText ?? 'এলাকা —',
      feeLine: fee,
      ratingLine: rating,
      availabilityLine: technician.availability?.trim().isNotEmpty == true
          ? technician.availability!.trim()
          : null,
      tags: tags,
      primaryActionLabel: 'বুক',
      onPrimaryAction: () => _snack(context, 'বুকিং'),
      secondaryActionLabel: 'কল',
      onSecondaryAction: () => _snack(context, 'কল'),
      onTap: onTap,
    );
  }
}

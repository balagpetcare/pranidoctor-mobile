import 'package:flutter/material.dart';

import 'package:pranidoctor_mobile/src/design_system/widgets/prani_provider_card.dart';
import 'package:pranidoctor_mobile/src/features/providers/data/provider_models.dart';

class DoctorSummaryCard extends StatelessWidget {
  const DoctorSummaryCard({
    super.key,
    required this.doctor,
    required this.onTap,
  });

  final DoctorSummary doctor;
  final VoidCallback onTap;

  void _snack(BuildContext context, String label) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$label — শীঘ্রই যুক্ত হবে')));
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final name = doctor.name.trim().isEmpty ? 'নাম পাওয়া যায়নি' : doctor.name;

    final roleParts = <String>[];
    if (doctor.degreeOrQualification != null &&
        doctor.degreeOrQualification!.trim().isNotEmpty) {
      roleParts.add(doctor.degreeOrQualification!.trim());
    }
    if (doctor.serviceType != null && doctor.serviceType!.trim().isNotEmpty) {
      roleParts.add(doctor.serviceType!.trim());
    }
    final roleLine = roleParts.join(' · ');

    final tags = <Widget>[
      if (doctor.homeVisit)
        Chip(
          visualDensity: VisualDensity.compact,
          label: const Text('হোম ভিজিট'),
          labelStyle: textTheme.labelMedium,
        ),
      if (doctor.emergency)
        Chip(
          visualDensity: VisualDensity.compact,
          label: const Text('জরুরি'),
          labelStyle: textTheme.labelMedium,
        ),
      if (doctor.onlineConsultation)
        Chip(
          visualDensity: VisualDensity.compact,
          label: const Text('অনলাইন'),
          labelStyle: textTheme.labelMedium,
        ),
    ];

    final area = (doctor.areaText != null && doctor.areaText!.trim().isNotEmpty)
        ? doctor.areaText!.trim()
        : 'এলাকা জানা নেই';

    final fee = doctor.fee != null && doctor.fee!.trim().isNotEmpty
        ? 'ফি: ${doctor.fee} টাকা'
        : 'ফি: নির্ধারিত নয়';

    final rating =
        'রেটিং: ${doctor.rating == null ? 'শীঘ্রই' : doctor.rating.toString()}';

    return PraniProviderCard(
      name: name,
      roleLine: roleLine.isEmpty ? null : roleLine,
      areaLine: area,
      feeLine: fee,
      ratingLine: rating,
      availabilityLine: doctor.availability?.trim().isNotEmpty == true
          ? doctor.availability!.trim()
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

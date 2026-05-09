import 'package:flutter/material.dart';

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
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(doctor.name, style: Theme.of(context).textTheme.titleLarge),
              if (doctor.degreeOrQualification != null &&
                  doctor.degreeOrQualification!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  doctor.degreeOrQualification!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
              if (doctor.serviceType != null &&
                  doctor.serviceType!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  doctor.serviceType!,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(color: scheme.primary),
                ),
              ],
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.place_outlined, size: 20, color: scheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      doctor.areaText ?? 'এলাকা —',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                doctor.fee != null
                    ? 'ফি: ${doctor.fee} টাকা'
                    : 'ফি: নির্ধারিত নয়',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 6),
              Text(
                doctor.availability ?? '',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 6),
              Text(
                'রেটিং: ${doctor.rating == null ? 'শীঘ্রই' : doctor.rating.toString()}',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: () => _snack(context, 'কল'),
                    icon: const Icon(Icons.call_outlined, size: 20),
                    label: const Text('কল'),
                  ),
                  const SizedBox(width: 10),
                  FilledButton.tonalIcon(
                    onPressed: () => _snack(context, 'বুকিং'),
                    icon: const Icon(Icons.event_note_outlined, size: 20),
                    label: const Text('বুক'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

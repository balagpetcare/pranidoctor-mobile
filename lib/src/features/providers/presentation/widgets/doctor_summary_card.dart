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
    final textTheme = Theme.of(context).textTheme;
    final name = doctor.name.trim().isEmpty ? 'নাম পাওয়া যায়নি' : doctor.name;

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (doctor.degreeOrQualification != null &&
                  doctor.degreeOrQualification!.trim().isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  doctor.degreeOrQualification!.trim(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
              ],
              if (doctor.serviceType != null &&
                  doctor.serviceType!.trim().isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  doctor.serviceType!.trim(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleSmall?.copyWith(color: scheme.primary),
                ),
              ],
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
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
                ],
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.place_outlined, size: 20, color: scheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      (doctor.areaText != null &&
                              doctor.areaText!.trim().isNotEmpty)
                          ? doctor.areaText!.trim()
                          : 'এলাকা জানা নেই',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyLarge,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                doctor.fee != null && doctor.fee!.trim().isNotEmpty
                    ? 'ফি: ${doctor.fee} টাকা'
                    : 'ফি: নির্ধারিত নয়',
                style: textTheme.bodyMedium,
              ),
              if (doctor.availability != null &&
                  doctor.availability!.trim().isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  doctor.availability!.trim(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
              ],
              const SizedBox(height: 4),
              Text(
                'রেটিং: ${doctor.rating == null ? 'শীঘ্রই' : doctor.rating.toString()}',
                style: textTheme.labelMedium?.copyWith(
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

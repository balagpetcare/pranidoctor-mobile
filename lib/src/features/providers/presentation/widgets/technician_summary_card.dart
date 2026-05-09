import 'package:flutter/material.dart';

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
              Text(
                technician.name,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              if (technician.serviceType != null &&
                  technician.serviceType!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  technician.serviceType!,
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
                      technician.areaText ?? 'এলাকা —',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                technician.fee != null
                    ? 'ফি: ${technician.fee} টাকা'
                    : 'ফি: নির্ধারিত নয়',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 6),
              Text(
                technician.availability ?? '',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
              ),
              if (technician.supportedAnimalTypes.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: technician.supportedAnimalTypes
                      .map(
                        (s) => Chip(
                          visualDensity: VisualDensity.compact,
                          label: Text(s),
                        ),
                      )
                      .toList(),
                ),
              ],
              const SizedBox(height: 6),
              Text(
                'রেটিং: ${technician.rating == null ? 'শীঘ্রই' : technician.rating.toString()}',
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

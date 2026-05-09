import 'package:flutter/material.dart';

import 'package:pranidoctor_mobile/src/core/constants/pd_spacing.dart';
import 'package:pranidoctor_mobile/src/core/widgets/pd_app_card.dart';
import 'package:pranidoctor_mobile/src/features/doctor_workflow/presentation/widgets/doctor_workflow_badges.dart';

/// Tappable summary card for doctor queues (requests / cases).
class DoctorQueueCard extends StatelessWidget {
  const DoctorQueueCard({
    super.key,
    required this.title,
    required this.animalLine,
    required this.customerLine,
    this.metaLine,
    required this.isEmergency,
    this.priorityLabel,
    required this.onTap,
  });

  final String title;
  final String animalLine;
  final String customerLine;
  final String? metaLine;
  final bool isEmergency;
  final String? priorityLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return PdAppCard(
      useShadow: true,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: PdSpacing.xs),
          DoctorUrgencyBadges(
            isEmergency: isEmergency,
            priorityLabel: priorityLabel,
          ),
          const SizedBox(height: PdSpacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.pets_outlined, size: 18, color: scheme.primary),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'প্রাণীর তথ্য',
                      style: textTheme.labelMedium?.copyWith(
                        color: scheme.primary,
                      ),
                    ),
                    Text(animalLine, style: textTheme.bodyMedium),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: PdSpacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.person_outline,
                size: 18,
                color: scheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'গ্রাহকের তথ্য',
                      style: textTheme.labelMedium?.copyWith(
                        color: scheme.primary,
                      ),
                    ),
                    Text(customerLine, style: textTheme.bodyMedium),
                  ],
                ),
              ),
            ],
          ),
          if (metaLine != null && metaLine!.trim().isNotEmpty) ...[
            const SizedBox(height: PdSpacing.sm),
            Text(
              metaLine!,
              style: textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: PdSpacing.xs),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'বিস্তারিত দেখুন',
              style: textTheme.labelLarge?.copyWith(
                color: scheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

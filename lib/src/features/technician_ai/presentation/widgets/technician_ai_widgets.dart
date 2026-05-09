import 'package:flutter/material.dart';

import 'package:pranidoctor_mobile/src/features/technician_ai/data/technician_job_models.dart';

/// Small “AI টেকনিশিয়ান” badge for app bars and headers.
class TechnicianAiBadge extends StatelessWidget {
  const TechnicianAiBadge({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Chip(
      avatar: Icon(
        Icons.biotech_outlined,
        size: compact ? 16 : 18,
        color: scheme.primary,
      ),
      label: Text(
        compact ? 'AI' : 'AI টেকনিশিয়ান',
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: scheme.onSecondaryContainer,
        ),
      ),
      side: BorderSide(color: scheme.outlineVariant),
      backgroundColor: scheme.secondaryContainer,
      padding: EdgeInsets.zero,
      visualDensity: compact ? VisualDensity.compact : VisualDensity.standard,
    );
  }
}

/// Status card for job / request workflow phase.
class TechnicianJobStatusCard extends StatelessWidget {
  const TechnicianJobStatusCard({super.key, required this.phase});

  final TechnicianWorkflowPhase phase;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (icon, bg) = switch (phase) {
      TechnicianWorkflowPhase.newRequest => (
        Icons.mark_email_unread_outlined,
        scheme.secondaryContainer,
      ),
      TechnicianWorkflowPhase.accepted => (
        Icons.how_to_reg_outlined,
        scheme.tertiaryContainer,
      ),
      TechnicianWorkflowPhase.active => (
        Icons.play_circle_outline,
        scheme.primaryContainer,
      ),
      TechnicianWorkflowPhase.serviceRecorded => (
        Icons.fact_check_outlined,
        scheme.surfaceContainerHighest,
      ),
      TechnicianWorkflowPhase.completed => (
        Icons.check_circle_outline,
        scheme.primaryContainer,
      ),
      TechnicianWorkflowPhase.rejectedOrCancelled => (
        Icons.cancel_outlined,
        scheme.errorContainer,
      ),
    };
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: scheme.onSurface),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'স্ট্যাটাস',
                    style: Theme.of(
                      context,
                    ).textTheme.labelLarge?.copyWith(color: scheme.primary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    phase.labelBn,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TechnicianAnimalCustomerSummary extends StatelessWidget {
  const TechnicianAnimalCustomerSummary({
    super.key,
    this.animal,
    this.customer,
  });

  final TechnicianAnimalSummary? animal;
  final TechnicianCustomerSummary? customer;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final a = animal;
    final c = customer;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.pets_outlined, color: scheme.primary, size: 22),
                const SizedBox(width: 8),
                Text(
                  'পশু ও গ্রাহক',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (a != null) ...[
              _line(context, 'নাম', a.name),
              if (a.species?.trim().isNotEmpty == true)
                _line(context, 'প্রাণীর ধরন', a.species!),
              if (a.animalType?.trim().isNotEmpty == true)
                _line(context, 'টাইপ', a.animalType!),
              if (a.breed?.trim().isNotEmpty == true)
                _line(context, 'জাত', a.breed!),
            ] else
              Text(
                'পশুর তথ্য পাওয়া যায়নি',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            const Divider(height: 28),
            Row(
              children: [
                Icon(Icons.person_outline, color: scheme.primary, size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    c?.displayLineBn ?? 'গ্রাহক —',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Widget _line(BuildContext context, String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              title,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(body, style: Theme.of(context).textTheme.bodyLarge),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';
import 'package:pranidoctor_mobile/src/features/service_requests/data/service_request_model.dart';

class ServiceRequestNotesSection extends StatelessWidget {
  const ServiceRequestNotesSection({super.key, required this.notes});

  final List<ServiceRequestNote> notes;

  @override
  Widget build(BuildContext context) {
    if (notes.isEmpty) return const SizedBox.shrink();

    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'নোট ও মন্তব্য',
          style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: PraniSpacing.sm),
        ...notes.map(
          (n) => Card(
            margin: const EdgeInsets.only(bottom: PraniSpacing.sm),
            child: ListTile(
              title: Text(n.body.isEmpty ? '—' : n.body),
              subtitle: Text(
                [
                  if (n.authorLabel != null && n.authorLabel!.trim().isNotEmpty)
                    n.authorLabel!.trim(),
                  if (n.createdAt != null)
                    '${n.createdAt!.toLocal().day}/${n.createdAt!.toLocal().month}/${n.createdAt!.toLocal().year}',
                ].join(' · '),
                style: textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

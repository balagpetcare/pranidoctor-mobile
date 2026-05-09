import 'package:flutter/material.dart';

import 'package:pranidoctor_mobile/src/core/constants/pd_spacing.dart';
import 'package:pranidoctor_mobile/src/core/widgets/pd_app_card.dart';

/// Summary card for assigned doctor or technician (best-effort from API maps).
class AssignedProviderCard extends StatelessWidget {
  const AssignedProviderCard({
    super.key,
    required this.roleLabelBn,
    required this.displayName,
    this.phone,
  });

  final String roleLabelBn;
  final String displayName;
  final String? phone;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return PdAppCard(
      useShadow: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: scheme.primaryContainer,
            foregroundColor: scheme.onPrimaryContainer,
            child: Icon(
              roleLabelBn.contains('ডাক্তার')
                  ? Icons.medical_services_outlined
                  : Icons.engineering_outlined,
            ),
          ),
          const SizedBox(width: PdSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  roleLabelBn,
                  style: textTheme.labelLarge?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  displayName,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (phone != null && phone!.trim().isNotEmpty) ...[
                  const SizedBox(height: PdSpacing.xs),
                  Text(
                    phone!.trim(),
                    style: textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

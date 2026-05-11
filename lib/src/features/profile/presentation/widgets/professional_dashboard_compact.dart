import 'package:flutter/material.dart';

import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';
import 'package:pranidoctor_mobile/src/features/profile/presentation/widgets/professional_dashboard_card.dart';

class ProfessionalDashboardCompact extends StatelessWidget {
  const ProfessionalDashboardCompact({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            2,
            PraniSpacing.xs,
            4,
            PraniSpacing.xs,
          ),
          child: Text(
            'প্রফেশনাল ড্যাশবোর্ড',
            style: textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: scheme.onSurfaceVariant,
              letterSpacing: 0.1,
            ),
          ),
        ),
        const ProfessionalDashboardCard(),
      ],
    );
  }
}

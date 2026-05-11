import 'package:flutter/material.dart';

import 'package:pranidoctor_mobile/src/features/profile/presentation/widgets/professional_state_views/professional_dashboard_card_layout.dart';

/// Compact verified professional tile with badge and dashboard CTA.
class ApprovedProfessionalView extends StatelessWidget {
  const ApprovedProfessionalView({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onOpenDashboard,
    this.actionsDisabled = false,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onOpenDashboard;
  final bool actionsDisabled;

  @override
  Widget build(BuildContext context) {
    return ProfessionalDashboardCardLayout(
      icon: icon,
      title: title,
      subtitle: subtitle,
      statusBadge: const ProfessionalStatusBadge(
        label: 'Verified',
        tone: ProfessionalStatusBadgeTone.success,
      ),
      trailing: CompactDashboardButton(
        label: 'Dashboard',
        onPressed: onOpenDashboard,
        filled: true,
        disabled: actionsDisabled,
      ),
    );
  }
}

import 'package:flutter/material.dart';

import 'package:pranidoctor_mobile/src/features/profile/presentation/widgets/professional_state_views/professional_dashboard_card_layout.dart';

/// Compact pending review tile with status badge and view CTA.
class PendingReviewView extends StatelessWidget {
  const PendingReviewView({
    super.key,
    required this.onViewApplication,
    this.actionsDisabled = false,
  });

  final VoidCallback onViewApplication;
  final bool actionsDisabled;

  @override
  Widget build(BuildContext context) {
    return ProfessionalDashboardCardLayout(
      icon: Icons.hourglass_top_outlined,
      title: 'Under Review',
      subtitle: 'আপনার আবেদন যাচাই করা হচ্ছে',
      statusBadge: const ProfessionalStatusBadge(
        label: 'Pending',
        tone: ProfessionalStatusBadgeTone.warning,
      ),
      trailing: CompactDashboardButton(
        label: 'View',
        onPressed: onViewApplication,
        disabled: actionsDisabled,
      ),
    );
  }
}

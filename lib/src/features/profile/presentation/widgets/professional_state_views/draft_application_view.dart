import 'package:flutter/material.dart';

import 'package:pranidoctor_mobile/src/features/profile/presentation/widgets/professional_state_views/professional_dashboard_card_layout.dart';

/// Compact draft application tile with progress indicator and continue CTA.
class DraftApplicationView extends StatelessWidget {
  const DraftApplicationView({
    super.key,
    required this.onContinue,
    this.completionPercent,
    this.actionsDisabled = false,
  });

  final VoidCallback onContinue;
  final int? completionPercent;
  final bool actionsDisabled;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final percent = completionPercent;

    return ProfessionalDashboardCardLayout(
      icon: Icons.edit_note_outlined,
      title: 'Application In Progress',
      subtitle: 'আপনার আবেদন এখনো সম্পূর্ণ হয়নি',
      helper: percent != null
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    value: percent / 100,
                    strokeWidth: 2.5,
                    backgroundColor: scheme.outlineVariant.withValues(alpha: 0.4),
                    valueColor: AlwaysStoppedAnimation(scheme.primary),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '$percent%',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: scheme.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                ),
              ],
            )
          : null,
      trailing: CompactDashboardButton(
        label: 'Continue',
        onPressed: onContinue,
        filled: true,
        disabled: actionsDisabled,
      ),
    );
  }
}

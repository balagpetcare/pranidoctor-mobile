import 'package:flutter/material.dart';

import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_info_card.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/application/ai_technician_dashboard_ui_helpers.dart';

/// Request pipeline strip: info card + tappable rows (values from parent).
class TechnicianRequestStatusGrid extends StatelessWidget {
  const TechnicianRequestStatusGrid({
    super.key,
    required this.infoTitle,
    required this.infoSubtitle,
    required this.rows,
    required this.onOpenRequests,
    this.unavailableMark = kAiTechnicianDashboardUnavailableMark,
  });

  final String infoTitle;
  final String infoSubtitle;
  final List<TechnicianRequestStatusRowData> rows;
  final VoidCallback onOpenRequests;
  final String unavailableMark;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return PraniInfoCard(
      title: infoTitle,
      subtitle: infoSubtitle,
      leadingIcon: Icon(Icons.info_outline_rounded, color: scheme.primary),
      padding: const EdgeInsets.all(PraniSpacing.lg),
      child: Column(
        children: rows
            .map(
              (r) => _RequestStatusRow(
                label: r.label,
                icon: r.icon,
                value: r.displayValue ?? unavailableMark,
                onTap: onOpenRequests,
              ),
            )
            .toList(),
      ),
    );
  }
}

class TechnicianRequestStatusRowData {
  const TechnicianRequestStatusRowData({
    required this.label,
    required this.icon,
    this.displayValue,
  });

  final String label;
  final IconData icon;

  /// When null, [TechnicianRequestStatusGrid] uses [unavailableMark].
  final String? displayValue;
}

class _RequestStatusRow extends StatelessWidget {
  const _RequestStatusRow({
    required this.label,
    required this.icon,
    required this.value,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: PraniSpacing.xs),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(PraniRadius.sm),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: PraniSpacing.sm,
              horizontal: PraniSpacing.xs,
            ),
            child: Row(
              children: [
                Icon(icon, size: 22, color: scheme.primary),
                const SizedBox(width: PraniSpacing.sm),
                Expanded(child: Text(label, style: textTheme.bodyMedium)),
                Text(
                  value,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: scheme.outline),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_buttons.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_premium_card.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_section_header.dart';

/// Primary workspace shortcuts — tab switches are wired by the parent (shell).
class DoctorEnterpriseQuickActions extends StatelessWidget {
  const DoctorEnterpriseQuickActions({
    super.key,
    required this.onNewPrescription,
    required this.onViewPatients,
    required this.onUpcomingAppointments,
    required this.onEmergencyCases,
  });

  final VoidCallback onNewPrescription;
  final VoidCallback onViewPatients;
  final VoidCallback onUpcomingAppointments;
  final VoidCallback onEmergencyCases;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const PraniSectionHeader(
          title: 'দ্রুত অ্যাকশন',
          subtitle: 'কর্মদিবসের শর্টকাট',
          leadingIcon: Icons.bolt_rounded,
        ),
        const SizedBox(height: PraniSpacing.md),
        PraniPremiumCard(
          padding: const EdgeInsets.all(PraniSpacing.lg),
          child: LayoutBuilder(
            builder: (context, c) {
              final narrow = c.maxWidth < 400;
              final gap = PraniSpacing.sm;
              final w = narrow ? c.maxWidth : (c.maxWidth - gap) / 2;

              Widget cell({
                required String label,
                required IconData icon,
                required VoidCallback onTap,
              }) {
                return SizedBox(
                  width: narrow ? double.infinity : w,
                  child: PraniPrimaryButton(
                    label: label,
                    icon: icon,
                    fullWidth: true,
                    minimumHeight: 48,
                    onPressed: onTap,
                  ),
                );
              }

              final children = <Widget>[
                cell(
                  label: 'নতুন প্রেসক্রিপশন',
                  icon: Icons.medication_outlined,
                  onTap: onNewPrescription,
                ),
                cell(
                  label: 'রোগী দেখুন',
                  icon: Icons.groups_outlined,
                  onTap: onViewPatients,
                ),
                cell(
                  label: 'আসন্ন অ্যাপয়েন্টমেন্ট',
                  icon: Icons.event_available_outlined,
                  onTap: onUpcomingAppointments,
                ),
                cell(
                  label: 'জরুরি কেস',
                  icon: Icons.emergency_outlined,
                  onTap: onEmergencyCases,
                ),
              ];

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < children.length; i++) ...[
                    if (i > 0) SizedBox(height: gap),
                    children[i],
                  ],
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

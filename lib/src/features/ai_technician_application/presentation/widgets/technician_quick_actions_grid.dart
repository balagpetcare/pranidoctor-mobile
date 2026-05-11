import 'package:flutter/material.dart';

import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_buttons.dart';

/// Two-column quick actions; optional gating when [approvedLike] is false.
class TechnicianQuickActionsGrid extends StatelessWidget {
  const TechnicianQuickActionsGrid({
    super.key,
    required this.approvedLike,
    required this.onOpenRequests,
    required this.onNewService,
    required this.onOpenServices,
    required this.onEditProfile,
    required this.onDocuments,
    required this.onSupport,
    required this.onApplicationStatus,
    this.gatingMessage = 'এই কাজের জন্য অনুমোদন প্রয়োজন।',
  });

  final bool approvedLike;
  final VoidCallback onOpenRequests;
  final VoidCallback onNewService;
  final VoidCallback onOpenServices;
  final VoidCallback onEditProfile;
  final VoidCallback onDocuments;
  final VoidCallback onSupport;
  final VoidCallback onApplicationStatus;
  final String gatingMessage;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final gap = PraniSpacing.sm;
        final w = (c.maxWidth - gap) / 2;

        Widget cell({
          required String label,
          required IconData icon,
          required VoidCallback onTap,
          bool enabled = true,
        }) {
          return SizedBox(
            width: w,
            child: Opacity(
              opacity: enabled ? 1 : 0.45,
              child: PraniSecondaryButton(
                label: label,
                icon: icon,
                fullWidth: true,
                minimumHeight: 46,
                onPressed: enabled
                    ? onTap
                    : () {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(gatingMessage)));
                      },
              ),
            ),
          );
        }

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            cell(
              label: 'কাজের অনুরোধ',
              icon: Icons.assignment_outlined,
              onTap: onOpenRequests,
              enabled: approvedLike,
            ),
            cell(
              label: 'নতুন সার্ভিস',
              icon: Icons.add_circle_outline_rounded,
              onTap: onNewService,
              enabled: approvedLike,
            ),
            cell(
              label: 'সার্ভিস তালিকা',
              icon: Icons.list_alt_rounded,
              onTap: onOpenServices,
              enabled: true,
            ),
            cell(
              label: 'প্রোফাইল এডিট',
              icon: Icons.edit_outlined,
              onTap: onEditProfile,
              enabled: true,
            ),
            cell(
              label: 'ডকুমেন্ট আপলোড',
              icon: Icons.upload_file_outlined,
              onTap: onDocuments,
              enabled: true,
            ),
            cell(
              label: 'সাপোর্ট',
              icon: Icons.support_agent_rounded,
              onTap: onSupport,
              enabled: true,
            ),
            cell(
              label: 'আবেদনের অবস্থা',
              icon: Icons.fact_check_outlined,
              onTap: onApplicationStatus,
              enabled: true,
            ),
          ],
        );
      },
    );
  }
}

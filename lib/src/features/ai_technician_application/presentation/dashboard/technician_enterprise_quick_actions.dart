import 'package:flutter/material.dart';

import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_buttons.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_premium_card.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_section_header.dart';

class TechnicianEnterpriseQuickActions extends StatelessWidget {
  const TechnicianEnterpriseQuickActions({
    super.key,
    required this.approvedLike,
    required this.onStartNewService,
    required this.onViewRequests,
    required this.onCheckEarnings,
    required this.onUpdateAvailability,
    this.gatingMessage = 'এই কাজের জন্য অনুমোদন প্রয়োজন।',
  });

  final bool approvedLike;
  final VoidCallback onStartNewService;
  final VoidCallback onViewRequests;
  final VoidCallback onCheckEarnings;
  final VoidCallback onUpdateAvailability;
  final String gatingMessage;

  void _gateOr(BuildContext context, VoidCallback fn) {
    if (!approvedLike) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(gatingMessage)),
      );
      return;
    }
    fn();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const PraniSectionHeader(
          title: 'দ্রুত অ্যাকশন',
          subtitle: 'প্রতিদিনের কাজ',
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
                bool needsApproval = true,
              }) {
                return SizedBox(
                  width: narrow ? double.infinity : w,
                  child: PraniPrimaryButton(
                    label: label,
                    icon: icon,
                    fullWidth: true,
                    minimumHeight: 48,
                    onPressed: () {
                      if (needsApproval) {
                        _gateOr(context, onTap);
                      } else {
                        onTap();
                      }
                    },
                  ),
                );
              }

              final children = <Widget>[
                cell(
                  label: 'নতুন সেবা শুরু',
                  icon: Icons.play_circle_outline_rounded,
                  onTap: onStartNewService,
                ),
                cell(
                  label: 'অনুরোধ দেখুন',
                  icon: Icons.assignment_outlined,
                  onTap: onViewRequests,
                  needsApproval: false,
                ),
                cell(
                  label: 'আয় দেখুন',
                  icon: Icons.account_balance_wallet_outlined,
                  onTap: onCheckEarnings,
                  needsApproval: false,
                ),
                cell(
                  label: 'উপলব্ধতা আপডেট',
                  icon: Icons.tune_rounded,
                  onTap: onUpdateAvailability,
                  needsApproval: false,
                ),
              ];

              if (narrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < children.length; i++) ...[
                      if (i > 0) SizedBox(height: gap),
                      children[i],
                    ],
                  ],
                );
              }
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: children,
              );
            },
          ),
        ),
      ],
    );
  }
}

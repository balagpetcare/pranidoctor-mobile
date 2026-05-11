import 'package:flutter/material.dart';

import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_buttons.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_empty_state.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_premium_card.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_section_header.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/data/ai_technician_models.dart';

/// Active services list + CTAs; empty state when [services] is empty.
class TechnicianActiveServicesSection extends StatelessWidget {
  const TechnicianActiveServicesSection({
    super.key,
    required this.approvedLike,
    required this.services,
    required this.onOpenServicesList,
    required this.onOpenNewService,
    this.sectionTitle = 'সক্রিয় সার্ভিস',
    this.sectionSubtitleApproved = 'খামারিদের জন্য প্রদর্শিত সেবা',
    this.sectionSubtitlePending = 'অনুমোদনের পর সক্রিয় করা যাবে',
    this.viewAllLabel = 'সব দেখুন',
    this.primaryCtaLabel = 'নতুন সার্ভিস তৈরি করুন',
    this.secondaryCtaLabel = 'সার্ভিস তালিকা',
    this.emptyTitle = 'কোনো সক্রিয় সার্ভিস নেই',
    this.emptyMessageApproved = 'নতুন সার্ভিস যোগ করে খামারিদের কাছে দেখান।',
    this.emptyMessagePending = 'অনুমোদনের পর সার্ভিস তৈরি করা যাবে।',
    this.emptyActionLabel = 'সার্ভিস তালিকা',
  });

  final bool approvedLike;
  final List<AiTechnicianServiceRow> services;
  final VoidCallback onOpenServicesList;
  final VoidCallback onOpenNewService;
  final String sectionTitle;
  final String sectionSubtitleApproved;
  final String sectionSubtitlePending;
  final String viewAllLabel;
  final String primaryCtaLabel;
  final String secondaryCtaLabel;
  final String emptyTitle;
  final String emptyMessageApproved;
  final String emptyMessagePending;
  final String emptyActionLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PraniSectionHeader(
          title: sectionTitle,
          subtitle: approvedLike
              ? sectionSubtitleApproved
              : sectionSubtitlePending,
          leadingIcon: Icons.home_repair_service_outlined,
          actionLabel: viewAllLabel,
          onAction: onOpenServicesList,
        ),
        const SizedBox(height: PraniSpacing.md),
        PraniPremiumCard(
          padding: const EdgeInsets.all(PraniSpacing.xl),
          child: services.isEmpty
              ? PraniEmptyState(
                  title: emptyTitle,
                  message: approvedLike
                      ? emptyMessageApproved
                      : emptyMessagePending,
                  icon: Icons.playlist_add_check_outlined,
                  boxed: false,
                  actionLabel: approvedLike ? emptyActionLabel : null,
                  onAction: approvedLike ? onOpenServicesList : null,
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: services.map((s) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: PraniSpacing.sm),
                      child: Material(
                        color: scheme.surfaceContainerHighest.withValues(
                          alpha: 0.35,
                        ),
                        borderRadius: BorderRadius.circular(PraniRadius.md),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(PraniRadius.md),
                          onTap: onOpenServicesList,
                          child: Padding(
                            padding: const EdgeInsets.all(PraniSpacing.md),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  s.title,
                                  style: textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: PraniSpacing.xxs),
                                Text(
                                  '${AiTechnicianAnimalTypes.labelBn(s.animalType)} · ৳${s.basePrice}',
                                  style: PraniTextStyles.bodyMuted(
                                    scheme,
                                    textTheme,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
        ),
        const SizedBox(height: PraniSpacing.md),
        if (approvedLike)
          PraniPrimaryButton(
            label: primaryCtaLabel,
            onPressed: onOpenNewService,
          ),
        if (approvedLike) const SizedBox(height: PraniSpacing.sm),
        PraniSecondaryButton(
          label: secondaryCtaLabel,
          fullWidth: true,
          onPressed: onOpenServicesList,
        ),
      ],
    );
  }
}

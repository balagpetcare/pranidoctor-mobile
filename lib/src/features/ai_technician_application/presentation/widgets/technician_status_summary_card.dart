import 'package:flutter/material.dart';

import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_premium_card.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/application/ai_technician_dashboard_ui_helpers.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/data/ai_technician_models.dart';

/// Hero summary: name, role, publish + pipeline chips, completion, service area, notes.
class TechnicianStatusSummaryCard extends StatelessWidget {
  const TechnicianStatusSummaryCard({
    super.key,
    required this.profile,
    required this.applicationStatus,
    required this.published,
    required this.completionPercent,
    required this.approvedLike,
    this.correctionNote,
    this.adminNote,
    this.roleLabel = 'এআই টেকনিশিয়ান',
    this.nameFallback = 'টেকনিশিয়ানের নাম যোগ করুন',

    /// Dashboard aggregate when present; falls back to [profile.providerStatus].
    this.providerStatusCodeOverride,
  });

  final AiTechnicianProfile profile;
  final String applicationStatus;
  final bool published;
  final int completionPercent;
  final bool approvedLike;
  final String? correctionNote;
  final String? adminNote;
  final String roleLabel;
  final String nameFallback;
  final String? providerStatusCodeOverride;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final name = profile.displayName?.trim().isNotEmpty == true
        ? profile.displayName!.trim()
        : nameFallback;
    final initial = name.isNotEmpty
        ? String.fromCharCode(name.runes.first).toUpperCase()
        : '?';

    final verified =
        profile.verifiedAt != null && profile.verifiedAt!.trim().isNotEmpty;
    final providerCode = providerStatusCodeOverride?.trim().isNotEmpty == true
        ? providerStatusCodeOverride!.trim()
        : profile.providerStatus;

    return PraniPremiumCard(
      padding: const EdgeInsets.all(PraniSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: scheme.primaryContainer,
                foregroundColor: scheme.onPrimaryContainer,
                child: Text(
                  initial,
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: PraniSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: PraniTextStyles.cardTitleProminent(
                        scheme,
                        textTheme,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: PraniSpacing.xxs),
                    Text(
                      roleLabel,
                      style: PraniTextStyles.bodyMuted(scheme, textTheme),
                    ),
                    const SizedBox(height: PraniSpacing.sm),
                    Wrap(
                      spacing: PraniSpacing.sm,
                      runSpacing: PraniSpacing.xs,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Chip(
                          avatar: Icon(
                            published ? Icons.public : Icons.lock_outline,
                            size: 18,
                            color: scheme.onSecondaryContainer,
                          ),
                          label: Text(
                            published ? 'প্রকাশিত' : 'অপ্রকাশিত',
                            style: textTheme.labelMedium,
                          ),
                          backgroundColor: scheme.secondaryContainer,
                          side: BorderSide.none,
                        ),
                        Chip(
                          label: Text(
                            AiTechnicianStatusCopy.titleBn(applicationStatus),
                            style: textTheme.labelMedium,
                          ),
                          backgroundColor: scheme.primaryContainer,
                          side: BorderSide.none,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                verified
                    ? Icons.verified_rounded
                    : Icons.pending_actions_outlined,
                color: verified ? scheme.primary : scheme.outline,
                size: 28,
                semanticLabel: verified ? 'যাচাইকৃত' : 'যাচাই অপেক্ষমাণ',
              ),
            ],
          ),
          const SizedBox(height: PraniSpacing.md),
          Text(
            'যাচাই অবস্থা: ${aiTechnicianProviderStatusLabelBn(providerCode)}',
            style: PraniTextStyles.body(
              scheme,
              textTheme,
            ).copyWith(height: 1.38),
          ),
          const SizedBox(height: PraniSpacing.sm),
          Text(
            'প্রোফাইল সম্পূর্ণতা: $completionPercent%',
            style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: PraniSpacing.xs),
          ClipRRect(
            borderRadius: BorderRadius.circular(PraniRadius.pill),
            child: LinearProgressIndicator(
              value: completionPercent / 100.0,
              minHeight: 8,
              backgroundColor: scheme.surfaceContainerHighest,
            ),
          ),
          const SizedBox(height: PraniSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.location_on_outlined, size: 20, color: scheme.primary),
              const SizedBox(width: PraniSpacing.sm),
              Expanded(
                child: Text(
                  aiTechnicianServiceAreaLine(profile),
                  style: textTheme.bodySmall?.copyWith(height: 1.4),
                ),
              ),
            ],
          ),
          const SizedBox(height: PraniSpacing.md),
          Text(
            AiTechnicianStatusCopy.messageBn(applicationStatus),
            style: textTheme.bodyMedium?.copyWith(height: 1.45),
          ),
          if (!approvedLike &&
              (correctionNote?.trim().isNotEmpty ?? false)) ...[
            const SizedBox(height: PraniSpacing.md),
            Text(
              'সংশোধন নোট',
              style: textTheme.labelLarge?.copyWith(
                color: scheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: PraniSpacing.xs),
            Text(
              correctionNote!.trim(),
              style: textTheme.bodyMedium?.copyWith(height: 1.42),
            ),
          ],
          if (!approvedLike && (adminNote?.trim().isNotEmpty ?? false)) ...[
            const SizedBox(height: PraniSpacing.md),
            Text(
              'অ্যাডমিন নোট',
              style: textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: PraniSpacing.xs),
            Text(
              adminNote!.trim(),
              style: textTheme.bodyMedium?.copyWith(height: 1.42),
            ),
          ],
        ],
      ),
    );
  }
}

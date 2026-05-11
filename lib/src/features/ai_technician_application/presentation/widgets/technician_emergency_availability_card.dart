import 'package:flutter/material.dart';

import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_premium_card.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/application/ai_technician_dashboard_ui_helpers.dart';

/// Emergency AI service toggle with Bengali copy and last-updated line.
class TechnicianEmergencyAvailabilityCard extends StatelessWidget {
  const TechnicianEmergencyAvailabilityCard({
    super.key,
    required this.acceptsEmergency,
    required this.published,
    required this.busy,
    required this.profileUpdatedAtIso,
    required this.onToggle,
    this.enabledExplanationPublished =
        'রাত বা জরুরি কলের জন্য প্রস্তুত থাকলে চালু রাখুন। বন্ধ থাকলে সাধারণ সময়ের অনুরোধই দেখবেন।',
    this.disabledExplanationUnpublished =
        'প্রোফাইল প্রকাশিত হলে জরুরি গ্রহণ চালু করা যাবে।',
  });

  final bool acceptsEmergency;
  final bool published;
  final bool busy;
  final String profileUpdatedAtIso;
  final ValueChanged<bool> onToggle;
  final String enabledExplanationPublished;
  final String disabledExplanationUnpublished;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return PraniPremiumCard(
      padding: const EdgeInsets.all(PraniSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                acceptsEmergency
                    ? Icons.flash_on_rounded
                    : Icons.flash_off_rounded,
                color: acceptsEmergency ? scheme.primary : scheme.outline,
              ),
              const SizedBox(width: PraniSpacing.sm),
              Expanded(
                child: Text(
                  acceptsEmergency
                      ? 'জরুরি সেবা চালু আছে'
                      : 'জরুরি সেবা বন্ধ আছে',
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (published && !busy)
                Switch.adaptive(value: acceptsEmergency, onChanged: onToggle)
              else if (busy)
                const SizedBox(
                  width: 28,
                  height: 28,
                  child: Padding(
                    padding: EdgeInsets.all(4),
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  ),
                )
              else
                Switch.adaptive(value: acceptsEmergency, onChanged: null),
            ],
          ),
          const SizedBox(height: PraniSpacing.sm),
          Text(
            published
                ? enabledExplanationPublished
                : disabledExplanationUnpublished,
            style: PraniTextStyles.bodyMuted(
              scheme,
              textTheme,
            ).copyWith(height: 1.45),
          ),
          const SizedBox(height: PraniSpacing.md),
          Text(
            'শেষ আপডেট: ${aiTechnicianShortUpdatedLabel(profileUpdatedAtIso)}',
            style: textTheme.labelSmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

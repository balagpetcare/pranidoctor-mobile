import 'package:flutter/material.dart';

import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';

/// Enterprise checklist before continuing to service creation.
class BeforeYouProceedChecklist extends StatelessWidget {
  const BeforeYouProceedChecklist({
    super.key,
    required this.scrollFraction,
    required this.scrollOverrideChecked,
    required this.onScrollOverrideChanged,
    required this.hasWarnings,
    required this.warningAcknowledged,
    required this.onWarningAckChanged,
    required this.hasSopOrProtocol,
    required this.sopConfirmed,
    required this.onSopConfirmedChanged,
    required this.optionalMediaAcknowledged,
    required this.onOptionalMediaAckChanged,
    required this.showOptionalMediaRow,
    this.onFutureAiNarration,
  });

  final double scrollFraction;
  final bool scrollOverrideChecked;
  final ValueChanged<bool?> onScrollOverrideChanged;

  final bool hasWarnings;
  final bool warningAcknowledged;
  final ValueChanged<bool?> onWarningAckChanged;

  final bool hasSopOrProtocol;
  final bool sopConfirmed;
  final ValueChanged<bool?> onSopConfirmedChanged;

  final bool optionalMediaAcknowledged;
  final ValueChanged<bool?> onOptionalMediaAckChanged;
  final bool showOptionalMediaRow;

  final VoidCallback? onFutureAiNarration;

  bool get readingGateOk => scrollFraction >= 0.55 || scrollOverrideChecked;

  bool get mandatoryOk {
    if (hasWarnings && !warningAcknowledged) return false;
    if (hasSopOrProtocol && !sopConfirmed) return false;
    return readingGateOk;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AnimatedContainer(
      duration: PraniDurations.medium,
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.all(PraniSpacing.xl),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(PraniRadius.xl),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.fact_check_rounded, color: scheme.primary),
              const SizedBox(width: PraniSpacing.sm),
              Expanded(
                child: Text(
                  'এগিয়ে যাওয়ার আগে',
                  style: PraniTextStyles.heading(
                    scheme,
                    textTheme,
                  ).copyWith(fontSize: 17),
                ),
              ),
            ],
          ),
          const SizedBox(height: PraniSpacing.md),
          Text(
            'পড়ার অগ্রগতি: ${(scrollFraction * 100).clamp(0, 100).toStringAsFixed(0)}%',
            style: PraniTextStyles.bodyMuted(scheme, textTheme),
          ),
          const SizedBox(height: PraniSpacing.sm),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            value: scrollOverrideChecked,
            onChanged: onScrollOverrideChanged,
            title: Text(
              'আমি উপরের নির্দেশনা ও মিডিয়া ম্যানুয়ালি পড়েছি (স্ক্রল ট্র্যাকিং ছাড়াই)',
              style: PraniTextStyles.bodySmall(scheme, textTheme),
            ),
          ),
          if (hasWarnings)
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              value: warningAcknowledged,
              onChanged: onWarningAckChanged,
              title: Text(
                'আমি সতর্কতা ও প্রতিবন্ধক বিভাগ পড়েছি এবং বুঝেছি',
                style: PraniTextStyles.bodySmall(
                  scheme,
                  textTheme,
                ).copyWith(fontWeight: FontWeight.w600, color: scheme.error),
              ),
            ),
          if (hasSopOrProtocol)
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              value: sopConfirmed,
              onChanged: onSopConfirmedChanged,
              title: Text(
                'আমি সংশ্লিষ্ট SOP / প্রোটোকল পর্যালোচনা করেছি',
                style: PraniTextStyles.bodySmall(scheme, textTheme),
              ),
            ),
          if (showOptionalMediaRow)
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              value: optionalMediaAcknowledged,
              onChanged: onOptionalMediaAckChanged,
              title: Text(
                'আমি প্রাথমিক ভিডিও/ছবি সেকশন দেখেছি (ঐচ্ছিক, সুপারিশকৃত)',
                style: PraniTextStyles.bodySmall(scheme, textTheme),
              ),
            ),
          if (onFutureAiNarration != null) ...[
            const SizedBox(height: PraniSpacing.sm),
            TextButton.icon(
              onPressed: onFutureAiNarration,
              icon: const Icon(Icons.graphic_eq_outlined, size: 18),
              label: const Text('AI ন্যারেটেড টিউটোরিয়াল (শীঘ্রই)'),
            ),
          ],
        ],
      ),
    );
  }
}

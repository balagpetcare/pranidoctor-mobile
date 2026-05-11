import 'package:flutter/material.dart';

import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';

/// Progress label + linear indicator for multi-step flows (Bengali-first).
class PraniStepProgressHeader extends StatelessWidget {
  const PraniStepProgressHeader({
    super.key,
    required this.stepIndexZeroBased,
    required this.totalSteps,
    required this.stepTitleBn,
    this.alertChildren = const [],
    this.compact = false,
  });

  /// 0-based step index (shown as “ধাপ N / …” with N = index + 1).
  final int stepIndexZeroBased;

  final int totalSteps;
  final String stepTitleBn;

  /// Correction notes, step errors, etc. — shown above the progress row.
  final List<Widget> alertChildren;

  /// Tighter typography and thinner bar for dense wizards.
  final bool compact;

  String _toBnDigits(int value) {
    const en = '0123456789';
    const bn = '০১২৩৪৫৬৭৮৯';
    return value.toString().split('').map((ch) {
      final i = en.indexOf(ch);
      return i >= 0 ? bn[i] : ch;
    }).join();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final n = (stepIndexZeroBased + 1).clamp(1, totalSteps);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (alertChildren.isNotEmpty) ...[
          ...alertChildren,
          SizedBox(height: compact ? PraniSpacing.xs : PraniSpacing.sm),
        ],
        Text(
          'ধাপ ${_toBnDigits(n)} / ${_toBnDigits(totalSteps)} · $stepTitleBn',
          style: PraniTextStyles.subheading(scheme, textTheme).copyWith(
            fontSize: compact ? 15 : 18,
            fontWeight: FontWeight.w600,
            color: scheme.onSurface,
          ),
        ),
        SizedBox(height: compact ? 4 : PraniSpacing.xs),
        ClipRRect(
          borderRadius: BorderRadius.circular(PraniRadius.sm),
          child: LinearProgressIndicator(
            value: n / totalSteps,
            minHeight: compact ? 5 : 8,
            backgroundColor: scheme.surfaceContainerHighest,
            color: scheme.primary,
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';

/// Placeholder layout while template JSON loads.
class TemplateDetailSkeleton extends StatelessWidget {
  const TemplateDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final base = scheme.surfaceContainerHighest.withValues(alpha: 0.55);

    Widget bar({double h = 14, double? w}) {
      return Container(
        height: h,
        width: w,
        decoration: BoxDecoration(
          color: base,
          borderRadius: BorderRadius.circular(PraniRadius.sm),
        ),
      );
    }

    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      children: [
        bar(h: 22, w: 260),
        const SizedBox(height: PraniSpacing.lg),
        bar(h: 120),
        const SizedBox(height: PraniSpacing.xl),
        bar(h: 16, w: 180),
        const SizedBox(height: PraniSpacing.md),
        bar(h: 12),
        const SizedBox(height: PraniSpacing.xs),
        bar(h: 12, w: 220),
        const SizedBox(height: PraniSpacing.xl),
        bar(h: 16, w: 200),
        const SizedBox(height: PraniSpacing.md),
        bar(h: 10),
        const SizedBox(height: PraniSpacing.xs),
        bar(h: 10),
        const SizedBox(height: PraniSpacing.xs),
        bar(h: 10, w: 280),
        const SizedBox(height: PraniSpacing.xl),
        bar(h: 44),
      ],
    );
  }
}

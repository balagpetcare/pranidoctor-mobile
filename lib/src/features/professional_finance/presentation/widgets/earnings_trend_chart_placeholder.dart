import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';

/// Placeholder for sparkline / bar chart until analytics API is wired.
class EarningsTrendChartPlaceholder extends StatelessWidget {
  const EarningsTrendChartPlaceholder({
    super.key,
    required this.seed,
    this.titleBn = 'আয়ের প্রবণতা (প্রিভিউ)',
  });

  /// Stable hash seed (e.g. first transaction id or "0").
  final String seed;
  final String titleBn;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final h = 120.0;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(PraniSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titleBn,
              style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: PraniSpacing.xs),
            Text(
              'fl_chart বা সার্ভার সিরিজ যুক্ত করলে এখানে লাইভ চার্ট দেখানো হবে।',
              style: textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: PraniSpacing.md),
            SizedBox(
              height: h,
              width: double.infinity,
              child: CustomPaint(
                painter: _DemoBarsPainter(
                  color: scheme.primary,
                  seed: seed.hashCode,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DemoBarsPainter extends CustomPainter {
  _DemoBarsPainter({required this.color, required this.seed});

  final Color color;
  final int seed;

  @override
  void paint(Canvas canvas, Size size) {
    final rnd = math.Random(seed);
    final n = 7;
    final gap = 6.0;
    final barW = (size.width - gap * (n - 1)) / n;
    for (var i = 0; i < n; i++) {
      final h = size.height * (0.25 + rnd.nextDouble() * 0.65);
      final x = i * (barW + gap);
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, size.height - h, barW, h),
        const Radius.circular(6),
      );
      final paint = Paint()
        ..shader = LinearGradient(
          colors: [
            color.withValues(alpha: 0.35),
            color.withValues(alpha: 0.9),
          ],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
        ).createShader(rect.outerRect);
      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DemoBarsPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.seed != seed;
}

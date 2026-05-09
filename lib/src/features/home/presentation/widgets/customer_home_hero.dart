import 'package:flutter/material.dart';

import 'package:pranidoctor_mobile/src/core/assets/prani_assets.dart';
import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';

/// Teal gradient hero with greeting and farm/pet illustration.
///
/// TODO(asset): Replace with final Prani Doctor home hero illustration when supplied.
class CustomerHomeHero extends StatelessWidget {
  const CustomerHomeHero({
    super.key,
    required this.greetingLine,
    required this.subtitle,
  });

  final String greetingLine;
  final String subtitle;

  static const LinearGradient _gradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0D8A75), PraniColors.primary, Color(0xFF34C4A8)],
  );

  /// Nearest existing marketing illustration for home / vet context.
  static const String _heroAsset = PraniAssets.doctorVisitCow;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(PraniRadii.lg),
      child: DecoratedBox(
        decoration: const BoxDecoration(gradient: _gradient),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            PraniSpacing.xl,
            PraniSpacing.xl,
            PraniSpacing.xl,
            PraniSpacing.md,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final illusWidth = (constraints.maxWidth * 0.38).clamp(
                96.0,
                140.0,
              );
              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          greetingLine,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.headlineSmall?.copyWith(
                            color: PraniColors.white,
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: PraniSpacing.sm),
                        Text(
                          subtitle,
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodyLarge?.copyWith(
                            color: PraniColors.white.withValues(alpha: 0.92),
                            height: 1.45,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: PraniSpacing.sm),
                  SizedBox(
                    width: illusWidth,
                    height: illusWidth * 1.05,
                    child: Image.asset(
                      _heroAsset,
                      fit: BoxFit.contain,
                      gaplessPlayback: true,
                      semanticLabel: 'প্রাণী চিকিৎসা সংক্রান্ত চিত্র',
                      cacheWidth:
                          (illusWidth * MediaQuery.devicePixelRatioOf(context))
                              .round()
                              .clamp(120, PraniAssetDecode.heroMaxPx),
                      errorBuilder: (_, _, _) => Icon(
                        Icons.pets_rounded,
                        size: illusWidth * 0.55,
                        color: PraniColors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

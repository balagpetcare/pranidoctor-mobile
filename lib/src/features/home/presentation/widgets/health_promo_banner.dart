import 'package:flutter/material.dart';

import 'package:pranidoctor_mobile/src/core/assets/prani_assets.dart';
import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';
import 'package:pranidoctor_mobile/src/features/home/presentation/home_layout_constants.dart';

/// Vaccination promo strip — teal-tint panel with CTA.
class HealthPromoBanner extends StatelessWidget {
  const HealthPromoBanner({super.key, required this.onLearnMore});

  final VoidCallback onLearnMore;

  static const Color _panel = Color(0xFFD8F5EF);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final dpr = MediaQuery.devicePixelRatioOf(context);

    const imgMax = 96.0;
    final decode = (imgMax * dpr).round().clamp(96, PraniAssetDecode.heroMaxPx);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(HomeLayout.cardRadius),
        border: Border.all(color: PraniColors.primary.withValues(alpha: 0.14)),
        boxShadow: PraniShadows.homeCardSoft,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          PraniSpacing.xl,
          PraniSpacing.lg,
          PraniSpacing.md,
          PraniSpacing.lg,
        ),
        child: LayoutBuilder(
          builder: (context, c) {
            final narrow = c.maxWidth < 340;
            final textCol = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'নিয়মিত টিকাদান করুন',
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurface,
                    height: 1.28,
                  ),
                ),
                const SizedBox(height: PraniSpacing.xxs),
                Text(
                  'সুস্থ রাখুন আপনার প্রাণীকে',
                  style: textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                    height: 1.38,
                  ),
                ),
                const SizedBox(height: PraniSpacing.md),
                Align(
                  alignment: Alignment.centerLeft,
                  child: FilledButton.tonal(
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: PraniSpacing.lg,
                        vertical: PraniSpacing.sm,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(PraniRadii.md),
                      ),
                    ),
                    onPressed: onLearnMore,
                    child: const Text('আরও জানুন'),
                  ),
                ),
              ],
            );

            final img = ClipRRect(
              borderRadius: BorderRadius.circular(PraniRadii.md),
              child: ColoredBox(
                color: PraniColors.white.withValues(alpha: 0.55),
                child: SizedBox(
                  width: narrow ? 80 : imgMax,
                  height: narrow ? 80 : imgMax,
                  child: Padding(
                    padding: const EdgeInsets.all(PraniSpacing.xs),
                    child: Image.asset(
                      PraniAssets.homePromoVaccination,
                      fit: BoxFit.contain,
                      alignment: Alignment.center,
                      gaplessPlayback: true,
                      semanticLabel: 'টিকাদান প্রচারণা চিত্র',
                      cacheWidth: decode,
                      cacheHeight: decode,
                      errorBuilder: (_, _, _) => Icon(
                        Icons.vaccines_outlined,
                        size: narrow ? 34 : 40,
                        color: scheme.primary,
                      ),
                    ),
                  ),
                ),
              ),
            );

            if (narrow) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: textCol),
                      const SizedBox(width: PraniSpacing.sm),
                      img,
                    ],
                  ),
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(flex: 3, child: textCol),
                const SizedBox(width: PraniSpacing.md),
                Flexible(flex: 2, child: img),
              ],
            );
          },
        ),
      ),
    );
  }
}

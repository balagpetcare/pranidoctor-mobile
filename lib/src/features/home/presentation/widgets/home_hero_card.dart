import 'package:flutter/material.dart';

import 'package:pranidoctor_mobile/src/core/assets/prani_assets.dart';
import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';
import 'package:pranidoctor_mobile/src/features/home/presentation/home_layout_constants.dart';

/// Teal gradient hero with greeting and illustration on the right.
class HomeHeroCard extends StatelessWidget {
  const HomeHeroCard({
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

  static const String _heroAsset = PraniAssets.homeHeroFarmVet;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(HomeLayout.cardRadius),
      child: DecoratedBox(
        decoration: const BoxDecoration(gradient: _gradient),
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            Positioned(
              right: -24,
              top: -28,
              child: IgnorePointer(
                child: Container(
                  width: 148,
                  height: 148,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: PraniColors.white.withValues(alpha: 0.07),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                PraniSpacing.lg,
                PraniSpacing.lg,
                PraniSpacing.md,
                PraniSpacing.lg,
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final w = constraints.maxWidth;
                  final narrow = w < 340;
                  final imgW = (w * 0.30).clamp(110.0, 130.0);
                  final imgBoxH = narrow
                      ? (imgW * 1.05)
                      : (188 - PraniSpacing.lg * 2).clamp(148.0, 168.0);
                  final dpr = MediaQuery.devicePixelRatioOf(context);
                  final decodeW = (imgW * dpr).round().clamp(
                    120,
                    PraniAssetDecode.heroMaxPx,
                  );
                  final decodeH = (imgBoxH * dpr).round().clamp(
                    96,
                    PraniAssetDecode.heroMaxPx,
                  );

                  Widget heroImage() {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(PraniRadii.md),
                      child: SizedBox(
                        width: imgW,
                        height: imgBoxH,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(PraniRadii.md),
                            color: PraniColors.white.withValues(alpha: 0.14),
                          ),
                          child: Image.asset(
                            _heroAsset,
                            fit: BoxFit.cover,
                            alignment: Alignment.centerRight,
                            gaplessPlayback: true,
                            filterQuality: FilterQuality.medium,
                            semanticLabel:
                                'ফার্ম ও প্রাণী চিকিৎসা সংক্রান্ত চিত্র',
                            cacheWidth: decodeW,
                            cacheHeight: decodeH,
                            errorBuilder: (_, _, _) => ColoredBox(
                              color: PraniColors.white.withValues(alpha: 0.12),
                              child: Center(
                                child: Icon(
                                  Icons.pets_rounded,
                                  size: imgW * 0.42,
                                  color: PraniColors.white.withValues(
                                    alpha: 0.92,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }

                  final textBlock = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        greetingLine,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.titleLarge?.copyWith(
                          color: PraniColors.white,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: PraniSpacing.sm),
                      Text(
                        subtitle,
                        maxLines: narrow ? 6 : 4,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodyMedium?.copyWith(
                          color: PraniColors.white.withValues(alpha: 0.93),
                          height: 1.42,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  );

                  if (narrow) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        textBlock,
                        const SizedBox(height: PraniSpacing.md),
                        Align(
                          alignment: Alignment.centerRight,
                          child: heroImage(),
                        ),
                      ],
                    );
                  }

                  return SizedBox(
                    height: 188,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: textBlock,
                          ),
                        ),
                        const SizedBox(width: PraniSpacing.sm),
                        heroImage(),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

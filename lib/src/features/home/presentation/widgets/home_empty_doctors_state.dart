import 'package:flutter/material.dart';

import 'package:pranidoctor_mobile/src/core/assets/prani_assets.dart';
import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';

/// Image-led empty state when no nearby doctors are returned.
class HomeEmptyDoctorsState extends StatelessWidget {
  const HomeEmptyDoctorsState({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final w = MediaQuery.sizeOf(context).width;
    final logicalW = (w - PraniSpacing.xl * 4).clamp(168.0, 240.0);
    final decode = (logicalW * dpr).round().clamp(
      160,
      PraniAssetDecode.heroMaxPx,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.surface,
            scheme.primaryContainer.withValues(alpha: 0.22),
          ],
        ),
        borderRadius: BorderRadius.circular(PraniRadii.lg),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.4)),
        boxShadow: PraniShadows.homeCardSoft,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          PraniSpacing.xl,
          PraniSpacing.xl,
          PraniSpacing.xl,
          PraniSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(PraniRadii.md),
              ),
              child: Padding(
                padding: const EdgeInsets.all(PraniSpacing.md),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(PraniRadii.sm),
                  child: SizedBox(
                    width: logicalW,
                    height: 118,
                    child: Image.asset(
                      PraniAssets.homeEmptyNearbyDoctors,
                      fit: BoxFit.contain,
                      alignment: Alignment.center,
                      gaplessPlayback: true,
                      cacheWidth: decode,
                      cacheHeight: (118 * dpr).round().clamp(
                        96,
                        PraniAssetDecode.heroMaxPx,
                      ),
                      semanticLabel: 'কাছাকাছি ডাক্তার নেই — চিত্র',
                      errorBuilder: (_, _, _) => Icon(
                        Icons.map_outlined,
                        size: 56,
                        color: scheme.primary.withValues(alpha: 0.65),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: PraniSpacing.md),
            Text(
              'কাছাকাছি কোনো ডাক্তার পাওয়া যায়নি',
              textAlign: TextAlign.center,
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: -0.15,
              ),
            ),
            const SizedBox(height: PraniSpacing.xs),
            Text(
              'ফিল্টার বা এলাকা পরিবর্তন করে আবার খুঁজুন, অথবা রিফ্রেশ করুন।',
              textAlign: TextAlign.center,
              style: textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
                height: 1.45,
              ),
            ),
            const SizedBox(height: PraniSpacing.md),
            FilledButton.tonalIcon(
              style: FilledButton.styleFrom(
                minimumSize: const Size(48, 44),
                padding: const EdgeInsets.symmetric(
                  horizontal: PraniSpacing.xl,
                  vertical: PraniSpacing.sm,
                ),
              ),
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 20),
              label: const Text('রিফ্রেশ করুন'),
            ),
          ],
        ),
      ),
    );
  }
}

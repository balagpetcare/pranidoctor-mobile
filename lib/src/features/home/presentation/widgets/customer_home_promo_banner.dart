import 'package:flutter/material.dart';

import 'package:pranidoctor_mobile/src/core/assets/prani_assets.dart';
import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';

/// Vaccination promo strip — teal-tint panel with CTA.
///
/// TODO(asset): Swap illustration when final vaccination campaign art is ready.
class CustomerHomePromoBanner extends StatelessWidget {
  const CustomerHomePromoBanner({super.key, required this.onLearnMore});

  final VoidCallback onLearnMore;

  static const Color _panel = Color(0xFFD8F5EF);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(PraniRadii.lg),
        border: Border.all(color: PraniColors.primary.withValues(alpha: 0.12)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(PraniSpacing.xl),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'নিয়মিত টিকাদান করুন, সুস্থ রাখুন আপনার প্রাণীকে',
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: scheme.onSurface,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: PraniSpacing.md),
                  FilledButton.tonal(
                    onPressed: onLearnMore,
                    child: const Text('আরও জানুন'),
                  ),
                ],
              ),
            ),
            const SizedBox(width: PraniSpacing.sm),
            SizedBox(
              width: 88,
              height: 88,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(PraniRadii.md),
                child: ColoredBox(
                  color: PraniColors.white.withValues(alpha: 0.6),
                  child: Image.asset(
                    // Nearest cheerful livestock / care illustration.
                    PraniAssets.homeFarmBanner,
                    fit: BoxFit.cover,
                    cacheWidth: (88 * MediaQuery.devicePixelRatioOf(context))
                        .round()
                        .clamp(96, PraniAssetDecode.heroMaxPx),
                    errorBuilder: (_, _, _) => Icon(
                      Icons.vaccines_outlined,
                      size: 40,
                      color: scheme.primary,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

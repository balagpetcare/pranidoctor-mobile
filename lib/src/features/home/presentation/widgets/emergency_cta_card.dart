import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:pranidoctor_mobile/src/core/assets/prani_assets.dart';
import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';
import 'package:pranidoctor_mobile/src/features/home/presentation/home_layout_constants.dart';

/// Emergency call card — launches [tel:] when [emergencyPhone] is non-empty.
class EmergencyCtaCard extends StatelessWidget {
  const EmergencyCtaCard({
    super.key,
    required this.emergencyPhone,
    required this.onCallUnavailable,
  });

  final String? emergencyPhone;
  final VoidCallback onCallUnavailable;

  Future<void> _tryCall() async {
    final raw = emergencyPhone?.trim();
    if (raw == null || raw.isEmpty) {
      onCallUnavailable();
      return;
    }
    final uri = Uri(scheme: 'tel', path: raw);
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok) onCallUnavailable();
    } catch (_) {
      onCallUnavailable();
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final dpr = MediaQuery.devicePixelRatioOf(context);

    const imgLogical = 72.0;
    final decode = (imgLogical * dpr).round().clamp(
      96,
      PraniAssetDecode.heroMaxPx,
    );

    Widget illustration() {
      return ClipRRect(
        borderRadius: BorderRadius.circular(PraniRadii.md),
        child: ColoredBox(
          color: PraniColors.white.withValues(alpha: 0.65),
          child: SizedBox(
            width: imgLogical,
            height: imgLogical,
            child: Image.asset(
              PraniAssets.homeEmergencyVet,
              fit: BoxFit.contain,
              alignment: Alignment.center,
              gaplessPlayback: true,
              semanticLabel: 'জরুরি ভেটেরিনারি সহকারী',
              cacheWidth: decode,
              cacheHeight: decode,
              errorBuilder: (_, _, _) => Icon(
                Icons.emergency_outlined,
                color: scheme.tertiary,
                size: 34,
              ),
            ),
          ),
        ),
      );
    }

    final copy = Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'জরুরি প্রয়োজনে কল করুন',
            style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: PraniSpacing.xxs),
          Text(
            '২৪/৭ পেট/ফার্ম প্রাণী চিকিৎসা সহায়তা',
            style: textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.38,
            ),
          ),
        ],
      ),
    );

    final button = FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: PraniColors.accent,
        foregroundColor: PraniColors.textDark,
        minimumSize: const Size(88, 44),
        padding: const EdgeInsets.symmetric(
          horizontal: PraniSpacing.lg,
          vertical: PraniSpacing.sm + 2,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PraniRadii.md),
        ),
      ),
      onPressed: () => _tryCall(),
      child: const Text('কল করুন'),
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8F2),
        borderRadius: BorderRadius.circular(HomeLayout.cardRadius),
        border: Border.all(color: PraniColors.accent.withValues(alpha: 0.35)),
        boxShadow: PraniShadows.homeCardSoft,
      ),
      child: Padding(
        padding: const EdgeInsets.all(PraniSpacing.md + 2),
        child: LayoutBuilder(
          builder: (context, c) {
            final narrow = c.maxWidth < 340;
            if (narrow) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      illustration(),
                      const SizedBox(width: PraniSpacing.md),
                      copy,
                    ],
                  ),
                  const SizedBox(height: PraniSpacing.md),
                  SizedBox(width: double.infinity, child: button),
                ],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                illustration(),
                const SizedBox(width: PraniSpacing.md),
                copy,
                const SizedBox(width: PraniSpacing.sm),
                button,
              ],
            );
          },
        ),
      ),
    );
  }
}

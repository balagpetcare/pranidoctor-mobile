import 'package:flutter/material.dart';

/// Brand image paths under `assets/brand/` (guidelines not bundled for UI).
///
/// File mapping when names differ from marketing labels:
/// - [horizontalLogo] → `prani_doctor_horizontal_wordmark.png`
/// - [homeFarmBanner] → `farm_service_banner.png`
/// - [animalEmptyState] → no separate file; uses [onboardingFarmer] artwork.
abstract final class PraniAssets {
  static const String primaryLogo =
      'assets/brand/logos/prani_doctor_primary_logo.png';

  /// Wide logo (`prani_doctor_horizontal_wordmark.png`).
  static const String horizontalLogo =
      'assets/brand/logos/prani_doctor_horizontal_wordmark.png';

  static const String appIcon =
      'assets/brand/app_icons/prani_doctor_app_icon.png';

  static const String splashFarm =
      'assets/brand/illustrations/splash_farm_livestock.png';

  static const String onboardingFarmer =
      'assets/brand/illustrations/onboarding_farmer_livestock.png';

  /// Home / service hero (`farm_service_banner.png`).
  static const String homeFarmBanner =
      'assets/brand/illustrations/farm_service_banner.png';

  static const String doctorVisitCow =
      'assets/brand/illustrations/doctor_visit_cow_farm.png';

  static const String aiTechnicianCattle =
      'assets/brand/illustrations/ai_technician_cattle_service.png';

  static const String serviceTracking =
      'assets/brand/illustrations/service_tracking_livestock_app.png';

  /// Same illustration as [onboardingFarmer] until a dedicated asset exists.
  static const String animalEmptyState = onboardingFarmer;

  static const String altLogoEarthTone =
      'assets/brand/logos/prani_doctor_alt_logo_earth_tone.png';
}

/// Decode pixel budgets for [Image.asset] `cacheWidth` / `cacheHeight` (memory).
abstract final class PraniAssetDecode {
  static const int splashBgMaxWidthPx = 720;
  static const int splashBgMaxHeightPx = 1280;
  static const int logoSquarePx = 384;
  static const int logoHeaderPx = 256;
  static const int heroMaxPx = 1200;
  static const int onboardingIllustrationMaxPx = 900;
  static const int wordmarkMaxWidthPx = 900;

  static int cacheExtentPx(BuildContext context, double logical, int maxPx) {
    final dpr = MediaQuery.devicePixelRatioOf(context);
    return (logical * dpr).round().clamp(48, maxPx);
  }
}

/// Bounded brand image for heroes, banners, and empty states.
class PraniBrandHero extends StatelessWidget {
  const PraniBrandHero({
    super.key,
    required this.assetPath,
    this.height = 160,
    this.fit = BoxFit.cover,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.alignment = Alignment.center,
    this.backgroundColor,
    this.semanticLabel,
    this.decodeMaxPx = PraniAssetDecode.heroMaxPx,
  });

  final String assetPath;
  final double height;
  final BoxFit fit;
  final BorderRadius borderRadius;
  final Alignment alignment;
  final Color? backgroundColor;
  final String? semanticLabel;
  final int decodeMaxPx;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final mq = MediaQuery.of(context);
        final dpr = mq.devicePixelRatio;
        final layoutW =
            constraints.maxWidth.isFinite && constraints.maxWidth > 0
            ? constraints.maxWidth
            : mq.size.width;
        final decodeW = (layoutW * dpr).round().clamp(120, decodeMaxPx);
        final decodeH = (height * dpr).round().clamp(80, decodeMaxPx);
        return ClipRRect(
          borderRadius: borderRadius,
          child: ColoredBox(
            color:
                backgroundColor ??
                Theme.of(context).colorScheme.surfaceContainerHighest,
            child: SizedBox(
              width: double.infinity,
              height: height,
              child: Image.asset(
                assetPath,
                fit: fit,
                alignment: alignment,
                gaplessPlayback: true,
                semanticLabel: semanticLabel,
                cacheWidth: decodeW,
                cacheHeight: decodeH,
              ),
            ),
          ),
        );
      },
    );
  }
}

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

  /// Customer home hero illustration (`assets/images/home/hero_farm_vet.png`).
  static const String homeHeroFarmVet = 'assets/images/home/hero_farm_vet.png';

  /// Nearby doctors empty state (`assets/images/home/empty_nearby_doctors.png`).
  static const String homeEmptyNearbyDoctors =
      'assets/images/home/empty_nearby_doctors.png';

  /// Emergency CTA illustration (`assets/images/home/emergency_vet.png`).
  static const String homeEmergencyVet = 'assets/images/home/emergency_vet.png';

  /// Vaccination promo banner (`assets/images/home/promo_vaccination.png`).
  static const String homePromoVaccination =
      'assets/images/home/promo_vaccination.png';

  /// Bangladesh-context onboarding / intro slides (`assets/images/onboarding/`).
  static const String onboarding01ServiceOverviewBd =
      'assets/images/onboarding/onboarding_01_service_overview_bd.png';

  static const String onboarding02FarmerVetConsultationBd =
      'assets/images/onboarding/onboarding_02_farmer_vet_consultation_bd.png';

  static const String onboarding03AiFieldSupportBd =
      'assets/images/onboarding/onboarding_03_ai_field_support_bd.png';

  static const String onboarding04GetStartedBd =
      'assets/images/onboarding/onboarding_04_get_started_bd.png';
}

/// Decode pixel budgets for [Image.asset] `cacheWidth` / `cacheHeight` (memory).
abstract final class PraniAssetDecode {
  static const int splashBgMaxWidthPx = 720;
  static const int splashBgMaxHeightPx = 1280;
  static const int logoSquarePx = 384;
  static const int logoHeaderPx = 256;
  static const int heroMaxPx = 1200;
  static const int onboardingIllustrationMaxPx = 900;

  /// Full-width onboarding photography decode cap.
  static const int onboardingBdHeroMaxPx = 1080;
  static const int wordmarkMaxWidthPx = 900;

  static int cacheExtentPx(BuildContext context, double logical, int maxPx) {
    final dpr = MediaQuery.devicePixelRatioOf(context);
    return (logical * dpr).round().clamp(48, maxPx);
  }
}

/// Bounded brand image for heroes, banners, and empty states.
///
/// When [aspectRatio] is set, height follows width (`width / aspectRatio`) so
/// the hero scales on narrow and wide phones without a fixed pixel height.
/// When null, a fixed [height] is used (legacy behavior).
class PraniBrandHero extends StatelessWidget {
  const PraniBrandHero({
    super.key,
    required this.assetPath,
    this.height = 160,
    this.aspectRatio,
    this.fit = BoxFit.cover,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.alignment = Alignment.center,
    this.backgroundColor,
    this.semanticLabel,
    this.decodeMaxPx = PraniAssetDecode.heroMaxPx,
  });

  final String assetPath;
  final double height;

  /// If non-null, layout height is `maxWidth / aspectRatio` (ignores [height]).
  final double? aspectRatio;
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
        final layoutH = aspectRatio != null && aspectRatio! > 0
            ? layoutW / aspectRatio!
            : height;
        final decodeH = (layoutH * dpr).round().clamp(80, decodeMaxPx);
        final image = Image.asset(
          assetPath,
          fit: fit,
          alignment: alignment,
          gaplessPlayback: true,
          semanticLabel: semanticLabel,
          cacheWidth: decodeW,
          cacheHeight: decodeH,
        );
        return ClipRRect(
          borderRadius: borderRadius,
          child: ColoredBox(
            color:
                backgroundColor ??
                Theme.of(context).colorScheme.surfaceContainerHighest,
            child: aspectRatio != null && aspectRatio! > 0
                ? AspectRatio(aspectRatio: aspectRatio!, child: image)
                : SizedBox(
                    width: double.infinity,
                    height: height,
                    child: image,
                  ),
          ),
        );
      },
    );
  }
}

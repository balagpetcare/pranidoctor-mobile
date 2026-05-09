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
  });

  final String assetPath;
  final double height;
  final BoxFit fit;
  final BorderRadius borderRadius;
  final Alignment alignment;
  final Color? backgroundColor;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
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
          ),
        ),
      ),
    );
  }
}

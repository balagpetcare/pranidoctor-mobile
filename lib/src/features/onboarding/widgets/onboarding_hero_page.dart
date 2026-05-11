import 'package:flutter/material.dart';

import '../../../app/screen_padding.dart';
import '../../../design_system/prani_tokens.dart';
import '../../../design_system/widgets/prani_layered_hero_image_background.dart';

/// Full-viewport onboarding slide: layered hero (blur cover + sharp contain),
/// scrim gradients, and overlay copy.
///
/// Bottom [bottomReserved] leaves space for a fixed page indicator + CTA row
/// rendered by [OnboardingScreen] so controls do not overlap text.
class OnboardingHeroPage extends StatelessWidget {
  const OnboardingHeroPage({
    super.key,
    required this.imageAsset,
    required this.title,
    required this.description,
    required this.semanticLabel,
    required this.bottomReserved,
  });

  final String imageAsset;
  final String title;
  final String description;
  final String semanticLabel;
  final double bottomReserved;

  static List<Color> _topScrimColors(ColorScheme scheme) {
    return [
      Colors.black.withValues(alpha: 0.38),
      Colors.black.withValues(alpha: 0.12),
      Colors.transparent,
    ];
  }

  static List<Color> _bottomScrimColors() {
    return [
      Colors.transparent,
      const Color(0xFF041A15).withValues(alpha: 0.72),
      const Color(0xFF020D0B).withValues(alpha: 0.92),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final pad = pdScreenPadding(context);
    final mq = MediaQuery.of(context);
    final textScaler = mq.textScaler.clamp(
      minScaleFactor: 0.85,
      maxScaleFactor: 1.35,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: PraniLayeredHeroImageBackground(
                assetPath: imageAsset,
                semanticLabel: semanticLabel,
                foregroundAlignment: const Alignment(0, -0.1),
                backgroundBlurSigma: 16,
                backgroundDarken: 0.22,
                topReserved: PraniSpacing.sm,
                bottomReserved: bottomReserved + PraniSpacing.section,
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: _topScrimColors(scheme),
                    stops: const [0.0, 0.22, 0.42],
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: _bottomScrimColors(),
                    stops: const [0.52, 0.78, 1.0],
                  ),
                ),
              ),
            ),
            MediaQuery(
              data: mq.copyWith(textScaler: textScaler),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    pad.left,
                    PraniSpacing.sm,
                    pad.right,
                    bottomReserved + PraniSpacing.md,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Spacer(flex: 4),
                      Flexible(
                        flex: 6,
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: (mq.size.width - pad.left - pad.right)
                                  .clamp(0.0, 440.0),
                            ),
                            child: SingleChildScrollView(
                              physics: const ClampingScrollPhysics(),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    title,
                                    textAlign: TextAlign.center,
                                    style:
                                        PraniTextStyles.pageTitleProminent(
                                          scheme,
                                          textTheme,
                                        ).copyWith(
                                          color: PraniColors.white,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: -0.35,
                                          height: 1.22,
                                          shadows: const [
                                            Shadow(
                                              color: Color(0x66000000),
                                              blurRadius: 12,
                                              offset: Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                  ),
                                  SizedBox(height: PraniSpacing.md),
                                  Text(
                                    description,
                                    textAlign: TextAlign.center,
                                    style:
                                        PraniTextStyles.body(
                                          scheme,
                                          textTheme,
                                        ).copyWith(
                                          color: PraniColors.white.withValues(
                                            alpha: 0.92,
                                          ),
                                          height: 1.48,
                                          shadows: const [
                                            Shadow(
                                              color: Color(0x59000000),
                                              blurRadius: 10,
                                              offset: Offset(0, 1),
                                            ),
                                          ],
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

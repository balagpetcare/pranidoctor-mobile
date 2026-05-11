import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../../core/assets/prani_assets.dart';

/// Responsive full-screen hero image:
/// - Background: blurred cover image, so screen never looks empty
/// - Foreground: contain image, so the full artwork is always visible
/// - Works across different phone screen sizes
class PraniLayeredHeroImageBackground extends StatefulWidget {
  const PraniLayeredHeroImageBackground({
    super.key,
    required this.assetPath,
    this.semanticLabel,
    this.foregroundAlignment = Alignment.center,
    this.backgroundBlurSigma = 16,
    this.bottomReserved = 0,
    this.topReserved = 0,
    this.horizontalPadding = 0,
    this.backgroundDarken = 0.12,
    this.decodeMaxPx = PraniAssetDecode.onboardingBdHeroMaxPx,
    this.excludeBackgroundSemantics = false,
    this.onAssetFailed,
  });

  final String assetPath;
  final String? semanticLabel;
  final Alignment foregroundAlignment;
  final double backgroundBlurSigma;
  final double bottomReserved;
  final double topReserved;
  final double horizontalPadding;
  final double backgroundDarken;
  final int decodeMaxPx;
  final bool excludeBackgroundSemantics;
  final VoidCallback? onAssetFailed;

  @override
  State<PraniLayeredHeroImageBackground> createState() =>
      _PraniLayeredHeroImageBackgroundState();
}

class _PraniLayeredHeroImageBackgroundState
    extends State<PraniLayeredHeroImageBackground> {
  bool _imageFailed = false;
  bool _failureNotified = false;

  @override
  void didUpdateWidget(PraniLayeredHeroImageBackground oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.assetPath != widget.assetPath) {
      _imageFailed = false;
      _failureNotified = false;
    }
  }

  void _onAssetError() {
    if (!_failureNotified) {
      _failureNotified = true;
      widget.onAssetFailed?.call();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() => _imageFailed = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    if (_imageFailed) {
      return ColoredBox(
        color: scheme.surfaceContainerHighest,
        child: Center(
          child: Icon(
            Icons.pets,
            size: 64,
            color: scheme.primary,
            semanticLabel: widget.semanticLabel,
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;

        final bgDecodeW = PraniAssetDecode.cacheExtentPx(
          context,
          width,
          widget.decodeMaxPx,
        );

        final bgDecodeH = PraniAssetDecode.cacheExtentPx(
          context,
          height,
          widget.decodeMaxPx,
        );

        final safeForegroundWidth = (width - widget.horizontalPadding * 2)
            .clamp(0.0, width);

        final safeForegroundHeight =
            (height - widget.topReserved - widget.bottomReserved).clamp(
              0.0,
              height,
            );

        final fgDecodeW = PraniAssetDecode.cacheExtentPx(
          context,
          safeForegroundWidth,
          widget.decodeMaxPx,
        );

        final fgDecodeH = PraniAssetDecode.cacheExtentPx(
          context,
          safeForegroundHeight,
          widget.decodeMaxPx,
        );

        Widget errorIcon() {
          return Center(
            child: Icon(
              Icons.broken_image_outlined,
              size: 64,
              color: scheme.primary,
              semanticLabel: widget.semanticLabel,
            ),
          );
        }

        return Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: ClipRect(
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(
                    sigmaX: widget.backgroundBlurSigma,
                    sigmaY: widget.backgroundBlurSigma,
                  ),
                  child: Transform.scale(
                    scale: 1.08,
                    child: Image.asset(
                      widget.assetPath,
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                      gaplessPlayback: true,
                      excludeFromSemantics: true,
                      cacheWidth: bgDecodeW,
                      cacheHeight: bgDecodeH,
                      errorBuilder: (context, error, stackTrace) {
                        _onAssetError();
                        return errorIcon();
                      },
                    ),
                  ),
                ),
              ),
            ),

            Positioned.fill(
              child: ColoredBox(
                color: Colors.black.withValues(
                  alpha: widget.backgroundDarken.clamp(0.0, 0.6),
                ),
              ),
            ),

            Positioned.fill(
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    widget.horizontalPadding,
                    widget.topReserved,
                    widget.horizontalPadding,
                    widget.bottomReserved,
                  ),
                  child: Center(
                    child: Image.asset(
                      widget.assetPath,
                      fit: BoxFit.contain,
                      alignment: widget.foregroundAlignment,
                      width: safeForegroundWidth,
                      height: safeForegroundHeight,
                      gaplessPlayback: true,
                      semanticLabel: widget.semanticLabel,
                      cacheWidth: fgDecodeW,
                      cacheHeight: fgDecodeH,
                      errorBuilder: (context, error, stackTrace) {
                        _onAssetError();
                        return errorIcon();
                      },
                    ),
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

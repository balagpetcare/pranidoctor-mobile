import 'package:flutter/material.dart';

import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/presentation/template_learning/template_authenticated_image.dart';

/// Fullscreen zoom preview for template images.
abstract final class TemplateFullscreenMedia {
  static Future<void> showImage(
    BuildContext context, {
    required String uploadId,
  }) {
    return Navigator.of(context).push<void>(
      PageRouteBuilder<void>(
        opaque: false,
        barrierDismissible: true,
        barrierColor: Colors.black.withValues(alpha: 0.88),
        transitionDuration: PraniDurations.medium,
        reverseTransitionDuration: PraniDurations.short,
        pageBuilder: (ctx, anim, secAnim) {
          return FadeTransition(
            opacity: anim,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.94, end: 1).animate(
                CurvedAnimation(parent: anim, curve: Curves.easeOutCubic),
              ),
              child: GestureDetector(
                onTap: () => Navigator.of(ctx).pop(),
                child: Scaffold(
                  backgroundColor: Colors.transparent,
                  body: SafeArea(
                    child: Center(
                      child: InteractiveViewer(
                        minScale: 0.8,
                        maxScale: 4,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(PraniRadius.lg),
                          child: TemplateAuthenticatedImage(
                            uploadId: uploadId,
                            fit: BoxFit.contain,
                            borderRadius: BorderRadius.circular(PraniRadius.lg),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

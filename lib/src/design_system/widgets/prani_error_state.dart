import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/config/app_config.dart';
import '../prani_tokens.dart';
import 'prani_buttons.dart';

/// Centralized error UI — user-facing copy by default; optional technical detail in development.
class PraniErrorState extends StatelessWidget {
  const PraniErrorState({
    super.key,
    required this.title,
    required this.message,
    this.retryLabel,
    this.onRetry,
    this.compact = false,
    this.detail,
    this.icon = Icons.cloud_off_rounded,
    this.boxed = false,
  });

  final String title;
  final String message;
  final String? retryLabel;
  final VoidCallback? onRetry;
  final bool compact;

  /// Raw message — shown only in debug / development env when non-null non-empty.
  final String? detail;
  final IconData icon;

  /// When true, draws a tinted surface suitable for inline async strips.
  final bool boxed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final showTech =
        detail != null &&
        detail!.trim().isNotEmpty &&
        (kDebugMode || AppConfig.isDevelopmentEnv);

    final gap = compact ? PraniSpacing.sm : PraniSpacing.md;

    final inner = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: scheme.error, size: compact ? 36 : 42),
        SizedBox(height: gap),
        Text(
          title,
          textAlign: TextAlign.center,
          style: PraniTextStyles.heading(
            scheme,
            textTheme,
          ).copyWith(color: scheme.onSurface),
        ),
        const SizedBox(height: PraniSpacing.xs),
        Text(
          message,
          textAlign: TextAlign.center,
          style: PraniTextStyles.bodyMuted(scheme, textTheme).copyWith(
            color: scheme.onSurface.withValues(alpha: 0.92),
            height: 1.42,
          ),
        ),
        if (showTech) ...[
          const SizedBox(height: PraniSpacing.sm),
          Text(
            detail!.trim(),
            textAlign: TextAlign.center,
            style: PraniTextStyles.caption(
              scheme,
              textTheme,
            ).copyWith(color: scheme.onSurfaceVariant, fontFamily: 'monospace'),
          ),
        ],
        if (retryLabel != null && onRetry != null) ...[
          SizedBox(height: compact ? PraniSpacing.md : PraniSpacing.lg),
          PraniPrimaryButton(
            label: retryLabel!,
            onPressed: onRetry,
            fullWidth: false,
            icon: Icons.refresh_rounded,
          ),
        ],
      ],
    );

    if (!boxed) return inner;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.errorContainer.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(PraniRadius.lg),
        border: Border.all(color: scheme.error.withValues(alpha: 0.28)),
        boxShadow: PraniShadows.elevatedCardShadow(scheme.brightness),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          PraniSpacing.xl,
          PraniSpacing.lg,
          PraniSpacing.xl,
          PraniSpacing.xl,
        ),
        child: inner,
      ),
    );
  }
}

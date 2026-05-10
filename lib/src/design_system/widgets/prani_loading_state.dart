import 'package:flutter/material.dart';

import '../prani_tokens.dart';

/// Lightweight loading indicator — optional caption for Bengali status text.
class PraniLoadingState extends StatelessWidget {
  const PraniLoadingState({
    super.key,
    this.message,
    this.compact = false,
    this.height,
    this.strokeWidth = 3,
  });

  final String? message;
  final bool compact;

  /// When non-null, wraps a fixed-height strip (list placeholders).
  final double? height;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final indicator = SizedBox(
      width: compact ? 24 : 28,
      height: compact ? 24 : 28,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        color: scheme.primary,
      ),
    );

    final column = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        indicator,
        if (message != null && message!.trim().isNotEmpty) ...[
          const SizedBox(height: PraniSpacing.md),
          Text(
            message!,
            textAlign: TextAlign.center,
            style: PraniTextStyles.bodyMuted(
              scheme,
              textTheme,
            ).copyWith(fontWeight: FontWeight.w500),
          ),
        ],
      ],
    );

    if (height != null) {
      return SizedBox(
        height: height,
        child: Center(child: column),
      );
    }

    return column;
  }
}

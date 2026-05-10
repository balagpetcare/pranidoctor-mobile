import 'package:flutter/material.dart';

import '../prani_color_scheme_ext.dart';
import '../prani_tokens.dart';

/// Theme-aware elevated surface (no hardcoded white).
class PraniPremiumCard extends StatelessWidget {
  const PraniPremiumCard({
    super.key,
    required this.child,
    this.padding,
    this.radius,
    this.onTap,
    this.margin,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? radius;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final r = radius ?? PraniRadii.lg;

    final padded = Padding(padding: padding ?? EdgeInsets.zero, child: child);

    final Widget body;
    if (onTap != null) {
      body = Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(r),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          borderRadius: BorderRadius.circular(r),
          onTap: onTap,
          child: padded,
        ),
      );
    } else {
      body = padded;
    }

    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: scheme.praniElevatedCard,
          borderRadius: BorderRadius.circular(r),
          border: Border.all(
            color: scheme.outlineVariant.withValues(alpha: 0.38),
          ),
          boxShadow: PraniShadows.elevatedCardShadow(scheme.brightness),
        ),
        child: body,
      ),
    );
  }
}

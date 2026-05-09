import 'package:flutter/material.dart';

import '../constants/pd_radii.dart';
import '../constants/pd_shadows.dart';
import '../constants/pd_spacing.dart';

/// Opinionated card: optional soft shadow, default inner padding, tap ripple.
class PdAppCard extends StatelessWidget {
  const PdAppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(PdSpacing.md),
    this.onTap,
    this.margin,
    this.useShadow = false,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;
  final bool useShadow;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final cardColor =
        Theme.of(context).cardTheme.color ?? scheme.surfaceContainerLowest;
    final radius = BorderRadius.circular(PdRadii.card);

    Widget inner = Padding(padding: padding, child: child);

    if (onTap != null) {
      inner = Material(
        color: Colors.transparent,
        child: InkWell(onTap: onTap, borderRadius: radius, child: inner),
      );
    }

    if (useShadow) {
      return Padding(
        padding: margin ?? EdgeInsets.zero,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: radius,
            boxShadow: PdShadows.softCard(scheme),
          ),
          child: ClipRRect(borderRadius: radius, child: inner),
        ),
      );
    }

    return Card(
      margin: margin ?? EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: radius),
      child: inner,
    );
  }
}

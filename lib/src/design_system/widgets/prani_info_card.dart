import 'package:flutter/material.dart';

import '../prani_color_scheme_ext.dart';
import '../prani_tokens.dart';

/// General-purpose info / settings row card.
class PraniInfoCard extends StatelessWidget {
  const PraniInfoCard({
    super.key,
    required this.title,
    this.subtitle,
    this.leadingIcon,
    this.trailing,
    this.onTap,
    this.child,
    this.padding,
  });

  final String title;
  final String? subtitle;
  final Widget? leadingIcon;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Widget? child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final inner = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (leadingIcon != null) ...[
              IconTheme(
                data: IconThemeData(color: scheme.primary, size: 26),
                child: leadingIcon!,
              ),
              const SizedBox(width: PraniSpacing.md),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: PraniTextStyles.heading(scheme, textTheme),
                  ),
                  if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
                    const SizedBox(height: PraniSpacing.xxs),
                    Text(
                      subtitle!,
                      style: PraniTextStyles.bodyMuted(scheme, textTheme),
                    ),
                  ],
                ],
              ),
            ),
            ?trailing,
          ],
        ),
        if (child != null) ...[const SizedBox(height: PraniSpacing.md), child!],
      ],
    );

    final decorated = DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.praniElevatedCard,
        borderRadius: BorderRadius.circular(PraniRadius.lg),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.38),
        ),
        boxShadow: PraniShadows.elevatedCardShadow(scheme.brightness),
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(PraniSpacing.xl),
        child: inner,
      ),
    );

    if (onTap == null) return decorated;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(PraniRadius.lg),
        onTap: onTap,
        child: decorated,
      ),
    );
  }
}

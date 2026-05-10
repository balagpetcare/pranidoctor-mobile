import 'package:flutter/material.dart';

import '../prani_color_scheme_ext.dart';
import '../prani_tokens.dart';

/// Non-editable search affordance (parent handles taps) — used on Home and reusable elsewhere.
class PraniAppSearchBar extends StatelessWidget {
  const PraniAppSearchBar({
    super.key,
    required this.hintText,
    required this.onSearchTap,
    this.onFilterTap,
    this.filterTooltip = 'ফিল্টার',
    this.searchTooltip = 'খুঁজুন',
    this.height = 68,
    this.borderRadius,
  });

  final String hintText;
  final VoidCallback onSearchTap;
  final VoidCallback? onFilterTap;
  final String filterTooltip;
  final String searchTooltip;
  final double height;
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final r = borderRadius ?? PraniRadii.homeServiceTile;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.praniElevatedCard,
        borderRadius: BorderRadius.circular(r),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.38),
        ),
        boxShadow: PraniShadows.elevatedCardShadow(scheme.brightness),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(r),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onSearchTap,
          child: SizedBox(
            height: height,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: PraniSpacing.sm,
                vertical: PraniSpacing.xxs,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    tooltip: searchTooltip,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 44,
                      minHeight: 44,
                    ),
                    onPressed: onSearchTap,
                    icon: Icon(
                      Icons.search_rounded,
                      color: scheme.primary,
                      size: 24,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      hintText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyLarge?.copyWith(
                        color: scheme.onSurfaceVariant,
                        height: 1.25,
                      ),
                    ),
                  ),
                  if (onFilterTap != null)
                    IconButton(
                      tooltip: filterTooltip,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 44,
                        minHeight: 44,
                      ),
                      onPressed: onFilterTap,
                      icon: Icon(
                        Icons.tune_rounded,
                        color: scheme.onSurfaceVariant,
                        size: 22,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../prani_color_scheme_ext.dart';
import '../prani_tokens.dart';

/// Home service grid tile — fixed minimum height; surfaces follow [ColorScheme].
class PraniServiceCard extends StatelessWidget {
  const PraniServiceCard({
    super.key,
    required this.label,
    required this.icon,
    required this.pastel,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color pastel;
  final VoidCallback onTap;

  static const double minTileHeight = 136;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final radius = PraniRadii.homeServiceTile;
    final fill = scheme.praniElevatedCard;
    final border = scheme.outlineVariant.withValues(alpha: 0.38);

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: minTileHeight),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: border),
          boxShadow: PraniShadows.elevatedCardShadow(scheme.brightness),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(radius),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(PraniSpacing.md + 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: pastel,
                      borderRadius: BorderRadius.circular(PraniRadii.md),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(PraniSpacing.sm),
                      child: Icon(icon, color: scheme.primary, size: 26),
                    ),
                  ),
                  const SizedBox(height: PraniSpacing.md),
                  Expanded(
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        label,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        softWrap: true,
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          height: 1.38,
                          color: scheme.praniOnElevatedCard,
                        ),
                      ),
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

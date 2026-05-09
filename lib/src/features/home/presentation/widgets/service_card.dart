import 'package:flutter/material.dart';

import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';
import 'package:pranidoctor_mobile/src/features/home/presentation/home_layout_constants.dart';

/// Single service tile for the home grid — fixed minimum height for alignment.
class ServiceCard extends StatelessWidget {
  const ServiceCard({
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

  static const double minTileHeight = 132;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final radius = HomeLayout.serviceCardRadius;
    final border = scheme.outlineVariant.withValues(alpha: 0.32);

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: minTileHeight),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: PraniColors.white,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: border),
          boxShadow: PraniShadows.homeCardSoft,
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
                          color: scheme.onSurface,
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

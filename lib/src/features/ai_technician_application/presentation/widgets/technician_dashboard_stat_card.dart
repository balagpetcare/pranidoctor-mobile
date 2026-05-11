import 'package:flutter/material.dart';

import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_premium_card.dart';

/// One KPI tile for the AI technician dashboard grid.
class TechnicianDashboardStatItem {
  const TechnicianDashboardStatItem({
    required this.title,
    required this.value,
    required this.icon,
    required this.helper,
  });

  final String title;
  final String value;
  final IconData icon;
  final String helper;
}

class TechnicianDashboardStatCard extends StatelessWidget {
  const TechnicianDashboardStatCard({super.key, required this.item});

  final TechnicianDashboardStatItem item;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return PraniPremiumCard(
      padding: const EdgeInsets.all(PraniSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(item.icon, size: 22, color: scheme.primary),
              const Spacer(),
            ],
          ),
          const SizedBox(height: PraniSpacing.sm),
          Text(
            item.title,
            style: textTheme.labelMedium?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: PraniSpacing.xxs),
          Text(
            item.value,
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: PraniSpacing.xxs),
          Text(
            item.helper,
            style: textTheme.labelSmall?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.25,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// Responsive 2-column wrap of [TechnicianDashboardStatCard]s.
class TechnicianDashboardKpiGrid extends StatelessWidget {
  const TechnicianDashboardKpiGrid({super.key, required this.items});

  final List<TechnicianDashboardStatItem> items;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final gap = PraniSpacing.md;
        final w = (c.maxWidth - gap) / 2;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: items
              .map(
                (s) => SizedBox(
                  width: w,
                  child: TechnicianDashboardStatCard(item: s),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';

import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_premium_card.dart';

/// Placeholder earnings breakdown until API exposes period splits.
class TechnicianEarningsSummaryCard extends StatelessWidget {
  const TechnicianEarningsSummaryCard({
    super.key,
    this.summaryNote =
        'বিস্তারিত ভাগ এখনও পাওয়া যায়নি — মোট আয় উপরের সারাংশে দেখানো হয়েছে।',
    this.todayLabel = 'আজকের আয়',
    this.weekLabel = 'এই সপ্তাহ',
    this.monthLabel = 'এই মাস',
    this.pendingLabel = 'পেমেন্ট অপেক্ষমাণ',
    this.placeholderAmount = '৳০',

    /// Confirmed aggregate from dashboard payload (real server total).
    this.dashboardConfirmedTotalLabel = 'সার্বমোট আয় (ড্যাশবোর্ড)',
    this.dashboardConfirmedTotalBdt,
  });

  final String summaryNote;
  final String todayLabel;
  final String weekLabel;
  final String monthLabel;
  final String pendingLabel;
  final String placeholderAmount;
  final String dashboardConfirmedTotalLabel;

  /// Raw BDT string from API (e.g. `"12500.50"`); shown with ৳ prefix when set.
  final String? dashboardConfirmedTotalBdt;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final cells = [
      (todayLabel, placeholderAmount),
      (weekLabel, placeholderAmount),
      (monthLabel, placeholderAmount),
      (pendingLabel, placeholderAmount),
    ];

    return PraniPremiumCard(
      padding: const EdgeInsets.all(PraniSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (dashboardConfirmedTotalBdt != null &&
              dashboardConfirmedTotalBdt!.trim().isNotEmpty) ...[
            Text(
              dashboardConfirmedTotalLabel,
              style: textTheme.labelMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: PraniSpacing.xs),
            Text(
              '৳${dashboardConfirmedTotalBdt!.trim()}',
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: PraniSpacing.md),
          ],
          Text(
            summaryNote,
            style: PraniTextStyles.bodyMuted(
              scheme,
              textTheme,
            ).copyWith(height: 1.42),
          ),
          const SizedBox(height: PraniSpacing.md),
          LayoutBuilder(
            builder: (context, c) {
              final gap = PraniSpacing.md;
              final w = (c.maxWidth - gap) / 2;
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: cells
                    .map(
                      (e) => SizedBox(
                        width: w,
                        child: PraniPremiumCard(
                          padding: const EdgeInsets.all(PraniSpacing.md),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                e.$1,
                                style: textTheme.labelMedium?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: PraniSpacing.xs),
                              Text(
                                e.$2,
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

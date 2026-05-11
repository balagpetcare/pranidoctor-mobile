import 'package:flutter/material.dart';

import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_empty_state.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_premium_card.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/data/ai_technician_models.dart';

/// Recent reviews + headline metrics (values supplied by parent).
class TechnicianWeeklyPerformanceCard extends StatelessWidget {
  const TechnicianWeeklyPerformanceCard({
    super.key,
    required this.ratingAverage,
    required this.ratingCount,
    required this.completedServicesCount,
    required this.recentReviews,
    this.blockTitle = 'সাপ্তাহিক রিভিউ সারাংশ',
    this.introCopy =
        'গত কয়েকটি রিভিউ থেকে গড় এবং সম্পন্ন কাজের সংখ্যা নিচে দেখানো হয়েছে। পূর্ণাঙ্গ সাপ্তাহিক রিপোর্ট শীঘ্রই যুক্ত হবে।',
    this.emptyReviewsTitle = 'এখনও রিভিউ নেই',
    this.emptyReviewsMessage =
        'সেবা সম্পন্ন হলে খামারির রিভিউ এখানে দেখা যাবে।',
    this.completionRateValue,
    this.completionRateHint,
    this.responseQualityValue = 'শীঘ্রই',
    this.responseQualityHint = 'স্বয়ংক্রিয় মূল্যায়ন শীঘ্রই।',
  });

  /// Effective average (server or derived from [recentReviews] in parent).
  final double? ratingAverage;
  final int ratingCount;
  final int completedServicesCount;
  final List<AiTechnicianReviewSnippet> recentReviews;
  final String blockTitle;
  final String introCopy;
  final String emptyReviewsTitle;
  final String emptyReviewsMessage;
  final String? completionRateValue;
  final String? completionRateHint;
  final String responseQualityValue;
  final String? responseQualityHint;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return PraniPremiumCard(
      padding: const EdgeInsets.all(PraniSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            blockTitle,
            style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: PraniSpacing.sm),
          Text(
            introCopy,
            style: PraniTextStyles.bodyMuted(
              scheme,
              textTheme,
            ).copyWith(height: 1.42),
          ),
          const SizedBox(height: PraniSpacing.md),
          TechnicianPerformanceMetricRow(
            label: 'গড় রেটিং',
            value: ratingAverage != null
                ? ratingAverage!.toStringAsFixed(1)
                : '—',
          ),
          TechnicianPerformanceMetricRow(
            label: 'রিভিউ সংখ্যা',
            value: '$ratingCount',
          ),
          TechnicianPerformanceMetricRow(
            label: 'সম্পন্ন সেবা (সামগ্রিক)',
            value: '$completedServicesCount',
          ),
          TechnicianPerformanceMetricRow(
            label: 'সমাপ্তির হার',
            value: completionRateValue ?? '—',
            hint:
                completionRateHint ??
                'হার হিসেব করতে প্রয়োজনীয় তথ্য এখনও পর্যাপ্ত নয়।',
          ),
          TechnicianPerformanceMetricRow(
            label: 'প্রতিক্রিয়ার গুণমান',
            value: responseQualityValue,
            hint: responseQualityHint,
          ),
          const SizedBox(height: PraniSpacing.md),
          if (recentReviews.isEmpty)
            PraniEmptyState(
              title: emptyReviewsTitle,
              message: emptyReviewsMessage,
              icon: Icons.rate_review_outlined,
              boxed: false,
            )
          else
            ...recentReviews.map((rv) {
              final dt = rv.createdAt.length > 10
                  ? rv.createdAt.substring(0, 10)
                  : rv.createdAt;
              return Padding(
                padding: const EdgeInsets.only(bottom: PraniSpacing.sm),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${'★' * rv.rating}${'☆' * (5 - rv.rating)}',
                      style: textTheme.labelLarge?.copyWith(
                        color: scheme.tertiary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: PraniSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(dt, style: textTheme.labelSmall),
                          if (rv.comment != null &&
                              rv.comment!.trim().isNotEmpty)
                            Text(
                              rv.comment!.trim(),
                              style: textTheme.bodySmall?.copyWith(
                                height: 1.35,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}

class TechnicianPerformanceMetricRow extends StatelessWidget {
  const TechnicianPerformanceMetricRow({
    super.key,
    required this.label,
    required this.value,
    this.hint,
  });

  final String label;
  final String value;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: PraniSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: Text(label, style: textTheme.bodyMedium)),
              Text(
                value,
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          if (hint != null && hint!.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: PraniSpacing.xxs),
              child: Text(
                hint!,
                style: textTheme.labelSmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

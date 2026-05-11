import 'package:flutter/material.dart';

import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_premium_card.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_section_header.dart';
import 'package:pranidoctor_mobile/src/features/profile/data/dashboard_context_models.dart';

/// Lightweight analytics strip — expands when [completedAppointmentsThisWeek] is present.
class DoctorPerformanceAnalyticsSection extends StatelessWidget {
  const DoctorPerformanceAnalyticsSection({super.key, required this.doctor});

  final DashboardContextDoctor? doctor;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final week = doctor?.completedAppointmentsThisWeek;
    final avg = doctor?.rating.average;
    final ratingLabel = avg != null ? avg.toStringAsFixed(1) : '—';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const PraniSectionHeader(
          title: 'পারফরম্যান্স',
          subtitle: 'সাপ্তাহিক সূচক',
          leadingIcon: Icons.insights_outlined,
        ),
        const SizedBox(height: PraniSpacing.md),
        Row(
          children: [
            Expanded(
              child: PraniPremiumCard(
                padding: const EdgeInsets.all(PraniSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      week == null ? '—' : '$week',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'সম্পন্ন অ্যাপয়েন্ট (সপ্তাহ)',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: PraniSpacing.sm),
            Expanded(
              child: PraniPremiumCard(
                padding: const EdgeInsets.all(PraniSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ratingLabel,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'গড় রেটিং',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: PraniSpacing.sm),
        Text(
          'বিস্তৃত চার্ট ও কোহর্ট বিশ্লেষণ API যুক্ত হলে এখানে যোগ করা হবে।',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
                height: 1.4,
              ),
        ),
      ],
    );
  }
}

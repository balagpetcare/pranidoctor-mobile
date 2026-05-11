import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';
import 'package:pranidoctor_mobile/src/features/enterprise_insights/domain/enterprise_audit_activity.dart';
import 'package:pranidoctor_mobile/src/features/enterprise_insights/domain/professional_analytics_snapshot.dart';
import 'package:pranidoctor_mobile/src/features/enterprise_insights/domain/sync_outbox_snapshot.dart';
import 'package:pranidoctor_mobile/src/features/enterprise_insights/presentation/widgets/enterprise_sync_monitor.dart';

class EnterpriseOfflineSyncBanner extends StatelessWidget {
  const EnterpriseOfflineSyncBanner({
    super.key,
    required this.asyncSnapshot,
  });

  final AsyncValue<SyncOutboxSnapshot> asyncSnapshot;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      color: scheme.surfaceContainerHighest.withValues(alpha: 0.65),
      child: Padding(
        padding: const EdgeInsets.all(PraniSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.offline_bolt_outlined, color: scheme.primary),
                const SizedBox(width: PraniSpacing.sm),
                Text(
                  'অফলাইন-প্রথম ও সিঙ্ক ইঞ্জিন',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
            const SizedBox(height: PraniSpacing.xs),
            Text(
              'আউটবক্স SharedPreferences-এ সংরক্ষিত। কানেক্টিভিটি ফিরলে স্বয়ংক্রিয় রিট্রাই '
              '(এক্সপোনেনশিয়াল ব্যাকঅফ)। ব্যাকগ্রাউন্ড টাস্ক পরবর্তীতে [SyncBackgroundFlushPort] দিয়ে যুক্ত করুন।',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    height: 1.45,
                  ),
            ),
            const SizedBox(height: PraniSpacing.md),
            asyncSnapshot.when(
              loading: () => const LinearProgressIndicator(minHeight: 2),
              error: (e, _) => Text(
                'সিঙ্ক স্ট্যাটাস লোড ব্যর্থ: $e',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.error,
                    ),
              ),
              data: (snap) => EnterpriseSyncMonitor(snapshot: snap),
            ),
          ],
        ),
      ),
    );
  }
}

class EnterpriseAnalyticsMetricDeck extends StatelessWidget {
  const EnterpriseAnalyticsMetricDeck({super.key, required this.snapshot});

  final ProfessionalAnalyticsSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final items = <(String, String, IconData)>[
      (
        'মাসিক পারফরম্যান্স',
        snapshot.monthlyPerformanceBn,
        Icons.calendar_month_outlined,
      ),
      (
        'সেবা সাফল্যের হার',
        snapshot.serviceSuccessRateBn,
        Icons.verified_outlined,
      ),
      (
        'এলাকা পারফরম্যান্স',
        snapshot.areaPerformanceBn,
        Icons.map_outlined,
      ),
      (
        'রাজস্ব বিশ্লেষণ',
        snapshot.revenueAnalyticsBn,
        Icons.payments_outlined,
      ),
      (
        'বৃদ্ধি সূচক',
        snapshot.growthMetricsBn,
        Icons.trending_up_rounded,
      ),
    ];
    final w = (MediaQuery.sizeOf(context).width -
            PraniSpacing.lg * 2 -
            PraniSpacing.sm) /
        2;
    return Wrap(
      spacing: PraniSpacing.sm,
      runSpacing: PraniSpacing.sm,
      children: items
          .map(
            (t) => SizedBox(
              width: w,
              child: _MetricTile(
                title: t.$1,
                body: t.$2,
                icon: t.$3,
              ),
            ),
          )
          .toList(),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.title,
    required this.body,
    required this.icon,
  });

  final String title;
  final String body;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      color: scheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(PraniSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 22, color: scheme.primary),
            const SizedBox(height: PraniSpacing.xs),
            Text(
              title,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: PraniSpacing.xs),
            Text(
              body,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    height: 1.4,
                    color: scheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Placeholder layout for fl_chart / syncfusion later — fixed aspect slots.
class EnterpriseMultiChartPlaceholder extends StatelessWidget {
  const EnterpriseMultiChartPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    Widget slot(String label, IconData icon) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: scheme.outlineVariant),
            color: scheme.surfaceContainerHighest.withValues(alpha: 0.4),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 36, color: scheme.primary.withValues(alpha: 0.55)),
                const SizedBox(height: PraniSpacing.sm),
                Text(
                  label,
                  style: Theme.of(context).textTheme.titleSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: PraniSpacing.xs),
                Text(
                  'চার্ট লাইব্রেরি সংযোগের জন্য প্রস্তুত স্লট',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'চার্ট-প্রস্তুত স্থাপত্য',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: PraniSpacing.md),
        slot('মাসিক ট্রেন্ড', Icons.show_chart_rounded),
        const SizedBox(height: PraniSpacing.sm),
        slot('এলাকা তুলনা', Icons.bar_chart_rounded),
        const SizedBox(height: PraniSpacing.sm),
        slot('রাজস্ব / বৃদ্ধি', Icons.pie_chart_outline_rounded),
      ],
    );
  }
}

class EnterpriseAuditTimeline extends StatelessWidget {
  const EnterpriseAuditTimeline({super.key, required this.entries});

  final List<EnterpriseAuditEntry> entries;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return Text(
        'এখনও কোনো অডিট এন্ট্রি নেই।',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      );
    }
    final rev = entries.reversed.toList(growable: false);
    return Column(
      children: rev.take(12).map((e) {
        final local = e.atUtc.toLocal();
        final t =
            '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')} '
            '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
        return ListTile(
          contentPadding: EdgeInsets.zero,
          dense: true,
          leading: const Icon(Icons.gavel_outlined, size: 22),
          title: Text(e.summaryBn),
          subtitle: Text('$t · ${e.actionKey}'),
        );
      }).toList(),
    );
  }
}

class EnterpriseActivityList extends StatelessWidget {
  const EnterpriseActivityList({super.key, required this.entries});

  final List<EnterpriseActivityEntry> entries;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return Text(
        'কার্যকলমের ইতিহাস খালি।',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      );
    }
    final rev = entries.reversed.toList(growable: false);
    return Column(
      children: rev.take(15).map((e) {
        final local = e.atUtc.toLocal();
        final t =
            '${local.month}/${local.day} '
            '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
        return ListTile(
          contentPadding: EdgeInsets.zero,
          dense: true,
          leading: const Icon(Icons.history_rounded, size: 22),
          title: Text(e.titleBn),
          subtitle: Text(
            [t, if (e.detailBn != null && e.detailBn!.isNotEmpty) e.detailBn!]
                .join(' · '),
          ),
        );
      }).toList(),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_loading_state.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_premium_card.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_section_header.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/application/ai_technician_providers.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/data/ai_technician_models.dart';

class TechnicianDashboardKpiDeck extends StatelessWidget {
  const TechnicianDashboardKpiDeck({
    super.key,
    required this.data,
    required this.ratingLabel,
  });

  final AiTechnicianDashboardData data;
  final String ratingLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, c) {
        final narrow = c.maxWidth < 380;
        final tiles = <Widget>[
          _KpiTile(
            title: 'আজকের অনুরোধ',
            value: '${data.todayRequestsCount}',
            icon: Icons.today_outlined,
            scheme: scheme,
            narrow: narrow,
          ),
          _KpiTile(
            title: 'অপেক্ষমাণ',
            value: '${data.pendingRequestsCount}',
            icon: Icons.pending_actions_outlined,
            scheme: scheme,
            narrow: narrow,
          ),
          _KpiTile(
            title: 'সম্পন্ন সেবা',
            value: '${data.completedServicesCount}',
            icon: Icons.task_alt_rounded,
            scheme: scheme,
            narrow: narrow,
          ),
          _KpiTile(
            title: 'মোট আয়',
            value: '৳${data.totalEarningsBdt}',
            icon: Icons.savings_outlined,
            scheme: scheme,
            narrow: narrow,
          ),
          _KpiTile(
            title: 'রেটিং',
            value: ratingLabel,
            icon: Icons.star_rate_rounded,
            scheme: scheme,
            narrow: narrow,
          ),
        ];
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              for (var i = 0; i < tiles.length; i++) ...[
                if (i > 0) const SizedBox(width: PraniSpacing.sm),
                tiles[i],
              ],
            ],
          ),
        );
      },
    );
  }
}

class _KpiTile extends StatelessWidget {
  const _KpiTile({
    required this.title,
    required this.value,
    required this.icon,
    required this.scheme,
    required this.narrow,
  });

  final String title;
  final String value;
  final IconData icon;
  final ColorScheme scheme;
  final bool narrow;

  @override
  Widget build(BuildContext context) {
    final w = narrow ? 148.0 : 158.0;
    return SizedBox(
      width: w,
      child: PraniPremiumCard(
        padding: const EdgeInsets.all(PraniSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: scheme.primary, size: 22),
            const SizedBox(height: PraniSpacing.sm),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class TechnicianServiceRequestOverview extends ConsumerWidget {
  const TechnicianServiceRequestOverview({super.key, required this.onOpenAll});

  final VoidCallback onOpenAll;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final async = ref.watch(aiTechnicianRequestPipelineCountsProvider);

    return PraniPremiumCard(
      padding: const EdgeInsets.all(PraniSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'সেবা অনুরোধের ওভারভিউ',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
              TextButton(onPressed: onOpenAll, child: const Text('সব দেখুন')),
            ],
          ),
          const SizedBox(height: PraniSpacing.sm),
          async.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: PraniSpacing.lg),
              child: PraniLoadingState(
                message: 'অনুরোধের সংখ্যা লোড হচ্ছে…',
                compact: true,
              ),
            ),
            error: (err, _) => Padding(
              padding: const EdgeInsets.symmetric(vertical: PraniSpacing.md),
              child: Text(
                'পাইপলাইন সংখ্যা লোড করা যায়নি। তালিকা স্ক্রিনে বিস্তারিত দেখুন।',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.error,
                    ),
              ),
            ),
            data: (m) {
              if (m.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: PraniSpacing.md),
                  child: Text(
                    'এখনও কোনো অনুরোধের তথ্য নেই।',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                  ),
                );
              }
              Widget row(String label, IconData icon, String tab) {
                final v = m[tab]?.displayText ?? '—';
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Icon(icon, size: 20, color: scheme.primary),
                      const SizedBox(width: PraniSpacing.sm),
                      Expanded(child: Text(label)),
                      Text(
                        v,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ],
                  ),
                );
              }

              return Column(
                children: [
                  row('নতুন', Icons.fiber_new_rounded, 'new'),
                  row('গৃহীত', Icons.check_circle_outline_rounded, 'accepted'),
                  row('চলমান', Icons.sync_rounded, 'ongoing'),
                  row('সম্পন্ন', Icons.done_all_rounded, 'completed'),
                  row('বাতিল', Icons.cancel_outlined, 'cancelled'),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class TechnicianMonthlyAndInsightsStrip extends StatelessWidget {
  const TechnicianMonthlyAndInsightsStrip({super.key, required this.data});

  final AiTechnicianDashboardData data;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    String fmtInt(int? v) => v == null ? '—' : '$v';
    String fmtMoney(String? v) =>
        v == null || v.trim().isEmpty ? '—' : '৳${v.trim()}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const PraniSectionHeader(
          title: 'মাসিক পরিসংখ্যান',
          subtitle: 'সার্ভার ফিল্ড উপলব্ধ হলে স্বয়ংক্রিয়ভাবে পূর্ণ হবে',
          leadingIcon: Icons.calendar_month_outlined,
        ),
        const SizedBox(height: PraniSpacing.md),
        PraniPremiumCard(
          padding: const EdgeInsets.all(PraniSpacing.xl),
          child: Column(
            children: [
              _insightRow(
                context,
                'মাসে নতুন অনুরোধ',
                fmtInt(data.monthlyNewRequestsCount),
                Icons.add_chart_outlined,
                scheme,
              ),
              const Divider(height: 20),
              _insightRow(
                context,
                'মাসে সম্পন্ন সেবা',
                fmtInt(data.monthlyCompletedCount),
                Icons.checklist_rtl_rounded,
                scheme,
              ),
              const Divider(height: 20),
              _insightRow(
                context,
                'মাসিক আয়',
                fmtMoney(data.monthlyEarningsBdt),
                Icons.payments_outlined,
                scheme,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _insightRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    ColorScheme scheme,
  ) {
    return Row(
      children: [
        Icon(icon, color: scheme.primary),
        const SizedBox(width: PraniSpacing.md),
        Expanded(child: Text(label)),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
      ],
    );
  }
}

class TechnicianNearbyRepeatRow extends StatelessWidget {
  const TechnicianNearbyRepeatRow({super.key, required this.data});

  final AiTechnicianDashboardData data;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final nearby = data.nearbyFarmersCount;
    final repeat = data.repeatClientsCount;

    return Row(
      children: [
        Expanded(
          child: PraniPremiumCard(
            padding: const EdgeInsets.all(PraniSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.location_on_outlined, color: scheme.primary),
                const SizedBox(height: PraniSpacing.sm),
                Text(
                  'কাছাকাছি খামারি',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  nearby == null ? 'শীঘ্রই' : '$nearby জন',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
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
                Icon(Icons.groups_2_outlined, color: scheme.primary),
                const SizedBox(height: PraniSpacing.sm),
                Text(
                  'পুনরাবৃত্তি ক্লায়েন্ট',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  repeat == null ? 'শীঘ্রই' : '$repeat জন',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

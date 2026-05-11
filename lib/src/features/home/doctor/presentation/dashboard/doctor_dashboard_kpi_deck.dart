import 'package:flutter/material.dart';

import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_premium_card.dart';
import 'package:pranidoctor_mobile/src/features/profile/data/dashboard_context_models.dart';

String _metric(int? v) => v == null ? '—' : '$v';

String _money(double? v) {
  if (v == null) return '—';
  final rounded = v.round();
  return '৳$rounded';
}

/// Horizontal KPI strip — values come from [DashboardContextDoctor] when API supplies them.
class DoctorDashboardKpiDeck extends StatelessWidget {
  const DoctorDashboardKpiDeck({super.key, required this.doctor});

  final DashboardContextDoctor? doctor;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final d = doctor;
    return LayoutBuilder(
      builder: (context, c) {
        final narrow = c.maxWidth < 380;
        final tiles = <Widget>[
          _DoctorKpiTile(
            title: 'অ্যাপয়েন্ট কিউ',
            value: _metric(d?.appointmentQueueCount),
            icon: Icons.queue_play_next_outlined,
            scheme: scheme,
            narrow: narrow,
          ),
          _DoctorKpiTile(
            title: 'জরুরি কেস',
            value: _metric(d?.emergencyCasesCount),
            icon: Icons.emergency_outlined,
            scheme: scheme,
            narrow: narrow,
          ),
          _DoctorKpiTile(
            title: 'আজকের সূচি',
            value: _metric(d?.todayScheduleCount),
            icon: Icons.calendar_today_outlined,
            scheme: scheme,
            narrow: narrow,
          ),
          _DoctorKpiTile(
            title: 'সক্রিয় রোগী',
            value: _metric(d?.activePatientsCount),
            icon: Icons.monitor_heart_outlined,
            scheme: scheme,
            narrow: narrow,
          ),
          _DoctorKpiTile(
            title: 'প্রেসক্রিপশন (অপেক্ষমাণ)',
            value: _metric(d?.pendingPrescriptionsCount),
            icon: Icons.medication_outlined,
            scheme: scheme,
            narrow: narrow,
          ),
          _DoctorKpiTile(
            title: 'মাসিক আয়',
            value: _money(d?.earningsThisMonthBdt),
            icon: Icons.account_balance_wallet_outlined,
            scheme: scheme,
            narrow: narrow,
          ),
          _DoctorKpiTile(
            title: 'ফলো-আপ',
            value: _metric(d?.followUpCasesCount),
            icon: Icons.event_repeat_outlined,
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

class _DoctorKpiTile extends StatelessWidget {
  const _DoctorKpiTile({
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
    final w = narrow ? 152.0 : 162.0;
    return SizedBox(
      width: w,
      child: PraniPremiumCard(
        padding: const EdgeInsets.fromLTRB(
          PraniSpacing.md,
          PraniSpacing.md,
          PraniSpacing.md,
          PraniSpacing.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 22, color: scheme.primary),
            const SizedBox(height: PraniSpacing.sm),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    height: 1.25,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

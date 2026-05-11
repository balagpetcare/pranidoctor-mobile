import 'package:flutter/material.dart';

import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_empty_state.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_premium_card.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_section_header.dart';
import 'package:pranidoctor_mobile/src/features/profile/data/dashboard_context_models.dart';

String _n(int? v) => v == null ? '—' : '$v';

class DoctorAppointmentServiceOverview extends StatelessWidget {
  const DoctorAppointmentServiceOverview({
    super.key,
    required this.doctor,
    required this.onOpenAppointments,
  });

  final DashboardContextDoctor? doctor;
  final VoidCallback onOpenAppointments;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final d = doctor;
    final has = d?.hasAnyMetrics ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const PraniSectionHeader(
          title: 'সেবা ও অ্যাপয়েন্টমেন্ট',
          subtitle: 'কিউ, সূচি ও জরুরি',
          leadingIcon: Icons.medical_information_outlined,
        ),
        const SizedBox(height: PraniSpacing.md),
        PraniPremiumCard(
          padding: const EdgeInsets.all(PraniSpacing.lg),
          child: has
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _row(
                      context,
                      Icons.queue_play_next_outlined,
                      'অ্যাপয়েন্টমেন্ট কিউ',
                      _n(d!.appointmentQueueCount),
                    ),
                    const Divider(height: PraniSpacing.xl),
                    _row(
                      context,
                      Icons.calendar_month_outlined,
                      'আজকের সূচি',
                      _n(d.todayScheduleCount),
                    ),
                    const Divider(height: PraniSpacing.xl),
                    _row(
                      context,
                      Icons.emergency_outlined,
                      'জরুরি কেস',
                      _n(d.emergencyCasesCount),
                    ),
                    const SizedBox(height: PraniSpacing.md),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: onOpenAppointments,
                        child: const Text('অ্যাপয়েন্টমেন্ট ট্যাব'),
                      ),
                    ),
                  ],
                )
              : PraniEmptyState(
                  title: 'এখনও মেট্রিক নেই',
                  message:
                      'সার্ভার থেকে অ্যাপয়েন্টমেন্ট সংখ্যা এলে এখানে দেখা যাবে।',
                  icon: Icons.event_note_outlined,
                  iconColor: scheme.outline,
                  actionLabel: 'অ্যাপয়েন্টমেন্ট',
                  onAction: onOpenAppointments,
                  boxed: false,
                ),
        ),
      ],
    );
  }

  Widget _row(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, color: scheme.primary),
        const SizedBox(width: PraniSpacing.md),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
      ],
    );
  }
}

class DoctorPrescriptionSummaryCard extends StatelessWidget {
  const DoctorPrescriptionSummaryCard({super.key, required this.doctor});

  final DashboardContextDoctor? doctor;

  @override
  Widget build(BuildContext context) {
    final d = doctor;
    final pending = d?.pendingPrescriptionsCount;
    final issued = d?.prescriptionsIssuedThisMonth;
    final has = pending != null || issued != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const PraniSectionHeader(
          title: 'প্রেসক্রিপশন সারাংশ',
          subtitle: 'অপেক্ষমাণ ও মাসিক ইস্যু',
          leadingIcon: Icons.medication_outlined,
        ),
        const SizedBox(height: PraniSpacing.md),
        PraniPremiumCard(
          padding: const EdgeInsets.all(PraniSpacing.lg),
          child: has
              ? Row(
                  children: [
                    Expanded(
                      child: _mini(
                        context,
                        'অপেক্ষমাণ',
                        _n(pending),
                      ),
                    ),
                    const SizedBox(width: PraniSpacing.md),
                    Expanded(
                      child: _mini(
                        context,
                        'মাসে ইস্যু',
                        _n(issued),
                      ),
                    ),
                  ],
                )
              : Text(
                  'প্রেসক্রিপশন মেট্রিক API থেকে আসলে এখানে দেখানো হবে।',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        height: 1.45,
                      ),
                ),
        ),
      ],
    );
  }

  Widget _mini(BuildContext context, String k, String v) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(PraniSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              v,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              k,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class DoctorPatientManagementOverview extends StatelessWidget {
  const DoctorPatientManagementOverview({
    super.key,
    required this.doctor,
    required this.onOpenPatients,
  });

  final DashboardContextDoctor? doctor;
  final VoidCallback onOpenPatients;

  @override
  Widget build(BuildContext context) {
    final d = doctor;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const PraniSectionHeader(
          title: 'রোগী ব্যবস্থাপনা',
          subtitle: 'সক্রিয় ও ফলো-আপ',
          leadingIcon: Icons.groups_outlined,
        ),
        const SizedBox(height: PraniSpacing.md),
        PraniPremiumCard(
          padding: const EdgeInsets.all(PraniSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _stat(
                      context,
                      'সক্রিয় রোগী',
                      _n(d?.activePatientsCount),
                    ),
                  ),
                  const SizedBox(width: PraniSpacing.md),
                  Expanded(
                    child: _stat(
                      context,
                      'ফলো-আপ কেস',
                      _n(d?.followUpCasesCount),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: PraniSpacing.md),
              FilledButton.tonalIcon(
                onPressed: onOpenPatients,
                icon: const Icon(Icons.groups_rounded),
                label: const Text('রোগী তালিকা (ট্যাব)'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _stat(BuildContext context, String label, String value) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}

/// UI + copy explaining telemedicine / video visit readiness (API-driven flag).
class DoctorTelemedicineArchitectureCard extends StatelessWidget {
  const DoctorTelemedicineArchitectureCard({super.key, required this.doctor});

  final DashboardContextDoctor? doctor;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final capable = doctor?.telemedicineCapable ?? false;
    final today = doctor?.telemedicineTodayCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const PraniSectionHeader(
          title: 'টেলিমেডিসিন',
          subtitle: 'ভিডিও ভিজিট প্রস্তুতি',
          leadingIcon: Icons.video_call_outlined,
        ),
        const SizedBox(height: PraniSpacing.md),
        PraniPremiumCard(
          padding: const EdgeInsets.all(PraniSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    capable ? Icons.verified_outlined : Icons.hourglass_empty_rounded,
                    color: capable ? scheme.primary : scheme.outline,
                  ),
                  const SizedBox(width: PraniSpacing.sm),
                  Expanded(
                    child: Text(
                      capable
                          ? 'টেলিমেডিসিন চ্যানেল সক্রিয় (সার্ভার নিশ্চিতকরণ)'
                          : 'মডিউল আর্কিটেকচার প্রস্তুত — সার্ভার ফ্ল্যাগ অপেক্ষমাণ',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: PraniSpacing.sm),
              Text(
                'ভবিষ্যতে: ওয়েবআরটিসি / তৃতীয় পক্ষ ভিডিও প্রদানকারী সংযোগ, '
                'সেশন টোকেন ও বিলিং হুক একই কার্ড থেকে খুলবে।',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      height: 1.45,
                    ),
              ),
              if (today != null) ...[
                const SizedBox(height: PraniSpacing.md),
                Text(
                  'আজকের ভিডিও সেশন: $today',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

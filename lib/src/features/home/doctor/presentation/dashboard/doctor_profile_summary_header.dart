import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_premium_card.dart';
import 'package:pranidoctor_mobile/src/features/home/doctor/application/doctor_availability_notifier.dart';
import 'package:pranidoctor_mobile/src/features/profile/data/dashboard_context_models.dart';

/// Doctor hero card: identity, rating, desk presence, local emergency readiness.
class DoctorProfileSummaryHeader extends ConsumerWidget {
  const DoctorProfileSummaryHeader({
    super.key,
    required this.user,
    required this.doctor,
    required this.onUpdateAvailabilityTap,
  });

  final DashboardContextUser user;
  final DashboardContextDoctor? doctor;
  final VoidCallback onUpdateAvailabilityTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final availability = ref.watch(doctorAvailabilityProvider);
    final displayName = (doctor?.displayName?.trim().isNotEmpty ?? false)
        ? doctor!.displayName!.trim()
        : user.name.trim();
    final specialty = doctor?.specialty?.trim();
    final rating = doctor?.rating;
    final avg = rating?.average;
    final ratingLabel = avg != null ? avg.toStringAsFixed(1) : '—';
    final rc = rating?.count ?? 0;
    final ratingHelper = rc > 0 ? '$rcটি রিভিউ' : 'রিভিউ তথ্য শীঘ্রই';

    final serverEmerg = doctor?.acceptsEmergency;

    return PraniPremiumCard(
      padding: const EdgeInsets.all(PraniSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: scheme.primaryContainer,
                backgroundImage:
                    user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
                child: user.avatarUrl == null
                    ? Icon(Icons.person_rounded, color: scheme.onPrimaryContainer)
                    : null,
              ),
              const SizedBox(width: PraniSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName.isEmpty ? 'চিকিৎসক' : displayName,
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                      ),
                    ),
                    if (specialty != null && specialty.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        specialty,
                        style: textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    const SizedBox(height: PraniSpacing.sm),
                    Wrap(
                      spacing: PraniSpacing.sm,
                      runSpacing: PraniSpacing.sm,
                      children: [
                        Chip(
                          avatar: Icon(
                            Icons.star_rounded,
                            size: 18,
                            color: scheme.primary,
                          ),
                          label: Text('$ratingLabel · $ratingHelper'),
                        ),
                        if (serverEmerg != null)
                          Chip(
                            avatar: Icon(
                              Icons.verified_outlined,
                              size: 18,
                              color: scheme.tertiary,
                            ),
                            label: Text(
                              serverEmerg ? 'সার্ভার: জরুরি ON' : 'সার্ভার: জরুরি OFF',
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: PraniSpacing.lg),
          Text(
            'ডেস্ক উপস্থিতি',
            style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: PraniSpacing.sm),
          SegmentedButton<DoctorPresenceMode>(
            segments: [
              ButtonSegment(
                value: DoctorPresenceMode.online,
                label: Text(DoctorPresenceMode.online.labelBn),
                icon: const Icon(Icons.wifi_rounded, size: 18),
              ),
              ButtonSegment(
                value: DoctorPresenceMode.busy,
                label: Text(DoctorPresenceMode.busy.labelBn),
                icon: const Icon(Icons.do_not_disturb_on_rounded, size: 18),
              ),
              ButtonSegment(
                value: DoctorPresenceMode.offline,
                label: Text(DoctorPresenceMode.offline.labelBn),
                icon: const Icon(Icons.cloud_off_rounded, size: 18),
              ),
            ],
            selected: {availability.mode},
            onSelectionChanged: (s) {
              ref.read(doctorAvailabilityProvider.notifier).setMode(s.first);
            },
          ),
          const SizedBox(height: PraniSpacing.md),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: const Text('জরুরি কেস গ্রহণ (লোকাল)'),
            subtitle: Text(
              'ডিভাইসে সংরক্ষিত — API সংযুক্ত হলে সার্ভার মিলিয়ে নিন।',
              style: textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            value: availability.emergencyAvailable,
            onChanged: (v) {
              ref.read(doctorAvailabilityProvider.notifier).setEmergencyAvailable(v);
            },
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: onUpdateAvailabilityTap,
              icon: const Icon(Icons.tune_rounded, size: 18),
              label: const Text('উপস্থিতি বিস্তারিত'),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_premium_card.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/application/technician_presence_provider.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/data/ai_technician_models.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/presentation/widgets/technician_emergency_availability_card.dart';

/// Hero profile summary + presence + emergency (server-backed) row.
class TechnicianProfileSummaryHeader extends ConsumerWidget {
  const TechnicianProfileSummaryHeader({
    super.key,
    required this.profile,
    required this.data,
    required this.ratingLabel,
    required this.ratingHelper,
    required this.settingsBusy,
    required this.onEmergencyToggle,
  });

  final AiTechnicianProfile profile;
  final AiTechnicianDashboardData data;
  final String ratingLabel;
  final String ratingHelper;
  final bool settingsBusy;
  final ValueChanged<bool> onEmergencyToggle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final presence = ref.watch(technicianPresenceProvider);
    final name = profile.displayName?.trim().isNotEmpty == true
        ? profile.displayName!.trim()
        : 'টেকনিশিয়ান';
    final area = _areaLine(profile);

    return PraniPremiumCard(
      padding: EdgeInsets.zero,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(PraniRadius.card),
          gradient: LinearGradient(
            colors: [
              scheme.primaryContainer.withValues(alpha: 0.55),
              scheme.surface,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(PraniSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: scheme.primary.withValues(alpha: 0.18),
                    child: Icon(Icons.engineering_rounded, color: scheme.primary),
                  ),
                  const SizedBox(width: PraniSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (area != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            area,
                            style: PraniTextStyles.bodyMuted(scheme, textTheme),
                          ),
                        ],
                        const SizedBox(height: PraniSpacing.sm),
                        Wrap(
                          spacing: PraniSpacing.sm,
                          runSpacing: PraniSpacing.xs,
                          children: [
                            Chip(
                              avatar: Icon(
                                Icons.star_rounded,
                                size: 18,
                                color: scheme.primary,
                              ),
                              label: Text('$ratingLabel · $ratingHelper'),
                              visualDensity: VisualDensity.compact,
                              side: BorderSide(color: scheme.outlineVariant),
                            ),
                            Chip(
                              label: Text(
                                AiTechnicianStatusCopy.providerStatusBn(
                                  data.providerStatus ?? profile.providerStatus,
                                ),
                              ),
                              visualDensity: VisualDensity.compact,
                              side: BorderSide(color: scheme.outlineVariant),
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
                'উপস্থিতি',
                style: textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: PraniSpacing.sm),
              SegmentedButton<TechnicianPresenceMode>(
                segments: [
                  ButtonSegment(
                    value: TechnicianPresenceMode.online,
                    label: Text(TechnicianPresenceMode.online.labelBn),
                    icon: const Icon(Icons.wifi_rounded, size: 18),
                  ),
                  ButtonSegment(
                    value: TechnicianPresenceMode.busy,
                    label: Text(TechnicianPresenceMode.busy.labelBn),
                    icon: const Icon(Icons.do_not_disturb_on_rounded, size: 18),
                  ),
                  ButtonSegment(
                    value: TechnicianPresenceMode.offline,
                    label: Text(TechnicianPresenceMode.offline.labelBn),
                    icon: const Icon(Icons.cloud_off_rounded, size: 18),
                  ),
                ],
                selected: {presence},
                onSelectionChanged: (s) {
                  final m = s.first;
                  ref.read(technicianPresenceProvider.notifier).setMode(m);
                },
              ),
              const SizedBox(height: PraniSpacing.xl),
              TechnicianEmergencyAvailabilityCard(
                acceptsEmergency: data.acceptsEmergency,
                published: data.isPublished,
                busy: settingsBusy,
                profileUpdatedAtIso: profile.updatedAt,
                onToggle: onEmergencyToggle,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _areaLine(AiTechnicianProfile p) {
    final parts = <String>[];
    final d = p.district?.trim();
    final u = p.upazila?.trim();
    final n = p.unionOrArea?.trim();
    if (d != null && d.isNotEmpty) parts.add(d);
    if (u != null && u.isNotEmpty) parts.add(u);
    if (n != null && n.isNotEmpty) parts.add(n);
    if (parts.isEmpty) return null;
    return parts.join(' · ');
  }
}

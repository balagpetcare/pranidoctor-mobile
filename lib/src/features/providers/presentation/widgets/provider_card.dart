import 'package:flutter/material.dart';

import 'package:pranidoctor_mobile/src/core/constants/pd_spacing.dart';
import 'package:pranidoctor_mobile/src/features/providers/data/provider_kind.dart';
import 'package:pranidoctor_mobile/src/features/providers/data/provider_profile_model.dart';

/// Shared list card for doctors and AI technicians (Bengali-first).
class ProviderCard extends StatelessWidget {
  const ProviderCard({
    super.key,
    required this.profile,
    required this.onOpenDetail,
  });

  final ProviderProfile profile;
  final VoidCallback onOpenDetail;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpenDetail,
        child: Padding(
          padding: const EdgeInsets.all(PdSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: scheme.primaryContainer,
                    backgroundImage:
                        profile.profilePhotoUrl != null &&
                            (profile.profilePhotoUrl!.startsWith('http://') ||
                                profile.profilePhotoUrl!.startsWith('https://'))
                        ? NetworkImage(profile.profilePhotoUrl!)
                        : null,
                    child:
                        profile.profilePhotoUrl != null &&
                            (profile.profilePhotoUrl!.startsWith('http://') ||
                                profile.profilePhotoUrl!.startsWith('https://'))
                        ? null
                        : Icon(
                            profile.kind == ProviderKind.doctor
                                ? Icons.medical_services_outlined
                                : Icons.smart_toy_outlined,
                            color: scheme.onPrimaryContainer,
                          ),
                  ),
                  const SizedBox(width: PdSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile.name,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          profile.kind.labelBn,
                          style: textTheme.labelLarge?.copyWith(
                            color: scheme.primary,
                          ),
                        ),
                        if (profile.titleOrQualification != null &&
                            profile.titleOrQualification!
                                .trim()
                                .isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            profile.titleOrQualification!,
                            style: textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: PdSpacing.sm),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.place_outlined, size: 18, color: scheme.primary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      profile.areaCoverageSummary?.trim().isNotEmpty == true
                          ? profile.areaCoverageSummary!
                          : 'এলাকা — শীঘ্রই',
                      style: textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
              if (profile.animalTypesSummary.isNotEmpty) ...[
                const SizedBox(height: PdSpacing.xs),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: profile.animalTypesSummary
                      .map(
                        (s) => Chip(
                          visualDensity: VisualDensity.compact,
                          label: Text(s, style: textTheme.labelSmall),
                        ),
                      )
                      .toList(),
                ),
              ],
              if (profile.serviceTypesSummary != null &&
                  profile.serviceTypesSummary!.trim().isNotEmpty) ...[
                const SizedBox(height: PdSpacing.xs),
                Text(
                  'সেবা: ${profile.serviceTypesSummary}',
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
              const SizedBox(height: PdSpacing.sm),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _FeeBadge(feeText: profile.feeText),
                  _AvailabilityBadge(text: profile.availabilityText),
                  if (profile.homeVisit)
                    Chip(
                      visualDensity: VisualDensity.compact,
                      avatar: Icon(
                        profile.kind == ProviderKind.doctor
                            ? Icons.home_outlined
                            : Icons.agriculture_outlined,
                        size: 16,
                        color: scheme.primary,
                      ),
                      label: Text(
                        profile.kind == ProviderKind.doctor
                            ? 'হোম ভিজিট'
                            : 'মাঠ সেবা',
                        style: textTheme.labelSmall,
                      ),
                    ),
                  if (profile.emergency)
                    Chip(
                      visualDensity: VisualDensity.compact,
                      avatar: Icon(
                        Icons.emergency_outlined,
                        size: 16,
                        color: scheme.error,
                      ),
                      label: Text(
                        'জরুরি',
                        style: textTheme.labelSmall?.copyWith(
                          color: scheme.error,
                        ),
                      ),
                    ),
                  if (profile.kind == ProviderKind.aiTechnician &&
                      profile.aiTechnicianService)
                    Chip(
                      visualDensity: VisualDensity.compact,
                      avatar: Icon(
                        Icons.support_agent_outlined,
                        size: 16,
                        color: scheme.tertiary,
                      ),
                      label: Text('এআই সেবা', style: textTheme.labelSmall),
                    ),
                  Chip(
                    visualDensity: VisualDensity.compact,
                    label: Text(
                      profile.onlineConsultation ? 'অনলাইন' : 'অনলাইন — শীঘ্রই',
                      style: textTheme.labelSmall,
                    ),
                  ),
                  Chip(
                    visualDensity: VisualDensity.compact,
                    label: Text(
                      profile.rating != null
                          ? 'রেটিং ${profile.rating}'
                          : 'রেটিং — শীঘ্রই',
                      style: textTheme.labelSmall,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: PdSpacing.md),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.tonal(
                  onPressed: onOpenDetail,
                  child: const Text('বিস্তারিত'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeeBadge extends StatelessWidget {
  const _FeeBadge({required this.feeText});

  final String? feeText;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final label = feeText != null && feeText!.trim().isNotEmpty
        ? 'ফি $feeText টাকা'
        : 'ফি — শীঘ্রই';
    return Chip(
      visualDensity: VisualDensity.compact,
      avatar: Icon(Icons.payments_outlined, size: 16, color: scheme.primary),
      label: Text(label, style: Theme.of(context).textTheme.labelSmall),
    );
  }
}

class _AvailabilityBadge extends StatelessWidget {
  const _AvailabilityBadge({required this.text});

  final String? text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final label = text != null && text!.trim().isNotEmpty
        ? text!
        : 'উপলব্ধতা — শীঘ্রই';
    return Chip(
      visualDensity: VisualDensity.compact,
      avatar: Icon(Icons.schedule, size: 16, color: scheme.secondary),
      label: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

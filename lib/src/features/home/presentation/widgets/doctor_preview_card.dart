import 'package:flutter/material.dart';

import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';
import 'package:pranidoctor_mobile/src/features/providers/data/provider_models.dart';

/// Compact doctor summary card for horizontal lists on the home feed.
class DoctorPreviewCard extends StatelessWidget {
  const DoctorPreviewCard({
    super.key,
    required this.doctor,
    required this.onTap,
  });

  final DoctorSummary doctor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final name = doctor.name.trim().isEmpty ? 'নাম পাওয়া যায়নি' : doctor.name;
    final qual = doctor.degreeOrQualification?.trim();
    final ratingText = doctor.rating != null ? '★ ${doctor.rating}' : '★ —';
    final areaLine = doctor.areaText?.trim();
    final avail = doctor.availability?.trim();
    final photo = doctor.profilePhotoUrl?.trim();

    Widget avatarChild;
    if (photo != null &&
        photo.isNotEmpty &&
        (photo.startsWith('http://') || photo.startsWith('https://'))) {
      avatarChild = ClipOval(
        child: Image.network(
          photo,
          width: 56,
          height: 56,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) =>
              Icon(Icons.person_rounded, color: scheme.primary, size: 30),
        ),
      );
    } else {
      avatarChild = Icon(Icons.person_rounded, color: scheme.primary);
    }

    final locationOrDistance = areaLine != null && areaLine.isNotEmpty
        ? 'এলাকা: $areaLine'
        : 'দূরত্ব: শীঘ্রই';

    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(PraniRadii.lg),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.35),
        ),
        boxShadow: PraniShadows.elevatedCardShadow(scheme.brightness),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(PraniRadii.lg),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(PraniSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: scheme.primaryContainer,
                  child: avatarChild,
                ),
                const SizedBox(width: PraniSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (qual != null && qual.isNotEmpty) ...[
                        const SizedBox(height: PraniSpacing.xxs),
                        Text(
                          qual,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                            height: 1.32,
                          ),
                        ),
                      ],
                      const Spacer(),
                      if (avail != null && avail.isNotEmpty) ...[
                        Text(
                          avail,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.labelSmall?.copyWith(
                            color: scheme.primary,
                          ),
                        ),
                        const SizedBox(height: PraniSpacing.xxs),
                      ],
                      Text(
                        ratingText,
                        style: textTheme.labelLarge?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        locationOrDistance,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.labelSmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

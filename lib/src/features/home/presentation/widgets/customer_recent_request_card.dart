import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/pd_spacing.dart';
import '../../../../core/widgets/pd_app_card.dart';
import '../../../../core/widgets/pd_buttons.dart';
import '../../../service_requests/application/service_requests_providers.dart';
import '../../../service_requests/data/service_request_model.dart';
import '../../../service_requests/presentation/service_request_detail_screen.dart';

/// Latest service request summary or empty/error states (Bangla).
class CustomerRecentRequestCard extends ConsumerWidget {
  const CustomerRecentRequestCard({
    super.key,
    required this.onOpenRequestsTab,
    required this.onOpenBooking,
  });

  final VoidCallback onOpenRequestsTab;
  final VoidCallback onOpenBooking;

  static String _formatSubmitted(DateTime t) {
    final d = t.toLocal();
    return '${d.day}/${d.month}/${d.year}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final async = ref.watch(serviceRequestsListProvider);

    return async.when(
      loading: () => PdAppCard(
        padding: const EdgeInsets.all(PdSpacing.md),
        child: Row(
          children: [
            SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: scheme.primary,
              ),
            ),
            const SizedBox(width: PdSpacing.md),
            Expanded(
              child: Text(
                'সাম্প্রতিক অনুরোধ লোড হচ্ছে…',
                style: textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
      error: (e, _) => PdAppCard(
        padding: const EdgeInsets.all(PdSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.cloud_off_outlined, color: scheme.error),
                const SizedBox(width: PdSpacing.sm),
                Expanded(
                  child: Text(
                    'অনুরোধের তালিকা লোড করা যায়নি।',
                    style: textTheme.titleSmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: PdSpacing.xs),
            Text(
              '$e',
              style: textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: PdSpacing.md),
            PdSecondaryButton(
              label: 'আবার চেষ্টা করুন',
              onPressed: () =>
                  ref.read(serviceRequestsListProvider.notifier).refresh(),
            ),
          ],
        ),
      ),
      data: (items) {
        if (items.isEmpty) {
          return PdAppCard(
            padding: const EdgeInsets.all(PdSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'এখনও কোনো অনুরোধ নেই',
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: PdSpacing.xs),
                Text(
                  'নতুন চিকিৎসা বা সেবার জন্য অনুরোধ তৈরি করুন।',
                  style: textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: PdSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: PdPrimaryButton(
                        label: 'নতুন অনুরোধ',
                        onPressed: onOpenBooking,
                      ),
                    ),
                    const SizedBox(width: PdSpacing.sm),
                    Expanded(
                      child: PdSecondaryButton(
                        label: 'অনুরোধ ট্যাব',
                        onPressed: onOpenRequestsTab,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }

        final ServiceRequest r = items.first;
        final animalLine = r.animal != null
            ? '${r.animal!.name} (${r.animal!.species})'
            : 'পশু প্রোফাইল';

        return PdAppCard(
          useShadow: true,
          onTap: () =>
              context.push(ServiceRequestDetailScreen.routePathFor(r.id)),
          padding: const EdgeInsets.all(PdSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'সাম্প্রতিক অনুরোধ',
                style: textTheme.labelLarge?.copyWith(
                  color: scheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: PdSpacing.sm),
              Text(
                r.serviceType.labelBn,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: PdSpacing.xxs),
              Text(
                '${r.status.labelBn} · ${_formatSubmitted(r.submittedAt)}',
                style: textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: PdSpacing.xs),
              Text(animalLine, style: textTheme.bodyMedium),
              const SizedBox(height: PdSpacing.sm),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'বিস্তারিত দেখুন',
                  style: textTheme.labelLarge?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

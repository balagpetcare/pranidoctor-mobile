import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pranidoctor_mobile/src/app/screen_padding.dart';
import 'package:pranidoctor_mobile/src/core/constants/pd_spacing.dart';
import 'package:pranidoctor_mobile/src/core/widgets/pd_async_states.dart';
import 'package:pranidoctor_mobile/src/core/widgets/pd_app_card.dart';
import 'package:pranidoctor_mobile/src/features/service_requests/application/service_requests_providers.dart';
import 'package:pranidoctor_mobile/src/features/service_requests/data/service_request_model.dart';
import 'package:pranidoctor_mobile/src/features/service_requests/presentation/booking_wizard_screen.dart';
import 'package:pranidoctor_mobile/src/features/service_requests/presentation/service_request_detail_screen.dart';
import 'package:pranidoctor_mobile/src/features/service_requests/presentation/widgets/service_request_status_badge.dart';

/// Full-screen list (route) or embedded shell tab ([embeddedInShell]).
class ServiceRequestsListScreen extends ConsumerWidget {
  const ServiceRequestsListScreen({super.key, this.embeddedInShell = false});

  /// When `true`, matches bottom tab: title **অনুরোধ**, no back button, extra bottom padding for FAB.
  final bool embeddedInShell;

  static const routePath = '/service-requests';
  static const routeName = 'serviceRequestsList';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bottomPad = embeddedInShell ? 100.0 : 24.0;
    return Scaffold(
      appBar: AppBar(
        title: Text(embeddedInShell ? 'অনুরোধ' : 'আমার অনুরোধ'),
        automaticallyImplyLeading: !embeddedInShell,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(BookingWizardScreen.routePath),
        icon: const Icon(Icons.add),
        label: const Text('নতুন অনুরোধ'),
      ),
      body: ServiceRequestsListBody(bottomPadding: bottomPad),
    );
  }
}

/// Shared scrollable list body (refresh, loading/error/empty, cards).
class ServiceRequestsListBody extends ConsumerWidget {
  const ServiceRequestsListBody({super.key, required this.bottomPadding});

  final double bottomPadding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(serviceRequestsListProvider);
    final hPad = pdScreenPadding(context).horizontal;

    return RefreshIndicator(
      onRefresh: () => ref.read(serviceRequestsListProvider.notifier).refresh(),
      child: async.when(
        loading: () => ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(hPad, 48, hPad, bottomPadding),
          children: const [
            PdLoadingBody(message: 'অনুরোধের তালিকা লোড হচ্ছে…'),
          ],
        ),
        error: (e, _) => ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(hPad, 24, hPad, bottomPadding),
          children: [
            SizedBox(
              height: 420,
              child: PdErrorBody(
                title: 'লোড করা যায়নি',
                message: '$e',
                retryLabel: 'আবার চেষ্টা করুন',
                onRetry: () =>
                    ref.read(serviceRequestsListProvider.notifier).refresh(),
              ),
            ),
          ],
        ),
        data: (items) {
          if (items.isEmpty) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(hPad, 24, hPad, bottomPadding),
              children: [
                SizedBox(
                  height: 440,
                  child: PdEmptyState(
                    icon: Icons.assignment_outlined,
                    title: 'কোনো অনুরোধ নেই',
                    subtitle:
                        'নতুন চিকিৎসা বা সেবার অনুরোধ জমা দিতে নিচের বোতাম চাপুন।',
                    actionLabel: 'নতুন অনুরোধ',
                    onAction: () => context.push(BookingWizardScreen.routePath),
                  ),
                ),
              ],
            );
          }

          return ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(hPad, 16, hPad, bottomPadding),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(height: PdSpacing.sm),
            itemBuilder: (context, i) {
              final r = items[i];
              return _RequestCard(
                request: r,
                onTap: () =>
                    context.push(ServiceRequestDetailScreen.routePathFor(r.id)),
              );
            },
          );
        },
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({required this.request, required this.onTap});

  final ServiceRequest request;
  final VoidCallback onTap;

  static String _formatDate(DateTime t) {
    final d = t.toLocal();
    return '${d.day}/${d.month}/${d.year}';
  }

  static String _formatDateTime(DateTime t) {
    final d = t.toLocal();
    final hh = d.hour.toString().padLeft(2, '0');
    final mm = d.minute.toString().padLeft(2, '0');
    return '${d.day}/${d.month}/${d.year}, $hh:$mm';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final animalLine = request.animal != null
        ? '${request.animal!.name} (${request.animal!.species})'
        : 'পশু তথ্য উপলব্ধ নয়';

    final locationLine = request.locationText?.trim().isNotEmpty == true
        ? request.locationText!.trim()
        : (request.areaId != null && request.areaId!.trim().isNotEmpty)
        ? 'এলাকা: ${request.areaId}'
        : null;

    final timeParts = <String>[
      'জমা: ${_formatDateTime(request.submittedAt)}',
      if (request.preferredTime?.trim().isNotEmpty == true)
        'পছন্দের সময়: ${request.preferredTime!.trim()}',
      if (request.scheduledStart != null)
        'নির্ধারিত: ${_formatDate(request.scheduledStart!)}',
    ];

    return PdAppCard(
      useShadow: true,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  request.serviceType.labelBn,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: PdSpacing.sm),
              ServiceRequestStatusBadge(status: request.status),
            ],
          ),
          const SizedBox(height: PdSpacing.sm),
          Row(
            children: [
              Icon(Icons.pets_outlined, size: 18, color: scheme.primary),
              const SizedBox(width: 6),
              Expanded(child: Text(animalLine, style: textTheme.bodyMedium)),
            ],
          ),
          if (locationLine != null) ...[
            const SizedBox(height: PdSpacing.xs),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.place_outlined,
                  size: 18,
                  color: scheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    locationLine,
                    style: textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: PdSpacing.sm),
          Text(
            timeParts.join(' · '),
            style: textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: PdSpacing.xs),
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
  }
}

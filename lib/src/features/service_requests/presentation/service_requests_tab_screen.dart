import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pranidoctor_mobile/src/app/screen_padding.dart';
import 'package:pranidoctor_mobile/src/app/user_visible_async_error.dart';
import 'package:pranidoctor_mobile/src/core/assets/prani_assets.dart';
import 'package:pranidoctor_mobile/src/core/config/app_config.dart';
import 'package:pranidoctor_mobile/src/features/billing/data/billing_payment_summary_model.dart';
import 'package:pranidoctor_mobile/src/features/billing/presentation/widgets/customer_billing_summary_card.dart';
import 'package:pranidoctor_mobile/src/features/service_requests/application/service_requests_providers.dart';
import 'package:pranidoctor_mobile/src/features/service_requests/data/service_request_model.dart';
import 'package:pranidoctor_mobile/src/features/service_requests/data/service_request_repository.dart';
import 'package:pranidoctor_mobile/src/features/service_requests/presentation/booking_wizard_screen.dart';

class ServiceRequestsTabScreen extends ConsumerWidget {
  const ServiceRequestsTabScreen({super.key});

  /// Space below the last list card so content clears the extended FAB overlay.
  static const double _listBottomClearFab = 88;

  static const double _emptyHeroAspectRatio = 2.12;

  static void _safeOpenBooking(BuildContext context) {
    try {
      context.pushNamed(BookingWizardScreen.routeName);
    } catch (e, stack) {
      assert(() {
        debugPrint('ServiceRequestsTab: booking route failed: $e\n$stack');
        return true;
      }());
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text('নতুন অনুরোধ খুলতে সমস্যা হয়েছে। আবার চেষ্টা করুন।'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(serviceRequestsListProvider);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final hPad = pdScreenPadding(context).horizontal;
    final maxW = pdReadableMaxWidth(context);
    final bottomFabPad =
        10.0 + MediaQuery.viewPaddingOf(context).bottom.clamp(0.0, 24.0);

    return Scaffold(
      appBar: AppBar(title: const Text('অনুরোধ')),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: bottomFabPad),
        child: FloatingActionButton.extended(
          elevation: 2,
          focusElevation: 4,
          hoverElevation: 4,
          highlightElevation: 2,
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          onPressed: () => _safeOpenBooking(context),
          icon: const Icon(Icons.add),
          label: const Text('নতুন অনুরোধ'),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(serviceRequestsListProvider.notifier).refresh(),
        child: async.when(
          loading: () => CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: CircularProgressIndicator(color: scheme.primary),
                ),
              ),
            ],
          ),
          error: (e, _) {
            assert(() {
              debugPrint('serviceRequestsListProvider error: $e');
              return true;
            }());
            return CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(hPad, 24, hPad, 24),
                  sliver: SliverToBoxAdapter(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: maxW),
                        child: Column(
                          children: [
                            Icon(
                              Icons.cloud_off_outlined,
                              size: 44,
                              color: scheme.error,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'লোড করা যায়নি',
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              userVisibleAsyncErrorBn(e),
                              textAlign: TextAlign.center,
                              style: textTheme.bodyMedium?.copyWith(
                                color: scheme.onSurfaceVariant,
                                height: 1.45,
                              ),
                            ),
                            const SizedBox(height: 22),
                            FilledButton.icon(
                              onPressed: () => ref
                                  .read(serviceRequestsListProvider.notifier)
                                  .refresh(),
                              icon: const Icon(Icons.refresh),
                              label: const Text('আবার চেষ্টা করুন'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
          data: (items) {
            if (items.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  hPad,
                  8,
                  hPad,
                  _listBottomClearFab + bottomFabPad,
                ),
                children: [
                  Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxW),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          PraniBrandHero(
                            assetPath: PraniAssets.serviceTracking,
                            aspectRatio: _emptyHeroAspectRatio,
                            fit: BoxFit.cover,
                            alignment: Alignment.center,
                            borderRadius: BorderRadius.circular(16),
                            semanticLabel: 'সেবা অনুরোধ ট্র্যাকিং',
                          ),
                          const SizedBox(height: 18),
                          DecoratedBox(
                            decoration: BoxDecoration(
                              color: scheme.primaryContainer,
                              shape: BoxShape.circle,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Icon(
                                Icons.assignment_outlined,
                                size: 32,
                                color: scheme.onPrimaryContainer,
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            'কোনো অনুরোধ নেই',
                            textAlign: TextAlign.center,
                            style: textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'খামারে ডাক্তার বা টেকনিশিয়ানের সেবার জন্য নতুন অনুরোধ জমা দিতে নিচের «নতুন অনুরোধ» বোতাম চাপুন।',
                            textAlign: TextAlign.center,
                            style: textTheme.bodyLarge?.copyWith(
                              color: scheme.onSurfaceVariant,
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }
            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                hPad,
                12,
                hPad,
                _listBottomClearFab + bottomFabPad,
              ),
              itemCount: items.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final r = items[i];
                return _ServiceRequestListCard(
                  serviceLabel: r.serviceType.labelBn,
                  statusAndDate:
                      '${r.status.labelBn} · ${_formatSubmitted(r.submittedAt)}',
                  onTap: () => context.push(
                    ServiceRequestDetailScreen.routePathFor(r.id),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  static String _formatSubmitted(DateTime t) {
    final d = t.toLocal();
    return '${d.day}/${d.month}/${d.year}';
  }
}

class _ServiceRequestListCard extends StatelessWidget {
  const _ServiceRequestListCard({
    required this.serviceLabel,
    required this.statusAndDate,
    required this.onTap,
  });

  final String serviceLabel;
  final String statusAndDate;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      serviceLabel,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        height: 1.32,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      statusAndDate,
                      style: textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                        height: 1.35,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                color: scheme.outline,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ServiceRequestDetailScreen extends ConsumerWidget {
  const ServiceRequestDetailScreen({super.key, required this.requestId});

  final String requestId;

  static const routeName = 'serviceRequestDetail';

  static String routePathFor(String id) => '/service-requests/$id';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(serviceRequestDetailProvider(requestId));
    final hPad = pdScreenPadding(context).horizontal;

    return Scaffold(
      appBar: AppBar(title: const Text('অনুরোধের বিবরণ')),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: EdgeInsets.all(hPad),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'লোড করা যায়নি',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  userVisibleAsyncErrorBn(e),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
        data: (r) => ListView(
          padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 32),
          children: [
            PraniBrandHero(
              assetPath: PraniAssets.serviceTracking,
              height: 136,
              fit: BoxFit.cover,
              semanticLabel: 'অনুরোধ ট্র্যাকিং ও খামার সেবা',
            ),
            const SizedBox(height: 16),
            _StatusBanner(status: r.status),
            const SizedBox(height: 16),
            CustomerBillingSummaryCard(
              summary: _customerBillingForDisplay(r),
              isEmpty: _customerBillingEmpty(r),
            ),
            const SizedBox(height: 16),
            _DetailSection(title: 'সেবার ধরন', body: r.serviceType.labelBn),
            _DetailSection(title: 'স্ট্যাটাস', body: r.status.labelBn),
            if (r.assignedDoctorDisplayName != null)
              _DetailSection(
                title: 'নিয়োজিত ডাক্তার',
                body: r.assignedDoctorDisplayName!,
              ),
            if (r.assignedTechnicianDisplayName != null)
              _DetailSection(
                title: 'নিয়োজিত টেকনিশিয়ান',
                body: r.assignedTechnicianDisplayName!,
              ),
            if (r.assignedAt != null)
              _DetailSection(
                title: 'নিয়োগের সময়',
                body: _formatDt(r.assignedAt!),
              ),
            if (r.startedAt != null)
              _DetailSection(
                title: 'কাজ শুরুর সময়',
                body: _formatDt(r.startedAt!),
              ),
            if (r.completedAt != null)
              _DetailSection(
                title: 'সমাপ্তির সময়',
                body: _formatDt(r.completedAt!),
              ),
            if (r.animal != null)
              _DetailSection(
                title: 'পশু',
                body: '${r.animal!.name} (${r.animal!.species})',
              ),
            if (r.serviceCategory != null)
              _DetailSection(title: 'ক্যাটাগরি', body: r.serviceCategory!.name),
            _DetailSection(
              title: 'সমস্যা / লক্ষণ',
              body: r.problemOrSymptom?.trim().isNotEmpty == true
                  ? r.problemOrSymptom!
                  : '—',
            ),
            _DetailSection(
              title: 'বিবরণ',
              body: r.description?.trim().isNotEmpty == true
                  ? r.description!
                  : '—',
            ),
            _DetailSection(
              title: 'ঠিকানা / অবস্থান',
              body: r.locationText?.trim().isNotEmpty == true
                  ? r.locationText!
                  : '—',
            ),
            _DetailSection(
              title: 'পছন্দের সময়',
              body: r.preferredTime?.trim().isNotEmpty == true
                  ? r.preferredTime!
                  : '—',
            ),
            _DetailSection(title: 'জমার সময়', body: _formatDt(r.submittedAt)),
            if (r.cancelledAt != null)
              _DetailSection(
                title: 'বাতিলের সময়',
                body: _formatDt(r.cancelledAt!),
              ),
            if (r.cancelReason?.trim().isNotEmpty == true)
              _DetailSection(title: 'বাতিলের কারণ', body: r.cancelReason!),
            if (r.canCustomerCancel) ...[
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () => _confirmCancel(context, ref, r.id),
                icon: const Icon(Icons.cancel_outlined),
                label: const Text('অনুরোধ বাতিল করুন'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static String _formatDt(DateTime t) {
    final d = t.toLocal();
    return '${d.day}/${d.month}/${d.year}, ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  static BillingPaymentSummary? _customerBillingForDisplay(ServiceRequest r) {
    var b = r.billing;
    if (b == null && AppConfig.useMockBillingUi) {
      b = BillingPaymentSummary.demoForCustomerPreview();
    }
    return b;
  }

  static bool _customerBillingEmpty(ServiceRequest r) {
    final b = _customerBillingForDisplay(r);
    if (b == null) return true;
    return b.isEmptyForCustomerView;
  }

  static Future<void> _confirmCancel(
    BuildContext context,
    WidgetRef ref,
    String id,
  ) async {
    final reasonCtrl = TextEditingController();
    try {
      final go = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('বাতিল করবেন?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('এই অনুরোধ বাতিল করা হলে আর চালিয়ে যাওয়া যাবে না।'),
              const SizedBox(height: 12),
              TextField(
                controller: reasonCtrl,
                decoration: const InputDecoration(
                  labelText: 'কারণ (ঐচ্ছিক)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('না'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('হ্যাঁ, বাতিল করুন'),
            ),
          ],
        ),
      );
      if (go != true || !context.mounted) return;

      final reason = reasonCtrl.text.trim();

      try {
        await ref
            .read(serviceRequestRepositoryProvider)
            .cancel(id, cancelReason: reason.isEmpty ? null : reason);
        if (!context.mounted) return;
        ref.invalidate(serviceRequestDetailProvider(id));
        ref.invalidate(serviceRequestsListProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('অনুরোধ বাতিল করা হয়েছে')),
        );
      } on ServiceRequestApiException catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      reasonCtrl.dispose();
    }
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.status});

  final ServiceRequestStatus status;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = switch (status) {
      ServiceRequestStatus.PENDING => scheme.secondaryContainer,
      ServiceRequestStatus.ASSIGNED ||
      ServiceRequestStatus.ACCEPTED ||
      ServiceRequestStatus.IN_PROGRESS => scheme.tertiaryContainer,
      ServiceRequestStatus.CANCELLED ||
      ServiceRequestStatus.REJECTED => scheme.errorContainer,
      ServiceRequestStatus.COMPLETED => scheme.primaryContainer,
    };
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(Icons.flag_outlined, color: scheme.onSecondaryContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                status.labelBn,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(body, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}

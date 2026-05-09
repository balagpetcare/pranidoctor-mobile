import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pranidoctor_mobile/src/app/screen_padding.dart';
import 'package:pranidoctor_mobile/src/core/config/app_config.dart';
import 'package:pranidoctor_mobile/src/features/billing/data/billing_payment_summary_model.dart';
import 'package:pranidoctor_mobile/src/features/billing/presentation/widgets/customer_billing_summary_card.dart';
import 'package:pranidoctor_mobile/src/features/service_requests/application/service_requests_providers.dart';
import 'package:pranidoctor_mobile/src/features/service_requests/data/service_request_model.dart';
import 'package:pranidoctor_mobile/src/features/service_requests/data/service_request_repository.dart';
import 'package:pranidoctor_mobile/src/features/service_requests/presentation/booking_wizard_screen.dart';

class ServiceRequestsTabScreen extends ConsumerWidget {
  const ServiceRequestsTabScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(serviceRequestsListProvider);
    final scheme = Theme.of(context).colorScheme;
    final hPad = pdScreenPadding(context).horizontal;

    return Scaffold(
      appBar: AppBar(title: const Text('অনুরোধ')),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(serviceRequestsListProvider.notifier).refresh(),
        child: async.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(hPad),
            children: [
              const SizedBox(height: 48),
              Icon(Icons.error_outline, size: 48, color: scheme.error),
              const SizedBox(height: 16),
              Text(
                'লোড করা যায়নি',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '$e',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          data: (items) {
            if (items.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(hPad),
                children: [
                  const SizedBox(height: 48),
                  Icon(
                    Icons.assignment_outlined,
                    size: 56,
                    color: scheme.primary,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'কোনো অনুরোধ নেই',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'নতুন চিকিৎসা বা সেবার অনুরোধ জমা দিতে নিচের বোতাম চাপুন।',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              );
            }
            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 100),
              itemCount: items.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final r = items[i];
                return Card(
                  child: ListTile(
                    title: Text(r.serviceType.labelBn),
                    subtitle: Text(
                      '${r.status.labelBn} · ${_formatSubmitted(r.submittedAt)}',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push(
                      ServiceRequestDetailScreen.routePathFor(r.id),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(BookingWizardScreen.routePath),
        icon: const Icon(Icons.add),
        label: const Text('নতুন অনুরোধ'),
      ),
    );
  }

  static String _formatSubmitted(DateTime t) {
    final d = t.toLocal();
    return '${d.day}/${d.month}/${d.year}';
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
            child: Text('লোড হয়নি: $e', textAlign: TextAlign.center),
          ),
        ),
        data: (r) => ListView(
          padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 32),
          children: [
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

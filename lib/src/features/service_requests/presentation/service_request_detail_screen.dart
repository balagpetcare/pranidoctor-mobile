import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pranidoctor_mobile/src/app/screen_padding.dart';
import 'package:pranidoctor_mobile/src/core/constants/pd_spacing.dart';
import 'package:pranidoctor_mobile/src/core/widgets/pd_async_states.dart';
import 'package:pranidoctor_mobile/src/features/service_requests/application/service_requests_providers.dart';
import 'package:pranidoctor_mobile/src/features/service_requests/data/service_request_model.dart';
import 'package:pranidoctor_mobile/src/features/service_requests/data/service_request_repository.dart';
import 'package:pranidoctor_mobile/src/features/service_requests/domain/service_request_timeline.dart';
import 'package:pranidoctor_mobile/src/features/service_requests/presentation/widgets/assigned_provider_card.dart';
import 'package:pranidoctor_mobile/src/features/service_requests/presentation/widgets/request_placeholder_sections.dart';
import 'package:pranidoctor_mobile/src/features/service_requests/presentation/widgets/service_request_status_badge.dart';
import 'package:pranidoctor_mobile/src/features/service_requests/presentation/widgets/service_request_timeline_view.dart';

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
        loading: () => const PdLoadingBody(message: 'বিস্তারিত লোড হচ্ছে…'),
        error: (e, _) => Padding(
          padding: EdgeInsets.all(hPad),
          child: PdErrorBody(
            title: 'লোড হয়নি',
            message: '$e',
            retryLabel: 'আবার চেষ্টা করুন',
            onRetry: () =>
                ref.invalidate(serviceRequestDetailProvider(requestId)),
          ),
        ),
        data: (r) => ListView(
          padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 32),
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    r.serviceType.labelBn,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: PdSpacing.sm),
                ServiceRequestStatusBadge(status: r.status),
              ],
            ),
            const SizedBox(height: PdSpacing.lg),
            ServiceRequestTimelineView(steps: buildServiceRequestTimeline(r)),
            const SizedBox(height: PdSpacing.lg),
            if (_showDoctorCard(r)) ...[
              AssignedProviderCard(
                roleLabelBn: 'নিয়োজিত ডাক্তার',
                displayName: r.assignedDoctorDisplayName ?? 'ডাক্তার নিয়োজিত',
                phone: r.assignedDoctorPhone,
              ),
              const SizedBox(height: PdSpacing.sm),
            ],
            if (_showTechnicianCard(r)) ...[
              AssignedProviderCard(
                roleLabelBn: 'নিয়োজিত টেকনিশিয়ান',
                displayName:
                    r.assignedTechnicianDisplayName ?? 'টেকনিশিয়ান নিয়োজিত',
                phone: r.assignedTechnicianPhone,
              ),
              const SizedBox(height: PdSpacing.sm),
            ],
            if (r.animal != null)
              _DetailSection(
                title: 'পশু',
                body: '${r.animal!.name} (${r.animal!.species})',
              ),
            _DetailSection(
              title: 'ঠিকানা / অবস্থান',
              body: r.locationText?.trim().isNotEmpty == true
                  ? r.locationText!
                  : '—',
            ),
            _DetailSection(title: 'জরুরিতা', body: r.urgencyDisplayBn),
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
              title: 'পছন্দের সময়',
              body: r.preferredTime?.trim().isNotEmpty == true
                  ? r.preferredTime!
                  : '—',
            ),
            if (r.serviceCategory != null)
              _DetailSection(title: 'ক্যাটাগরি', body: r.serviceCategory!.name),
            if (r.isEmergency)
              _DetailSection(title: 'জরুরি অনুরোধ', body: 'হ্যাঁ'),
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
            _DetailSection(title: 'জমার সময়', body: _formatDt(r.submittedAt)),
            if (r.cancelledAt != null)
              _DetailSection(
                title: 'বাতিলের সময়',
                body: _formatDt(r.cancelledAt!),
              ),
            if (r.cancelReason?.trim().isNotEmpty == true)
              _DetailSection(title: 'বাতিলের কারণ', body: r.cancelReason!),
            const SizedBox(height: PdSpacing.md),
            const RequestPlaceholderSections(),
            if (r.canCustomerCancel) ...[
              const SizedBox(height: PdSpacing.xl),
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

  static bool _showDoctorCard(ServiceRequest r) {
    return (r.assignedDoctorId?.trim().isNotEmpty ?? false) ||
        r.assignedDoctor != null;
  }

  static bool _showTechnicianCard(ServiceRequest r) {
    return (r.assignedTechnicianId?.trim().isNotEmpty ?? false) ||
        r.assignedTechnician != null;
  }

  static String _formatDt(DateTime t) {
    final d = t.toLocal();
    return '${d.day}/${d.month}/${d.year}, ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pranidoctor_mobile/src/app/screen_padding.dart';
import 'package:pranidoctor_mobile/src/core/constants/pd_spacing.dart';
import 'package:pranidoctor_mobile/src/core/widgets/pd_async_states.dart';
import 'package:pranidoctor_mobile/src/features/doctor_workflow/application/doctor_workflow_providers.dart';
import 'package:pranidoctor_mobile/src/features/doctor_workflow/data/doctor_case_models.dart';
import 'package:pranidoctor_mobile/src/features/doctor_workflow/data/doctor_workflow_repository.dart';
import 'package:pranidoctor_mobile/src/features/doctor_workflow/presentation/doctor_complete_case_screen.dart';
import 'package:pranidoctor_mobile/src/features/doctor_workflow/presentation/doctor_prescription_screen.dart';
import 'package:pranidoctor_mobile/src/features/doctor_workflow/presentation/doctor_treatment_note_screen.dart';
import 'package:pranidoctor_mobile/src/features/doctor_workflow/presentation/widgets/doctor_workflow_badges.dart';

class DoctorCaseDetailScreen extends ConsumerWidget {
  const DoctorCaseDetailScreen({super.key, required this.caseId});

  final String caseId;

  static const routeName = 'doctorCaseDetail';

  static String routePathFor(String id) => '/doctor/cases/$id';

  static String _formatDt(DateTime t) {
    final d = t.toLocal();
    return '${d.day}/${d.month}/${d.year}, ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(doctorCaseDetailProvider(caseId));
    final hPad = pdScreenPadding(context).horizontal;

    return Scaffold(
      appBar: AppBar(
        title: const Text('কেস বিস্তারিত'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Center(child: DoctorModeChip()),
          ),
        ],
      ),
      body: async.when(
        loading: () => const PdLoadingBody(message: 'বিস্তারিত লোড হচ্ছে…'),
        error: (e, _) => Padding(
          padding: EdgeInsets.all(hPad),
          child: PdErrorBody(
            title: 'লোড হয়নি',
            message: '$e',
            retryLabel: 'আবার চেষ্টা করুন',
            onRetry: () => ref.invalidate(doctorCaseDetailProvider(caseId)),
          ),
        ),
        data: (d) => ListView(
          padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 32),
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    d.serviceTypeLabel?.trim().isNotEmpty == true
                        ? d.serviceTypeLabel!.trim()
                        : 'কেস',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: PdSpacing.sm),
            DoctorUrgencyBadges(
              isEmergency: d.isEmergency,
              priorityLabel: d.priorityLabel,
            ),
            const SizedBox(height: PdSpacing.lg),
            _DetailSection(title: 'অবস্থা', body: d.status),
            _DetailSection(
              title: 'গ্রাহকের তথ্য',
              body: d.customer.displayLineBn,
            ),
            _DetailSection(title: 'প্রাণীর তথ্য', body: d.animal.lineBn),
            _DetailSection(
              title: 'ঠিকানা / অবস্থান',
              body: d.locationText?.trim().isNotEmpty == true
                  ? d.locationText!.trim()
                  : '—',
            ),
            _DetailSection(
              title: 'সমস্যা / লক্ষণ',
              body: d.problemOrSymptom?.trim().isNotEmpty == true
                  ? d.problemOrSymptom!
                  : '—',
            ),
            _DetailSection(
              title: 'বিবরণ',
              body: d.description?.trim().isNotEmpty == true
                  ? d.description!
                  : '—',
            ),
            _DetailSection(
              title: 'পছন্দের সময়',
              body: d.preferredTime?.trim().isNotEmpty == true
                  ? d.preferredTime!
                  : '—',
            ),
            if (d.existingTreatmentNote?.trim().isNotEmpty == true)
              _DetailSection(
                title: 'চিকিৎসা নোট',
                body: d.existingTreatmentNote!,
              ),
            if (d.existingPrescriptionSummary?.trim().isNotEmpty == true)
              _DetailSection(
                title: 'প্রেসক্রিপশন',
                body: d.existingPrescriptionSummary!,
              ),
            if (d.submittedAt != null)
              _DetailSection(
                title: 'জমার সময়',
                body: _formatDt(d.submittedAt!),
              ),
            const SizedBox(height: PdSpacing.xl),
            if (d.canAcceptOrReject) ...[
              FilledButton.icon(
                onPressed: () => _confirmAccept(context, ref, d),
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('গ্রহণ করুন'),
              ),
              const SizedBox(height: PdSpacing.sm),
              OutlinedButton.icon(
                onPressed: () => _confirmReject(context, ref, d),
                icon: const Icon(Icons.cancel_outlined),
                label: const Text('প্রত্যাখ্যান করুন'),
              ),
              const SizedBox(height: PdSpacing.lg),
            ],
            if (d.canEditTreatment) ...[
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.medical_information_outlined),
                title: const Text('চিকিৎসা নোট'),
                subtitle: const Text('নোট যুক্ত বা আপডেট করুন'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(
                  DoctorTreatmentNoteScreen.routePathFor(d.caseId),
                ),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.medication_outlined),
                title: const Text('প্রেসক্রিপশন'),
                subtitle: const Text('প্রেসক্রিপশন তৈরি করুন'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(
                  DoctorPrescriptionScreen.routePathFor(d.caseId),
                ),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.task_alt_outlined),
                title: const Text('কেস সম্পন্ন করুন'),
                subtitle: const Text('চিকিৎসা শেষ হলে সম্পন্ন করুন'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(
                  DoctorCompleteCaseScreen.routePathFor(d.caseId),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static Future<void> _confirmAccept(
    BuildContext context,
    WidgetRef ref,
    DoctorCaseDetail d,
  ) async {
    final rid = d.effectiveRequestIdForAcceptReject;
    if (rid == null || rid.isEmpty) return;
    final go = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('গ্রহণ করবেন?'),
        content: const Text('এই অনুরোধ গ্রহণ করলে কেস আপনার নামে চলবে।'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('না'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('হ্যাঁ, গ্রহণ করুন'),
          ),
        ],
      ),
    );
    if (go != true || !context.mounted) return;
    try {
      await ref.read(doctorWorkflowRepositoryProvider).acceptRequest(rid);
      if (!context.mounted) return;
      ref.invalidate(doctorCaseDetailProvider(d.caseId));
      ref.invalidate(doctorIncomingRequestsProvider);
      ref.invalidate(doctorCasesListProvider);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('গ্রহণ করা হয়েছে')));
    } on DoctorWorkflowApiException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  static Future<void> _confirmReject(
    BuildContext context,
    WidgetRef ref,
    DoctorCaseDetail d,
  ) async {
    final rid = d.effectiveRequestIdForAcceptReject;
    if (rid == null || rid.isEmpty) return;
    final reasonCtrl = TextEditingController();
    try {
      final go = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('প্রত্যাখ্যান করবেন?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'এই অনুরোধ প্রত্যাখ্যান করা হলে আর গ্রহণ করা যাবে না।',
              ),
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
              child: const Text('প্রত্যাখ্যান করুন'),
            ),
          ],
        ),
      );
      if (go != true || !context.mounted) return;
      final reason = reasonCtrl.text.trim();
      try {
        await ref
            .read(doctorWorkflowRepositoryProvider)
            .rejectRequest(rid, reason: reason.isEmpty ? null : reason);
        if (!context.mounted) return;
        ref.invalidate(doctorCaseDetailProvider(d.caseId));
        ref.invalidate(doctorIncomingRequestsProvider);
        ref.invalidate(doctorCasesListProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('প্রত্যাখ্যান করা হয়েছে')),
        );
        context.pop();
      } on DoctorWorkflowApiException catch (e) {
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

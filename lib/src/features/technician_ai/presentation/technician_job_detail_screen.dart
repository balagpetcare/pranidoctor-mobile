import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pranidoctor_mobile/src/app/screen_padding.dart';
import 'package:pranidoctor_mobile/src/features/billing/presentation/widgets/provider_earning_summary_card.dart';
import 'package:pranidoctor_mobile/src/features/technician_ai/application/technician_job_providers.dart';
import 'package:pranidoctor_mobile/src/features/technician_ai/data/technician_api_exception.dart';
import 'package:pranidoctor_mobile/src/features/technician_ai/data/technician_job_models.dart';
import 'package:pranidoctor_mobile/src/features/technician_ai/presentation/technician_ai_record_form_screen.dart';
import 'package:pranidoctor_mobile/src/features/technician_ai/presentation/technician_complete_job_screen.dart';
import 'package:pranidoctor_mobile/src/features/technician_ai/presentation/widgets/technician_ai_widgets.dart';

class TechnicianJobDetailScreen extends ConsumerStatefulWidget {
  const TechnicianJobDetailScreen({super.key, required this.jobId});

  final String jobId;

  static const routeName = 'technicianJobDetail';

  static String pathFor(String id) => '/technician/jobs/$id';

  @override
  ConsumerState<TechnicianJobDetailScreen> createState() =>
      _TechnicianJobDetailScreenState();
}

class _TechnicianJobDetailScreenState
    extends ConsumerState<TechnicianJobDetailScreen> {
  bool _busy = false;

  Future<void> _guard(Future<void> Function() fn) async {
    setState(() => _busy = true);
    try {
      await fn();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _invalidateLists() {
    ref.invalidate(technicianRequestsListProvider);
    ref.invalidate(technicianJobsListProvider);
    ref.invalidate(technicianJobDetailProvider(widget.jobId));
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(technicianJobDetailProvider(widget.jobId));
    final hPad = pdScreenPadding(context).horizontal;

    return Scaffold(
      appBar: AppBar(
        title: const Text('কাজের বিবরণ'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 8),
            child: Center(child: TechnicianAiBadge(compact: true)),
          ),
        ],
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: EdgeInsets.all(hPad),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('লোড হয়নি: $e', textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () =>
                      ref.invalidate(technicianJobDetailProvider(widget.jobId)),
                  child: const Text('আবার চেষ্টা'),
                ),
              ],
            ),
          ),
        ),
        data: (job) => Stack(
          children: [
            ListView(
              padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 120),
              children: [
                TechnicianJobStatusCard(phase: job.phase),
                const SizedBox(height: 16),
                TechnicianAnimalCustomerSummary(
                  animal: job.animal,
                  customer: job.customer,
                ),
                const SizedBox(height: 16),
                _DetailSection(
                  title: 'সমস্যা / লক্ষণ',
                  body: job.problemOrSymptom?.trim().isNotEmpty == true
                      ? job.problemOrSymptom!
                      : '—',
                ),
                _DetailSection(
                  title: 'বিবরণ',
                  body: job.description?.trim().isNotEmpty == true
                      ? job.description!
                      : '—',
                ),
                _DetailSection(
                  title: 'ঠিকানা / অবস্থান',
                  body: job.locationText?.trim().isNotEmpty == true
                      ? job.locationText!
                      : '—',
                ),
                _DetailSection(
                  title: 'পছন্দের সময়',
                  body: job.preferredTime?.trim().isNotEmpty == true
                      ? job.preferredTime!
                      : '—',
                ),
                if (job.submittedAt != null)
                  _DetailSection(
                    title: 'জমার সময়',
                    body: _formatDt(job.submittedAt!),
                  ),
                if (job.assignedAt != null)
                  _DetailSection(
                    title: 'নিয়োগের সময়',
                    body: _formatDt(job.assignedAt!),
                  ),
                if (job.startedAt != null)
                  _DetailSection(
                    title: 'কাজ শুরু',
                    body: _formatDt(job.startedAt!),
                  ),
                if (job.completedAt != null)
                  _DetailSection(
                    title: 'সমাপ্তি',
                    body: _formatDt(job.completedAt!),
                  ),
                const SizedBox(height: 8),
                _PlaceholderSection(
                  title: 'ফলো-আপ রিমাইন্ডার',
                  body:
                      job.aiRecord?.followUpReminderNote?.trim().isNotEmpty ==
                          true
                      ? job.aiRecord!.followUpReminderNote!
                      : 'পরে অ্যাপে রিমাইন্ডার সংযুক্ত করা হবে।',
                ),
                _TechnicianBillingBlock(job: job),
              ],
            ),
            Positioned(
              left: hPad,
              right: hPad,
              bottom: 24,
              child: _ActionBar(
                busy: _busy,
                job: job,
                onAccept: () => _accept(context, job),
                onReject: () => _reject(context, job),
                onRecord: () => context.push(
                  TechnicianAiRecordFormScreen.pathFor(widget.jobId),
                ),
                onComplete: () => context.push(
                  TechnicianCompleteJobScreen.pathFor(widget.jobId),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDt(DateTime t) {
    final d = t.toLocal();
    return '${d.day}/${d.month}/${d.year}, ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _accept(BuildContext context, TechnicianJobDetail job) async {
    final go = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('গ্রহণ করবেন?'),
        content: const Text(
          'এই অনুরোধ গ্রহণ করলে এটি আপনার চলমান কাজের তালিকায় যাবে।',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('না'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('হ্যাঁ'),
          ),
        ],
      ),
    );
    if (go != true || !context.mounted) return;
    await _guard(() async {
      try {
        await ref.read(technicianJobRepositoryProvider).acceptJob(job.id);
        _invalidateLists();
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('গ্রহণ করা হয়েছে')));
        }
      } on TechnicianApiException catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(e.message)));
        }
      }
    });
  }

  Future<void> _reject(BuildContext context, TechnicianJobDetail job) async {
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
              const Text('কারণ (ঐচ্ছিক)'),
              const SizedBox(height: 8),
              TextField(
                controller: reasonCtrl,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'কারণ লিখুন',
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
              child: const Text('প্রত্যাখ্যান'),
            ),
          ],
        ),
      );
      if (go != true || !context.mounted) return;
      await _guard(() async {
        try {
          await ref
              .read(technicianJobRepositoryProvider)
              .rejectJob(
                job.id,
                reason: reasonCtrl.text.trim().isEmpty ? null : reasonCtrl.text,
              );
          _invalidateLists();
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('প্রত্যাখ্যান করা হয়েছে')),
            );
            context.pop();
          }
        } on TechnicianApiException catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(e.message)));
          }
        }
      });
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

class _PlaceholderSection extends StatelessWidget {
  const _PlaceholderSection({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      color: scheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 6),
            Text(
              body,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _TechnicianBillingBlock extends StatelessWidget {
  const _TechnicianBillingBlock({required this.job});

  final TechnicianJobDetail job;

  @override
  Widget build(BuildContext context) {
    final b = job.billing;
    final empty = b == null || b.isEmptyForProviderView;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ProviderEarningSummaryCard(
          summary: empty ? null : b,
          isEmpty: empty,
          footerNote: job.aiRecord?.billingNote,
        ),
      ],
    );
  }
}

class _ActionBar extends StatelessWidget {
  const _ActionBar({
    required this.busy,
    required this.job,
    required this.onAccept,
    required this.onReject,
    required this.onRecord,
    required this.onComplete,
  });

  final bool busy;
  final TechnicianJobDetail job;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final VoidCallback onRecord;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(16),
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (busy) const LinearProgressIndicator(minHeight: 3),
            if (busy) const SizedBox(height: 8),
            if (job.canAccept)
              FilledButton(
                onPressed: busy ? null : onAccept,
                child: const Text('গ্রহণ করুন'),
              ),
            if (job.canAccept) const SizedBox(height: 8),
            if (job.canReject)
              OutlinedButton(
                onPressed: busy ? null : onReject,
                child: const Text('প্রত্যাখ্যান'),
              ),
            if (job.canReject) const SizedBox(height: 8),
            if (job.canEditRecord)
              FilledButton.tonal(
                onPressed: busy ? null : onRecord,
                child: const Text('AI সেবার রেকর্ড'),
              ),
            if (job.canEditRecord) const SizedBox(height: 8),
            if (job.canComplete)
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.tertiary,
                  foregroundColor: Theme.of(context).colorScheme.onTertiary,
                ),
                onPressed: busy ? null : onComplete,
                child: const Text('সেবা সম্পন্ন করুন'),
              ),
          ],
        ),
      ),
    );
  }
}

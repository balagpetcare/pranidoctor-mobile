import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pranidoctor_mobile/src/app/screen_padding.dart';
import 'package:pranidoctor_mobile/src/features/technician_ai/application/technician_job_providers.dart';
import 'package:pranidoctor_mobile/src/features/technician_ai/data/technician_api_exception.dart';
import 'package:pranidoctor_mobile/src/features/technician_ai/presentation/widgets/technician_ai_widgets.dart';

class TechnicianCompleteJobScreen extends ConsumerStatefulWidget {
  const TechnicianCompleteJobScreen({super.key, required this.jobId});

  final String jobId;

  static String pathFor(String jobId) => '/technician/jobs/$jobId/complete';

  @override
  ConsumerState<TechnicianCompleteJobScreen> createState() =>
      _TechnicianCompleteJobScreenState();
}

class _TechnicianCompleteJobScreenState
    extends ConsumerState<TechnicianCompleteJobScreen> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(technicianJobDetailProvider(widget.jobId));
    final hPad = pdScreenPadding(context).horizontal;

    return Scaffold(
      appBar: AppBar(
        title: const Text('সেবা সম্পন্ন'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 8),
            child: Center(child: TechnicianAiBadge(compact: true)),
          ),
        ],
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('লোড হয়নি: $e')),
        data: (job) {
          final rec = job.aiRecord;
          return ListView(
            padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 32),
            children: [
              TechnicianAnimalCustomerSummary(
                animal: job.animal,
                customer: job.customer,
              ),
              const SizedBox(height: 16),
              if (rec != null) ...[
                Text(
                  'AI রেকর্ড সারাংশ',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                _Line('প্রজাতি', rec.animalType ?? '—'),
                _Line('জাত', rec.breed ?? '—'),
                _Line('বীজ / ধরন', rec.semenOrBreedTypeNote ?? '—'),
                if (rec.servicePerformedAt != null)
                  _Line('সেবার সময়', _formatDt(rec.servicePerformedAt!)),
                _Line('নোট', rec.technicianNote ?? '—'),
              ] else
                Text(
                  'কোনো রেকর্ড নেই — আগে AI সেবার রেকর্ড সংরক্ষণ করুন।',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Text(
                    'ফলো-আপ ও বিলিং পরে অ্যাপে সম্পূর্ণ করা হবে। এখন শুধু সেবা সমাপ্তি চিহ্নিত করা হচ্ছে।',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: (!job.canComplete || _busy)
                    ? null
                    : () async {
                        final go = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('নিশ্চিত করবেন?'),
                            content: const Text(
                              'এই কাজটি সম্পন্ন হিসেবে চিহ্নিত করা হবে। পরে আর সম্পাদনা করা যাবে না।',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text('না'),
                              ),
                              FilledButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                child: const Text('হ্যাঁ, সম্পন্ন'),
                              ),
                            ],
                          ),
                        );
                        if (go != true || !context.mounted) return;
                        setState(() => _busy = true);
                        try {
                          await ref
                              .read(technicianJobRepositoryProvider)
                              .completeJob(job.id);
                          ref.invalidate(
                            technicianJobDetailProvider(widget.jobId),
                          );
                          ref.invalidate(technicianJobsListProvider);
                          ref.invalidate(technicianRequestsListProvider);
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('সেবা সম্পন্ন হয়েছে'),
                            ),
                          );
                          context.pop();
                        } on TechnicianApiException catch (e) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text(e.message)));
                        } finally {
                          if (mounted) setState(() => _busy = false);
                        }
                      },
                child: _busy
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('সম্পন্ন চিহ্নিত করুন'),
              ),
            ],
          );
        },
      ),
    );
  }

  String _formatDt(DateTime t) {
    final d = t.toLocal();
    return '${d.day}/${d.month}/${d.year}, ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }
}

class _Line extends StatelessWidget {
  const _Line(this.title, this.body);

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              title,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(child: Text(body)),
        ],
      ),
    );
  }
}

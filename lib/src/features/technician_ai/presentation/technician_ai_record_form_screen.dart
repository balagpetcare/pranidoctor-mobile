import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pranidoctor_mobile/src/app/screen_padding.dart';
import 'package:pranidoctor_mobile/src/features/technician_ai/application/technician_job_providers.dart';
import 'package:pranidoctor_mobile/src/features/technician_ai/data/technician_api_exception.dart';
import 'package:pranidoctor_mobile/src/features/technician_ai/data/technician_job_models.dart';
import 'package:pranidoctor_mobile/src/features/technician_ai/presentation/widgets/technician_ai_widgets.dart';

class TechnicianAiRecordFormScreen extends ConsumerStatefulWidget {
  const TechnicianAiRecordFormScreen({super.key, required this.jobId});

  final String jobId;

  static String pathFor(String jobId) => '/technician/jobs/$jobId/record';

  @override
  ConsumerState<TechnicianAiRecordFormScreen> createState() =>
      _TechnicianAiRecordFormScreenState();
}

class _TechnicianAiRecordFormScreenState
    extends ConsumerState<TechnicianAiRecordFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _defaultsApplied = false;
  late final TextEditingController _animalType;
  late final TextEditingController _breed;
  late final TextEditingController _semen;
  late final TextEditingController _note;
  late final TextEditingController _followUp;
  late final TextEditingController _billing;
  DateTime? _serviceAt;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _animalType = TextEditingController();
    _breed = TextEditingController();
    _semen = TextEditingController();
    _note = TextEditingController();
    _followUp = TextEditingController();
    _billing = TextEditingController();
  }

  @override
  void dispose() {
    _animalType.dispose();
    _breed.dispose();
    _semen.dispose();
    _note.dispose();
    _followUp.dispose();
    _billing.dispose();
    super.dispose();
  }

  void _applyJobDefaults(TechnicianJobDetail job) {
    final a = job.animal;
    if (_animalType.text.isEmpty && a?.species != null) {
      _animalType.text = a!.species!;
    }
    if (_breed.text.isEmpty && a?.breed != null) {
      _breed.text = a!.breed!;
    }
    _serviceAt ??= job.aiRecord?.servicePerformedAt ?? DateTime.now();
    if (_note.text.isEmpty && job.aiRecord?.technicianNote != null) {
      _note.text = job.aiRecord!.technicianNote!;
    }
    if (_semen.text.isEmpty && job.aiRecord?.semenOrBreedTypeNote != null) {
      _semen.text = job.aiRecord!.semenOrBreedTypeNote!;
    }
    if (_followUp.text.isEmpty && job.aiRecord?.followUpReminderNote != null) {
      _followUp.text = job.aiRecord!.followUpReminderNote!;
    }
    if (_billing.text.isEmpty && job.aiRecord?.billingNote != null) {
      _billing.text = job.aiRecord!.billingNote!;
    }
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 1),
      initialDate: _serviceAt ?? now,
    );
    if (d == null || !mounted) return;
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_serviceAt ?? now),
    );
    if (t == null || !mounted) return;
    setState(() {
      _serviceAt = DateTime(d.year, d.month, d.day, t.hour, t.minute);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final at = _serviceAt;
    if (at == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('সেবার তারিখ ও সময় নির্বাচন করুন')),
      );
      return;
    }
    setState(() => _submitting = true);
    try {
      final input = TechnicianAiRecordInput(
        animalType: _animalType.text,
        breed: _breed.text,
        semenOrBreedTypeNote: _semen.text,
        servicePerformedAt: at,
        technicianNote: _note.text,
        followUpReminderNote: _followUp.text,
        billingNote: _billing.text,
      );
      await ref
          .read(technicianJobRepositoryProvider)
          .saveAiRecord(widget.jobId, input);
      ref.invalidate(technicianJobDetailProvider(widget.jobId));
      ref.invalidate(technicianJobsListProvider);
      ref.invalidate(technicianRequestsListProvider);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('রেকর্ড সংরক্ষিত হয়েছে')));
        context.pop();
      }
    } on TechnicianApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(technicianJobDetailProvider(widget.jobId));
    final hPad = pdScreenPadding(context).horizontal;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI সেবার রেকর্ড'),
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
          if (!_defaultsApplied) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              _applyJobDefaults(job);
              setState(() => _defaultsApplied = true);
            });
          }
          return Form(
            key: _formKey,
            child: ListView(
              padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 32),
              children: [
                TechnicianAnimalCustomerSummary(
                  animal: job.animal,
                  customer: job.customer,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _animalType,
                  decoration: const InputDecoration(
                    labelText: 'প্রাণীর ধরন / প্রজাতি *',
                    hintText: 'যেমন: গরু, ছাগল',
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'প্রয়োজনীয়' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _breed,
                  decoration: const InputDecoration(labelText: 'জাত *'),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'প্রয়োজনীয়' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _semen,
                  decoration: const InputDecoration(
                    labelText: 'বীজ / স্ট্র / ধরন (প্লেসহোল্ডার)',
                    hintText: 'পরে কোড বা স্ট্র আইডি সংযুক্ত হবে',
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('সেবার তারিখ ও সময় *'),
                  subtitle: Text(
                    _serviceAt == null
                        ? 'নির্বাচন করুন'
                        : _formatDt(_serviceAt!),
                  ),
                  trailing: const Icon(Icons.event),
                  onTap: _submitting ? null : _pickDateTime,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _note,
                  decoration: const InputDecoration(
                    labelText: 'টেকনিশিয়ানের নোট *',
                  ),
                  maxLines: 4,
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'প্রয়োজনীয়' : null,
                ),
                const SizedBox(height: 16),
                Text(
                  'ফলো-আপ রিমাইন্ডার (প্লেসহোল্ডার)',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _followUp,
                  decoration: const InputDecoration(
                    hintText: 'যেমন: ২১ দিন পর পরীক্ষা',
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                Text(
                  'পেমেন্ট / বিলিং (প্লেসহোল্ডার)',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _billing,
                  decoration: const InputDecoration(
                    hintText: 'বিলিং পরে নিশ্চিত করা হবে',
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 28),
                FilledButton(
                  onPressed: _submitting ? null : _submit,
                  child: _submitting
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('সংরক্ষণ করুন'),
                ),
              ],
            ),
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

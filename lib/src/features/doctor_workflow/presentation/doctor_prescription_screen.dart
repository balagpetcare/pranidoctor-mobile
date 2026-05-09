import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pranidoctor_mobile/src/app/screen_padding.dart';
import 'package:pranidoctor_mobile/src/core/constants/pd_spacing.dart';
import 'package:pranidoctor_mobile/src/core/widgets/pd_text_field.dart';
import 'package:pranidoctor_mobile/src/features/doctor_workflow/application/doctor_workflow_providers.dart';
import 'package:pranidoctor_mobile/src/features/doctor_workflow/data/doctor_workflow_repository.dart';
import 'package:pranidoctor_mobile/src/features/doctor_workflow/presentation/widgets/doctor_workflow_badges.dart';

class DoctorPrescriptionScreen extends ConsumerStatefulWidget {
  const DoctorPrescriptionScreen({super.key, required this.caseId});

  final String caseId;

  static const routeName = 'doctorPrescription';

  static String routePathFor(String caseId) =>
      '/doctor/cases/$caseId/prescription';

  @override
  ConsumerState<DoctorPrescriptionScreen> createState() =>
      _DoctorPrescriptionScreenState();
}

class _DoctorPrescriptionScreenState
    extends ConsumerState<DoctorPrescriptionScreen> {
  final _instructions = TextEditingController();
  final _lines = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _instructions.dispose();
    _lines.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final inst = _instructions.text.trim();
    final lines = _lines.text.trim();
    if (inst.isEmpty && lines.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('প্রেসক্রিপশনের বিষয়বস্তু লিখুন।')),
      );
      return;
    }
    setState(() => _submitting = true);
    try {
      await ref
          .read(doctorWorkflowRepositoryProvider)
          .savePrescription(widget.caseId, {
            if (inst.isNotEmpty) 'instructions': inst,
            if (lines.isNotEmpty) 'lines': lines,
            if (lines.isNotEmpty) 'prescriptionText': lines,
            if (inst.isNotEmpty && lines.isEmpty) 'prescriptionText': inst,
          });
      if (!mounted) return;
      ref.invalidate(doctorCaseDetailProvider(widget.caseId));
      ref.invalidate(doctorCasesListProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('প্রেসক্রিপশন সংরক্ষিত হয়েছে')),
      );
      context.pop();
    } on DoctorWorkflowApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pad = pdScreenPadding(context);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('প্রেসক্রিপশন'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Center(child: DoctorModeChip()),
          ),
        ],
      ),
      body: ListView(
        padding: pad.copyWith(top: 16, bottom: 32),
        children: [
          Text(
            'ঔষধ ও খাবারের নির্দেশনা স্পষ্টভাবে লিখুন।',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: PdSpacing.lg),
          PdTextField(
            controller: _instructions,
            labelText: 'নির্দেশনা',
            hintText: 'খাওয়ার সময়, মাত্রা…',
            maxLines: 3,
            enabled: !_submitting,
          ),
          const SizedBox(height: PdSpacing.md),
          PdTextField(
            controller: _lines,
            labelText: 'ঔষধের তালিকা',
            hintText: 'প্রতি লাইনে একটি ঔষধ',
            maxLines: 10,
            enabled: !_submitting,
          ),
          const SizedBox(height: PdSpacing.xl),
          FilledButton(
            onPressed: _submitting ? null : _submit,
            child: _submitting
                ? SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: scheme.onPrimary,
                    ),
                  )
                : const Text('সংরক্ষণ করুন'),
          ),
        ],
      ),
    );
  }
}

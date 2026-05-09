import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pranidoctor_mobile/src/app/screen_padding.dart';
import 'package:pranidoctor_mobile/src/core/constants/pd_spacing.dart';
import 'package:pranidoctor_mobile/src/core/widgets/pd_text_field.dart';
import 'package:pranidoctor_mobile/src/features/doctor_workflow/application/doctor_workflow_providers.dart';
import 'package:pranidoctor_mobile/src/features/doctor_workflow/data/doctor_workflow_repository.dart';
import 'package:pranidoctor_mobile/src/features/doctor_workflow/presentation/widgets/doctor_workflow_badges.dart';

class DoctorTreatmentNoteScreen extends ConsumerStatefulWidget {
  const DoctorTreatmentNoteScreen({super.key, required this.caseId});

  final String caseId;

  static const routeName = 'doctorTreatmentNote';

  static String routePathFor(String caseId) =>
      '/doctor/cases/$caseId/treatment';

  @override
  ConsumerState<DoctorTreatmentNoteScreen> createState() =>
      _DoctorTreatmentNoteScreenState();
}

class _DoctorTreatmentNoteScreenState
    extends ConsumerState<DoctorTreatmentNoteScreen> {
  final _notes = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final text = _notes.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('চিকিৎসা নোট লিখুন।')));
      return;
    }
    setState(() => _submitting = true);
    try {
      await ref.read(doctorWorkflowRepositoryProvider).saveTreatmentNote(
        widget.caseId,
        {'treatmentNotes': text, 'notes': text},
      );
      if (!mounted) return;
      ref.invalidate(doctorCaseDetailProvider(widget.caseId));
      ref.invalidate(doctorCasesListProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('চিকিৎসা নোট সংরক্ষিত হয়েছে')),
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
        title: const Text('চিকিৎসা নোট'),
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
            'রোগী ও চিকিৎসার গুরুত্বপূর্ণ তথ্য লিখুন।',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: PdSpacing.lg),
          PdTextField(
            controller: _notes,
            labelText: 'চিকিৎসা নোট',
            hintText: 'লক্ষণ, পরীক্ষা, পরামর্শ…',
            maxLines: 8,
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

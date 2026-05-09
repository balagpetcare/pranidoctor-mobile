import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pranidoctor_mobile/src/app/screen_padding.dart';
import 'package:pranidoctor_mobile/src/core/constants/pd_spacing.dart';
import 'package:pranidoctor_mobile/src/core/widgets/pd_text_field.dart';
import 'package:pranidoctor_mobile/src/features/doctor_workflow/application/doctor_workflow_providers.dart';
import 'package:pranidoctor_mobile/src/features/doctor_workflow/data/doctor_workflow_repository.dart';
import 'package:pranidoctor_mobile/src/features/doctor_workflow/presentation/widgets/doctor_workflow_badges.dart';

class DoctorCompleteCaseScreen extends ConsumerStatefulWidget {
  const DoctorCompleteCaseScreen({super.key, required this.caseId});

  final String caseId;

  static const routeName = 'doctorCompleteCase';

  static String routePathFor(String caseId) => '/doctor/cases/$caseId/complete';

  @override
  ConsumerState<DoctorCompleteCaseScreen> createState() =>
      _DoctorCompleteCaseScreenState();
}

class _DoctorCompleteCaseScreenState
    extends ConsumerState<DoctorCompleteCaseScreen> {
  final _summary = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _summary.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final go = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('কেস সম্পন্ন করবেন?'),
        content: const Text(
          'সম্পন্ন করার পর এই কেস সক্রিয় তালিকায় আর থাকবে না (ব্যাকএন্ড নিয়ম অনুযায়ী)।',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('না'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('হ্যাঁ, সম্পন্ন করুন'),
          ),
        ],
      ),
    );
    if (go != true || !mounted) return;

    setState(() => _submitting = true);
    try {
      final note = _summary.text.trim();
      await ref
          .read(doctorWorkflowRepositoryProvider)
          .completeCase(
            widget.caseId,
            body: note.isEmpty ? null : {'summaryNote': note, 'notes': note},
          );
      if (!mounted) return;
      ref.invalidate(doctorCaseDetailProvider(widget.caseId));
      ref.invalidate(doctorCasesListProvider);
      ref.invalidate(doctorIncomingRequestsProvider);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('কেস সম্পন্ন করা হয়েছে')));
      context.pop();
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
        title: const Text('কেস সম্পন্ন করুন'),
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
            'চিকিৎসা শেষ হলে নিচের বোতামে সম্পন্ন করুন। ঐচ্ছিক সারাংশ লিখতে পারেন।',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: PdSpacing.lg),
          PdTextField(
            controller: _summary,
            labelText: 'সারাংশ (ঐচ্ছিক)',
            hintText: 'চূড়ান্ত পর্যবেক্ষণ…',
            maxLines: 4,
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
                : const Text('কেস সম্পন্ন করুন'),
          ),
        ],
      ),
    );
  }
}

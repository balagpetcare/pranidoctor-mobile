import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_section_header.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/presentation/ai_technician_application_form_screen.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/presentation/ai_technician_application_status_screen.dart';
import 'package:pranidoctor_mobile/src/features/professional_profile/domain/professional_persona.dart';
import 'package:pranidoctor_mobile/src/features/professional_verification/application/professional_verification_providers.dart';
import 'package:pranidoctor_mobile/src/features/professional_verification/domain/verification_workflow_phase.dart';
import 'package:pranidoctor_mobile/src/features/professional_verification/presentation/widgets/verification_audit_timeline.dart';
import 'package:pranidoctor_mobile/src/features/professional_verification/presentation/widgets/verification_document_review_list.dart';
import 'package:pranidoctor_mobile/src/features/professional_verification/presentation/widgets/verification_phase_badge.dart';
import 'package:pranidoctor_mobile/src/features/professional_verification/presentation/widgets/verification_rejection_banner.dart';

/// Enterprise verification panel (profile section + standalone screen).
class ProfessionalVerificationWorkflowPanel extends ConsumerStatefulWidget {
  const ProfessionalVerificationWorkflowPanel({super.key, required this.persona});

  final ProfessionalPersona persona;

  @override
  ConsumerState<ProfessionalVerificationWorkflowPanel> createState() =>
      _ProfessionalVerificationWorkflowPanelState();
}

class _ProfessionalVerificationWorkflowPanelState
    extends ConsumerState<ProfessionalVerificationWorkflowPanel> {
  VerificationWorkflowPhase? _prevPhase;
  String? _lastFingerprint;

  @override
  Widget build(BuildContext context) {
    final snap = ref.watch(professionalVerificationWorkflowProvider(widget.persona));
    final auditAsync =
        ref.watch(professionalVerificationAuditTrailProvider(widget.persona));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (snap.auditFingerprint == _lastFingerprint) return;
      _lastFingerprint = snap.auditFingerprint;
      unawaited(
        recordVerificationAuditProjection(
          persona: widget.persona,
          snap: snap,
          previousPhase: _prevPhase,
        ),
      );
      _prevPhase = snap.phase;
      ref.invalidate(professionalVerificationAuditTrailProvider(widget.persona));
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'যাচাই ও অনুমোদন',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ),
            VerificationPhaseBadge(phase: snap.phase),
          ],
        ),
        const SizedBox(height: PraniSpacing.sm),
        Text(
          'অ্যাডমিন রিভিউ প্রস্তুত স্ট্রাকচার — স্থানীয় অডিট + সার্ভার স্ট্যাটাস।',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
        ),
        if (snap.rawApplicationStatus != null &&
            snap.rawApplicationStatus!.trim().isNotEmpty) ...[
          const SizedBox(height: PraniSpacing.sm),
          Text(
            'API স্ট্যাটাস: ${snap.rawApplicationStatus}',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
        ],
        if (snap.rawProviderStatus != null &&
            snap.rawProviderStatus!.trim().isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            'প্রদানকারী স্ট্যাটাস: ${snap.rawProviderStatus}',
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ],
        const SizedBox(height: PraniSpacing.lg),
        VerificationRejectionBanner(
          phase: snap.phase,
          message: snap.rejectionOrCorrectionText,
          canResubmit: snap.canResubmit,
          onResubmit: widget.persona == ProfessionalPersona.aiTechnician
              ? () => context.push(AiTechnicianApplicationFormScreen.routePath)
              : null,
        ),
        const SizedBox(height: PraniSpacing.lg),
        if (widget.persona == ProfessionalPersona.aiTechnician) ...[
          VerificationDocumentReviewList(rows: snap.documentRows),
          const SizedBox(height: PraniSpacing.lg),
        ],
        const PraniSectionHeader(
          title: 'কার্যপ্রবাহ',
          subtitle: 'খসড়া → জমা → যাচাই → অনুমোদন',
          leadingIcon: Icons.account_tree_outlined,
        ),
        const SizedBox(height: PraniSpacing.md),
        Wrap(
          spacing: PraniSpacing.sm,
          runSpacing: PraniSpacing.sm,
          children: [
            for (final p in VerificationWorkflowPhase.values)
              VerificationPhaseBadge(phase: p, compact: true),
          ],
        ),
        const SizedBox(height: PraniSpacing.xl),
        auditAsync.when(
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(PraniSpacing.lg),
              child: CircularProgressIndicator.adaptive(),
            ),
          ),
          error: (e, _) => Text('অডিট লোড ব্যর্থ: $e'),
          data: (entries) => VerificationAuditTimeline(entries: entries),
        ),
        const SizedBox(height: PraniSpacing.lg),
        if (widget.persona == ProfessionalPersona.aiTechnician)
          OutlinedButton.icon(
            onPressed: () =>
                context.push(AiTechnicianApplicationStatusScreen.routePath),
            icon: const Icon(Icons.open_in_new_outlined),
            label: const Text('সম্পূর্ণ স্ট্যাটাস স্ক্রিন'),
          ),
      ],
    );
  }
}

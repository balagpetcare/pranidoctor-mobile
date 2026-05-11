import 'package:flutter/material.dart';

import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';
import 'package:pranidoctor_mobile/src/features/professional_verification/domain/verification_workflow_phase.dart';

class VerificationPhaseBadge extends StatelessWidget {
  const VerificationPhaseBadge({
    super.key,
    required this.phase,
    this.compact = false,
  });

  final VerificationWorkflowPhase phase;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = phase.toneColor(scheme).withValues(alpha: 0.18);
    final fg = phase.toneColor(scheme);
    return Chip(
      avatar: Icon(Icons.verified_outlined, size: compact ? 16 : 18, color: fg),
      label: Text(
        phase.labelBn,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: fg,
              fontWeight: FontWeight.w800,
            ),
      ),
      backgroundColor: bg,
      side: BorderSide(color: fg.withValues(alpha: 0.35)),
      padding: EdgeInsets.symmetric(
        horizontal: compact ? PraniSpacing.sm : PraniSpacing.md,
        vertical: compact ? 0 : 2,
      ),
    );
  }
}

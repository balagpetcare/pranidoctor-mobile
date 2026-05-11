import 'package:flutter/material.dart';

/// Enterprise verification phases (COMMAND 6) — aligned with admin review pipeline.
enum VerificationWorkflowPhase {
  draft,
  submitted,
  underReview,
  verified,
  rejected,
  suspended,
}

extension VerificationWorkflowPhaseUi on VerificationWorkflowPhase {
  String get labelBn => switch (this) {
        VerificationWorkflowPhase.draft => 'খসড়া',
        VerificationWorkflowPhase.submitted => 'জমা হয়েছে',
        VerificationWorkflowPhase.underReview => 'যাচাই চলছে',
        VerificationWorkflowPhase.verified => 'যাচাইকৃত',
        VerificationWorkflowPhase.rejected => 'প্রত্যাখ্যাত',
        VerificationWorkflowPhase.suspended => 'স্থগিত',
      };

  Color toneColor(ColorScheme scheme) => switch (this) {
        VerificationWorkflowPhase.draft => scheme.outline,
        VerificationWorkflowPhase.submitted => scheme.secondary,
        VerificationWorkflowPhase.underReview => scheme.tertiary,
        VerificationWorkflowPhase.verified => scheme.primary,
        VerificationWorkflowPhase.rejected => scheme.error,
        VerificationWorkflowPhase.suspended => scheme.errorContainer,
      };
}

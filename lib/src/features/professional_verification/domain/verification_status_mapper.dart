import 'package:pranidoctor_mobile/src/features/professional_verification/domain/verification_workflow_phase.dart';

/// Maps Prisma / mobile API status strings into [VerificationWorkflowPhase].
VerificationWorkflowPhase mapApiStatusToVerificationPhase(String? raw) {
  final s = raw?.trim().toUpperCase() ?? '';
  if (s.isEmpty) return VerificationWorkflowPhase.draft;

  switch (s) {
    case 'DRAFT':
      return VerificationWorkflowPhase.draft;
    case 'SUBMITTED':
      return VerificationWorkflowPhase.submitted;
    case 'UNDER_REVIEW':
    case 'PENDING_VERIFICATION':
    case 'PENDING_REVIEW':
      return VerificationWorkflowPhase.underReview;
    case 'APPROVED':
    case 'PUBLISHED':
    case 'VERIFIED':
    case 'ACTIVE':
      return VerificationWorkflowPhase.verified;
    case 'REJECTED':
      return VerificationWorkflowPhase.rejected;
    case 'SUSPENDED':
    case 'INACTIVE':
      return VerificationWorkflowPhase.suspended;
    case 'NEEDS_CORRECTION':
    case 'NEEDS_MORE_INFO':
      // User may edit and resubmit — treat as draft bucket for badges + resubmit UX.
      return VerificationWorkflowPhase.draft;
    default:
      return VerificationWorkflowPhase.draft;
  }
}

bool verificationPhaseAllowsResubmit(
  VerificationWorkflowPhase phase,
  String? rawApi,
) {
  final r = rawApi?.trim().toUpperCase() ?? '';
  if (r == 'REJECTED' || r == 'SUSPENDED') return false;
  if (phase == VerificationWorkflowPhase.rejected) return false;
  if (phase == VerificationWorkflowPhase.suspended) return false;
  if (phase == VerificationWorkflowPhase.verified) return false;
  return r == 'DRAFT' || r == 'NEEDS_CORRECTION' || r == 'NEEDS_MORE_INFO';
}

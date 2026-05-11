import 'package:pranidoctor_mobile/src/features/ai_technician_application/data/ai_technician_models.dart';
import 'package:pranidoctor_mobile/src/features/professional_profile/domain/professional_persona.dart';
import 'package:pranidoctor_mobile/src/features/professional_verification/domain/verification_status_mapper.dart';
import 'package:pranidoctor_mobile/src/features/professional_verification/domain/verification_workflow_phase.dart';
import 'package:pranidoctor_mobile/src/features/profile/data/dashboard_context_models.dart';

/// Per-document review row for admin-ready UI (maps API `reviewStatus`).
class VerificationDocumentReviewRow {
  const VerificationDocumentReviewRow({
    required this.documentId,
    required this.typeCode,
    required this.title,
    required this.reviewStatus,
  });

  final String documentId;
  final String typeCode;
  final String title;
  final String reviewStatus;

  String get reviewLabelBn {
    switch (reviewStatus.trim().toUpperCase()) {
      case 'APPROVED':
      case 'VERIFIED':
        return 'অনুমোদিত';
      case 'REJECTED':
        return 'প্রত্যাখ্যাত';
      case 'PENDING_REVIEW':
      case 'PENDING':
      default:
        return 'যাচাই অপেক্ষমাণ';
    }
  }
}

/// Aggregated verification view for UI + audit fingerprinting.
class VerificationWorkflowSnapshot {
  const VerificationWorkflowSnapshot({
    required this.persona,
    required this.phase,
    required this.rawApplicationStatus,
    this.rawProviderStatus,
    this.rejectionOrCorrectionText,
    this.adminNote,
    this.documentRows = const [],
  });

  final ProfessionalPersona persona;
  final VerificationWorkflowPhase phase;
  final String? rawApplicationStatus;
  final String? rawProviderStatus;
  final String? rejectionOrCorrectionText;
  final String? adminNote;
  final List<VerificationDocumentReviewRow> documentRows;

  bool get canResubmit =>
      verificationPhaseAllowsResubmit(phase, rawApplicationStatus);

  /// Stable key for local audit dedupe until server sends canonical history.
  String get auditFingerprint =>
      '${persona.name}|${phase.name}|${rawApplicationStatus ?? ''}|'
      '${rawProviderStatus ?? ''}|${rejectionOrCorrectionText ?? ''}|'
      '${documentRows.map((d) => '${d.documentId}:${d.reviewStatus}').join(';')}';
}

VerificationWorkflowSnapshot buildVerificationWorkflowSnapshot({
  required ProfessionalPersona persona,
  required DashboardContext dashboard,
  AiTechnicianProfile? technicianProfile,
}) {
  if (persona == ProfessionalPersona.aiTechnician) {
    final fromDash = dashboard.aiTechnician;
    final fromProfile = technicianProfile;
    final raw = (fromProfile?.status ?? fromDash?.status)?.trim();
    final phase = mapApiStatusToVerificationPhase(raw);
    final prov = fromProfile?.providerStatus ?? '';
    final correction = fromProfile?.correctionNote?.trim();
    final admin = fromProfile?.adminNote?.trim();
    final rejectText = (correction != null && correction.isNotEmpty)
        ? correction
        : (phase == VerificationWorkflowPhase.rejected &&
                admin != null &&
                admin.isNotEmpty)
            ? admin
            : null;

    final docs = fromProfile?.documents ?? const <AiTechnicianDocument>[];
    final rows = docs
        .map(
          (d) => VerificationDocumentReviewRow(
            documentId: d.id,
            typeCode: d.type,
            title: d.title,
            reviewStatus: d.reviewStatus,
          ),
        )
        .toList();

    return VerificationWorkflowSnapshot(
      persona: persona,
      phase: phase,
      rawApplicationStatus: raw,
      rawProviderStatus: prov.isEmpty ? null : prov,
      rejectionOrCorrectionText: rejectText,
      adminNote: admin,
      documentRows: rows,
    );
  }

  final doc = dashboard.doctor;
  final raw = doc?.verificationStatus?.trim();
  final phase = mapApiStatusToVerificationPhase(raw);
  final reason = doc?.verificationRejectionReason?.trim();
  return VerificationWorkflowSnapshot(
    persona: persona,
    phase: raw == null || raw.isEmpty ? VerificationWorkflowPhase.draft : phase,
    rawApplicationStatus: raw,
    rawProviderStatus: null,
    rejectionOrCorrectionText: reason?.isNotEmpty == true ? reason : null,
    adminNote: null,
    documentRows: const [],
  );
}

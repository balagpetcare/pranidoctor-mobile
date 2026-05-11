import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pranidoctor_mobile/src/features/ai_technician_application/application/ai_technician_providers.dart';
import 'package:pranidoctor_mobile/src/features/professional_profile/domain/professional_persona.dart';
import 'package:pranidoctor_mobile/src/features/professional_verification/application/verification_workflow_snapshot.dart';
import 'package:pranidoctor_mobile/src/features/professional_verification/data/verification_audit_entry.dart';
import 'package:pranidoctor_mobile/src/features/professional_verification/data/verification_audit_store.dart';
import 'package:pranidoctor_mobile/src/features/professional_verification/domain/verification_notification_event.dart';
import 'package:pranidoctor_mobile/src/features/professional_verification/domain/verification_workflow_phase.dart';
import 'package:pranidoctor_mobile/src/features/profile/application/profile_dashboard_providers.dart';

/// Live verification projection (dashboard + optional `me` profile for documents).
final professionalVerificationWorkflowProvider = Provider.autoDispose
    .family<VerificationWorkflowSnapshot, ProfessionalPersona>((ref, persona) {
  final dash = ref.watch(profileDashboardContextProvider);
  return switch (dash) {
    AsyncData(:final value) => buildVerificationWorkflowSnapshot(
        persona: persona,
        dashboard: value,
        technicianProfile: switch (persona) {
          ProfessionalPersona.aiTechnician => switch (ref.watch(
                aiTechnicianMeProvider,
              )) {
              AsyncData(:final value) => value.profile,
              _ => null,
            },
          ProfessionalPersona.veterinaryDoctor => null,
        },
      ),
    _ => VerificationWorkflowSnapshot(
        persona: persona,
        phase: VerificationWorkflowPhase.draft,
        rawApplicationStatus: null,
        documentRows: const [],
      ),
  };
});

final professionalVerificationAuditTrailProvider = FutureProvider.autoDispose
    .family<List<VerificationAuditEntry>, ProfessionalPersona>((ref, persona) {
  return loadVerificationAudit(persona);
});

/// Call after [professionalVerificationWorkflowProvider] changes (handled in UI).
Future<void> recordVerificationAuditProjection({
  required ProfessionalPersona persona,
  required VerificationWorkflowSnapshot snap,
  VerificationWorkflowPhase? previousPhase,
}) async {
  await appendVerificationAuditIfFingerprintChanged(
    persona: persona,
    fingerprint: snap.auditFingerprint,
    toPhase: snap.phase,
    fromPhase: previousPhase,
    apiStatusRaw: snap.rawApplicationStatus,
    note: snap.rejectionOrCorrectionText,
  );
  assert(() {
    debugPrint(
      '[PraniDoctor] ${VerificationNotificationEvent.phaseChanged} '
      'persona=${persona.name} fp=${snap.auditFingerprint}',
    );
    return true;
  }());
}

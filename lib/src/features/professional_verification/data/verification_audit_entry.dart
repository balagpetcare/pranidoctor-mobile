import 'package:pranidoctor_mobile/src/features/professional_verification/domain/verification_workflow_phase.dart';

/// One audit row (local + future server merge) — COMMAND 6.
class VerificationAuditEntry {
  const VerificationAuditEntry({
    required this.id,
    required this.atUtc,
    required this.toPhase,
    this.fromPhase,
    this.apiStatusRaw,
    this.source = 'client_projection',
    this.note,
  });

  final String id;
  final DateTime atUtc;
  final VerificationWorkflowPhase toPhase;
  final VerificationWorkflowPhase? fromPhase;
  final String? apiStatusRaw;
  final String source;
  final String? note;

  Map<String, Object?> toJson() => {
        'id': id,
        'atUtc': atUtc.toIso8601String(),
        'toPhase': toPhase.name,
        'fromPhase': fromPhase?.name,
        'apiStatusRaw': apiStatusRaw,
        'source': source,
        'note': note,
      };

  factory VerificationAuditEntry.fromJson(Map<String, Object?> m) {
    VerificationWorkflowPhase? parsePhase(String? raw) {
      if (raw == null || raw.isEmpty) return null;
      for (final v in VerificationWorkflowPhase.values) {
        if (v.name == raw) return v;
      }
      return null;
    }

    final tp = parsePhase(m['toPhase'] as String?) ?? VerificationWorkflowPhase.draft;

    return VerificationAuditEntry(
      id: '${m['id'] ?? ''}',
      atUtc: DateTime.tryParse('${m['atUtc'] ?? ''}')?.toUtc() ?? DateTime.now().toUtc(),
      toPhase: tp,
      fromPhase: parsePhase(m['fromPhase'] as String?),
      apiStatusRaw: m['apiStatusRaw'] as String?,
      source: '${m['source'] ?? 'client_projection'}',
      note: m['note'] as String?,
    );
  }
}

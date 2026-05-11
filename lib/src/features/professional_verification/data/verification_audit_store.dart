import 'dart:convert';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:pranidoctor_mobile/src/features/professional_profile/domain/professional_persona.dart';
import 'package:pranidoctor_mobile/src/features/professional_verification/data/verification_audit_entry.dart';
import 'package:pranidoctor_mobile/src/features/professional_verification/domain/verification_workflow_phase.dart';

String _auditPrefsKey(ProfessionalPersona p) =>
    'pd_professional_verification_audit_v1_${p.name}';

String _fingerprintPrefsKey(ProfessionalPersona p) =>
    'pd_professional_verification_fp_v1_${p.name}';

Future<List<VerificationAuditEntry>> loadVerificationAudit(
  ProfessionalPersona persona,
) async {
  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getString(_auditPrefsKey(persona));
  if (raw == null || raw.trim().isEmpty) return const [];
  try {
    final list = jsonDecode(raw);
    if (list is! List) return const [];
    return list
        .map(
          (e) => VerificationAuditEntry.fromJson(
            Map<String, Object?>.from(e as Map),
          ),
        )
        .toList();
  } catch (_) {
    return const [];
  }
}

Future<void> saveVerificationAudit(
  ProfessionalPersona persona,
  List<VerificationAuditEntry> entries,
) async {
  final prefs = await SharedPreferences.getInstance();
  final capped = entries.length > 80 ? entries.sublist(entries.length - 80) : entries;
  await prefs.setString(
    _auditPrefsKey(persona),
    jsonEncode(capped.map((e) => e.toJson()).toList()),
  );
}

Future<String?> loadLastVerificationFingerprint(ProfessionalPersona p) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(_fingerprintPrefsKey(p));
}

Future<void> saveLastVerificationFingerprint(
  ProfessionalPersona p,
  String fp,
) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_fingerprintPrefsKey(p), fp);
}

Future<void> appendVerificationAuditIfFingerprintChanged({
  required ProfessionalPersona persona,
  required String fingerprint,
  required VerificationWorkflowPhase toPhase,
  VerificationWorkflowPhase? fromPhase,
  String? apiStatusRaw,
  String? note,
}) async {
  final last = await loadLastVerificationFingerprint(persona);
  if (last == fingerprint) return;

  final list = await loadVerificationAudit(persona);
  final id =
      '${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1 << 30)}';
  list.add(
    VerificationAuditEntry(
      id: id,
      atUtc: DateTime.now().toUtc(),
      toPhase: toPhase,
      fromPhase: fromPhase,
      apiStatusRaw: apiStatusRaw,
      note: note,
    ),
  );
  await saveVerificationAudit(persona, list);
  await saveLastVerificationFingerprint(persona, fingerprint);
}

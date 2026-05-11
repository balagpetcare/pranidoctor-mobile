import 'dart:convert';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:pranidoctor_mobile/src/features/enterprise_insights/domain/enterprise_audit_activity.dart';
import 'package:pranidoctor_mobile/src/features/session/application/session_notifier.dart';

String _auditKey(AppRole role) => 'pd_enterprise_audit_v1_${role.name}';
String _activityKey(AppRole role) => 'pd_enterprise_activity_v1_${role.name}';

Future<List<EnterpriseAuditEntry>> loadEnterpriseAudit(AppRole role) async {
  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getString(_auditKey(role));
  if (raw == null || raw.trim().isEmpty) return const [];
  try {
    final list = jsonDecode(raw);
    if (list is! List) return const [];
    return list
        .map(
          (e) => EnterpriseAuditEntry.fromJson(
            Map<String, Object?>.from(e as Map),
          ),
        )
        .toList();
  } catch (_) {
    return const [];
  }
}

Future<void> appendEnterpriseAudit(
  AppRole role,
  EnterpriseAuditEntry entry,
) async {
  final prefs = await SharedPreferences.getInstance();
  final existing = await loadEnterpriseAudit(role);
  final next = [...existing, entry];
  final capped =
      next.length > 100 ? next.sublist(next.length - 100) : next;
  await prefs.setString(
    _auditKey(role),
    jsonEncode(capped.map((e) => e.toJson()).toList()),
  );
}

Future<void> recordEnterpriseAuditPreview({
  required AppRole role,
  required String actionKey,
  required String summaryBn,
}) async {
  final id =
      '${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1 << 30)}';
  await appendEnterpriseAudit(
    role,
    EnterpriseAuditEntry(
      id: id,
      atUtc: DateTime.now().toUtc(),
      actionKey: actionKey,
      summaryBn: summaryBn,
    ),
  );
}

Future<List<EnterpriseActivityEntry>> loadEnterpriseActivity(
  AppRole role,
) async {
  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getString(_activityKey(role));
  if (raw == null || raw.trim().isEmpty) return const [];
  try {
    final list = jsonDecode(raw);
    if (list is! List) return const [];
    return list
        .map(
          (e) => EnterpriseActivityEntry.fromJson(
            Map<String, Object?>.from(e as Map),
          ),
        )
        .toList();
  } catch (_) {
    return const [];
  }
}

Future<void> appendEnterpriseActivity(
  AppRole role,
  EnterpriseActivityEntry entry,
) async {
  final prefs = await SharedPreferences.getInstance();
  final existing = await loadEnterpriseActivity(role);
  final next = [...existing, entry];
  final capped =
      next.length > 60 ? next.sublist(next.length - 60) : next;
  await prefs.setString(
    _activityKey(role),
    jsonEncode(capped.map((e) => e.toJson()).toList()),
  );
}

Future<void> recordEnterpriseActivityPreview({
  required AppRole role,
  required String titleBn,
  String? detailBn,
}) async {
  final id =
      '${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1 << 30)}';
  await appendEnterpriseActivity(
    role,
    EnterpriseActivityEntry(
      id: id,
      atUtc: DateTime.now().toUtc(),
      titleBn: titleBn,
      detailBn: detailBn,
    ),
  );
}

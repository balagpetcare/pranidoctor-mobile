/// Immutable audit row for compliance / support (local-first until server ships).
class EnterpriseAuditEntry {
  const EnterpriseAuditEntry({
    required this.id,
    required this.atUtc,
    required this.actionKey,
    required this.summaryBn,
    this.payloadJson,
  });

  final String id;
  final DateTime atUtc;
  final String actionKey;
  final String summaryBn;
  final String? payloadJson;

  Map<String, Object?> toJson() => {
        'id': id,
        'atUtc': atUtc.toIso8601String(),
        'actionKey': actionKey,
        'summaryBn': summaryBn,
        if (payloadJson != null) 'payloadJson': payloadJson,
      };

  factory EnterpriseAuditEntry.fromJson(Map<String, Object?> j) {
    return EnterpriseAuditEntry(
      id: '${j['id'] ?? ''}',
      atUtc: DateTime.tryParse('${j['atUtc'] ?? ''}')?.toUtc() ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      actionKey: '${j['actionKey'] ?? ''}',
      summaryBn: '${j['summaryBn'] ?? ''}',
      payloadJson: j['payloadJson'] as String?,
    );
  }
}

/// Lightweight user-visible activity (distinct from audit severity).
class EnterpriseActivityEntry {
  const EnterpriseActivityEntry({
    required this.id,
    required this.atUtc,
    required this.titleBn,
    this.detailBn,
  });

  final String id;
  final DateTime atUtc;
  final String titleBn;
  final String? detailBn;

  Map<String, Object?> toJson() => {
        'id': id,
        'atUtc': atUtc.toIso8601String(),
        'titleBn': titleBn,
        if (detailBn != null) 'detailBn': detailBn,
      };

  factory EnterpriseActivityEntry.fromJson(Map<String, Object?> j) {
    return EnterpriseActivityEntry(
      id: '${j['id'] ?? ''}',
      atUtc: DateTime.tryParse('${j['atUtc'] ?? ''}')?.toUtc() ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      titleBn: '${j['titleBn'] ?? ''}',
      detailBn: j['detailBn'] as String?,
    );
  }
}

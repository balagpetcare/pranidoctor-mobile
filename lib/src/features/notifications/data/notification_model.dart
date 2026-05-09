import 'dart:convert';

/// In-app notification row from `GET /api/mobile/notifications`.
class AppNotification {
  const AppNotification({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
    this.readAt,
    this.relatedRequestId,
    this.metadata,
  });

  final String id;

  /// Optional when API omits (legacy rows).
  final String userId;
  final String type;
  final String title;

  /// Message body; JSON may use `body` or `message`.
  final String body;
  final DateTime? readAt;
  final DateTime createdAt;

  /// Optional link to a service request when API sends it (top-level or metadata).
  final String? relatedRequestId;

  /// Parsed object metadata when API sends `metadata` or JSON `metadataJson`.
  final Map<String, dynamic>? metadata;

  bool get isUnread => readAt == null;

  /// Alias matching common naming (`body` is canonical in API).
  String get message => body;

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    final readRaw = json['readAt'];
    final createdRaw = json['createdAt'];

    final bodyRaw = json['body'] ?? json['message'];
    final bodyStr = bodyRaw is String ? bodyRaw : '';

    Map<String, dynamic>? meta;
    final directMeta = json['metadata'];
    if (directMeta is Map) {
      meta = Map<String, dynamic>.from(directMeta);
    } else {
      final mj = json['metadataJson'];
      if (mj is String && mj.isNotEmpty) {
        try {
          final decoded = jsonDecode(mj);
          if (decoded is Map<String, dynamic>) {
            meta = decoded;
          }
        } catch (_) {}
      }
    }

    String? relatedId;
    final top = json['relatedRequestId'];
    if (top is String && top.isNotEmpty) {
      relatedId = top;
    } else if (meta != null) {
      final r =
          meta['relatedRequestId'] ??
          meta['serviceRequestId'] ??
          meta['requestId'];
      if (r is String && r.isNotEmpty) relatedId = r;
    }

    final uidRaw = json['userId'];
    final uid = uidRaw is String ? uidRaw : '';

    final idRaw = json['id'];
    final idStr = idRaw == null ? '' : '$idRaw';

    return AppNotification(
      id: idStr,
      userId: uid,
      type: json['type'] as String? ?? '',
      title: json['title'] as String? ?? '',
      body: bodyStr,
      readAt: readRaw == null ? null : DateTime.tryParse(readRaw as String),
      createdAt: createdRaw is String
          ? DateTime.parse(createdRaw)
          : DateTime.fromMillisecondsSinceEpoch(0),
      relatedRequestId: relatedId,
      metadata: meta,
    );
  }
}

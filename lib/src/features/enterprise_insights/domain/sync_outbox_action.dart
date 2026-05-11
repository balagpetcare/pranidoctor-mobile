import 'package:meta/meta.dart';

/// High-level mutation kinds for routing, audit, and policy.
enum SyncActionType {
  profileUpdate,
  availabilityChange,
  serviceStatusUpdate,
  bookingDecision,
  notesUpload,
  mediaUploadMetadata,
  unknown,
}

extension SyncActionTypeSerialization on SyncActionType {
  String get wireName => name;

  static SyncActionType parse(String? raw) {
    if (raw == null || raw.isEmpty) return SyncActionType.unknown;
    for (final e in SyncActionType.values) {
      if (e.name == raw) return e;
    }
    return SyncActionType.unknown;
  }
}

/// Lifecycle of a single outbox row.
enum SyncActionStatus {
  pending,
  syncing,
  retryScheduled,
  failed,
  synced,
}

extension SyncActionStatusSerialization on SyncActionStatus {
  String get wireName => name;

  static SyncActionStatus parse(String? raw) {
    if (raw == null || raw.isEmpty) return SyncActionStatus.pending;
    for (final v in SyncActionStatus.values) {
      if (v.name == raw) return v;
    }
    return SyncActionStatus.pending;
  }
}

/// Maps [enqueue] resource/operation pairs into [SyncActionType].
SyncActionType inferSyncActionType(String resource, String operation) {
  final k =
      '${resource.trim().toLowerCase()}.${operation.trim().toLowerCase()}';
  return switch (k) {
    'profile.update' => SyncActionType.profileUpdate,
    'availability.set' ||
    'availability.change' ||
    'doctor.availability' =>
      SyncActionType.availabilityChange,
    'service.status' || 'service.update' => SyncActionType.serviceStatusUpdate,
    'booking.decision' || 'booking.accept' || 'booking.reject' =>
      SyncActionType.bookingDecision,
    'notes.upload' => SyncActionType.notesUpload,
    'media.metadata' || 'media.upload' => SyncActionType.mediaUploadMetadata,
    _ => SyncActionType.unknown,
  };
}

@immutable
class SyncOutboxAction {
  const SyncOutboxAction({
    required this.id,
    required this.type,
    required this.resource,
    required this.operation,
    required this.payloadJson,
    required this.createdAtUtc,
    required this.retryCount,
    required this.status,
    this.lastError,
    this.nextAttemptAtUtc,
    required this.updatedAtUtc,
  });

  final String id;
  final SyncActionType type;
  final String resource;
  final String operation;
  final String payloadJson;
  final DateTime createdAtUtc;
  final int retryCount;
  final SyncActionStatus status;
  final String? lastError;
  final DateTime? nextAttemptAtUtc;
  final DateTime updatedAtUtc;

  Map<String, Object?> toJson() => {
        'id': id,
        'type': type.wireName,
        'resource': resource,
        'operation': operation,
        'payloadJson': payloadJson,
        'createdAtUtc': createdAtUtc.toIso8601String(),
        'retryCount': retryCount,
        'status': status.wireName,
        if (lastError != null) 'lastError': lastError,
        if (nextAttemptAtUtc != null)
          'nextAttemptAtUtc': nextAttemptAtUtc!.toIso8601String(),
        'updatedAtUtc': updatedAtUtc.toIso8601String(),
      };

  factory SyncOutboxAction.fromJson(Map<String, Object?> j) {
    return SyncOutboxAction(
      id: '${j['id'] ?? ''}',
      type: SyncActionTypeSerialization.parse(j['type'] as String?),
      resource: '${j['resource'] ?? ''}',
      operation: '${j['operation'] ?? ''}',
      payloadJson: '${j['payloadJson'] ?? '{}'}',
      createdAtUtc: DateTime.tryParse('${j['createdAtUtc'] ?? ''}')?.toUtc() ??
          DateTime.now().toUtc(),
      retryCount: (j['retryCount'] as num?)?.toInt() ?? 0,
      status: SyncActionStatusSerialization.parse(j['status'] as String?),
      lastError: j['lastError'] as String?,
      nextAttemptAtUtc: j['nextAttemptAtUtc'] != null
          ? DateTime.tryParse('${j['nextAttemptAtUtc']}')?.toUtc()
          : null,
      updatedAtUtc: DateTime.tryParse('${j['updatedAtUtc'] ?? ''}')?.toUtc() ??
          DateTime.now().toUtc(),
    );
  }

  SyncOutboxAction copyWith({
    SyncActionType? type,
    String? resource,
    String? operation,
    String? payloadJson,
    int? retryCount,
    SyncActionStatus? status,
    String? lastError,
    DateTime? nextAttemptAtUtc,
    DateTime? updatedAtUtc,
    bool clearLastError = false,
    bool clearNextAttempt = false,
  }) {
    return SyncOutboxAction(
      id: id,
      type: type ?? this.type,
      resource: resource ?? this.resource,
      operation: operation ?? this.operation,
      payloadJson: payloadJson ?? this.payloadJson,
      createdAtUtc: createdAtUtc,
      retryCount: retryCount ?? this.retryCount,
      status: status ?? this.status,
      lastError: clearLastError ? null : (lastError ?? this.lastError),
      nextAttemptAtUtc: clearNextAttempt
          ? null
          : (nextAttemptAtUtc ?? this.nextAttemptAtUtc),
      updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
    );
  }
}

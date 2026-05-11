import 'package:meta/meta.dart';

import 'package:pranidoctor_mobile/src/features/enterprise_media_upload/domain/chunk_upload_plan.dart';
import 'package:pranidoctor_mobile/src/features/enterprise_media_upload/domain/media_upload_kind.dart';
import 'package:pranidoctor_mobile/src/features/enterprise_media_upload/domain/media_upload_lifecycle.dart';

@immutable
class MediaUploadTask {
  const MediaUploadTask({
    required this.id,
    required this.kind,
    required this.purpose,
    required this.sourcePath,
    required this.displayName,
    required this.mimeType,
    required this.lifecycle,
    required this.progress,
    required this.retryCount,
    required this.createdAtUtc,
    required this.updatedAtUtc,
    this.workingPath,
    this.thumbnailPath,
    this.sizeBytesOriginal,
    this.sizeBytesPrepared,
    this.sha256PreparedHex,
    this.durationMs,
    this.chunkPlanJson,
    this.nextAttemptUtc,
    this.lastError,
    this.paused = false,
    this.cancelRequested = false,
    this.serverFileId,
    this.serverDownloadUrl,
    this.serverMimeType,
    this.serverSizeBytes,
  });

  final String id;
  final MediaUploadKind kind;
  /// Backend `MobileUploadPurpose` string.
  final String purpose;
  final String sourcePath;
  final String displayName;
  final String mimeType;
  final MediaUploadLifecycle lifecycle;
  final double progress;
  final int retryCount;
  final DateTime createdAtUtc;
  final DateTime updatedAtUtc;
  final String? workingPath;
  final String? thumbnailPath;
  final int? sizeBytesOriginal;
  final int? sizeBytesPrepared;
  final String? sha256PreparedHex;
  final int? durationMs;
  final String? chunkPlanJson;
  final DateTime? nextAttemptUtc;
  final String? lastError;
  final bool paused;
  final bool cancelRequested;
  final String? serverFileId;
  final String? serverDownloadUrl;
  final String? serverMimeType;
  final int? serverSizeBytes;

  MediaUploadTask copyWith({
    String? workingPath,
    String? thumbnailPath,
    int? sizeBytesOriginal,
    int? sizeBytesPrepared,
    String? sha256PreparedHex,
    int? durationMs,
    String? chunkPlanJson,
    MediaUploadLifecycle? lifecycle,
    double? progress,
    int? retryCount,
    DateTime? nextAttemptUtc,
    String? lastError,
    bool? paused,
    bool? cancelRequested,
    String? serverFileId,
    String? serverDownloadUrl,
    String? serverMimeType,
    int? serverSizeBytes,
    DateTime? updatedAtUtc,
    bool clearWorkingPath = false,
    bool clearThumb = false,
    bool clearNextAttempt = false,
    bool clearError = false,
  }) {
    return MediaUploadTask(
      id: id,
      kind: kind,
      purpose: purpose,
      sourcePath: sourcePath,
      displayName: displayName,
      mimeType: mimeType,
      lifecycle: lifecycle ?? this.lifecycle,
      progress: progress ?? this.progress,
      retryCount: retryCount ?? this.retryCount,
      createdAtUtc: createdAtUtc,
      updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
      workingPath: clearWorkingPath ? null : (workingPath ?? this.workingPath),
      thumbnailPath: clearThumb ? null : (thumbnailPath ?? this.thumbnailPath),
      sizeBytesOriginal: sizeBytesOriginal ?? this.sizeBytesOriginal,
      sizeBytesPrepared: sizeBytesPrepared ?? this.sizeBytesPrepared,
      sha256PreparedHex: sha256PreparedHex ?? this.sha256PreparedHex,
      durationMs: durationMs ?? this.durationMs,
      chunkPlanJson: chunkPlanJson ?? this.chunkPlanJson,
      nextAttemptUtc: clearNextAttempt
          ? null
          : (nextAttemptUtc ?? this.nextAttemptUtc),
      lastError: clearError ? null : (lastError ?? this.lastError),
      paused: paused ?? this.paused,
      cancelRequested: cancelRequested ?? this.cancelRequested,
      serverFileId: serverFileId ?? this.serverFileId,
      serverDownloadUrl: serverDownloadUrl ?? this.serverDownloadUrl,
      serverMimeType: serverMimeType ?? this.serverMimeType,
      serverSizeBytes: serverSizeBytes ?? this.serverSizeBytes,
    );
  }

  Map<String, Object?> toJson() => {
        'id': id,
        'kind': kind.wireName,
        'purpose': purpose,
        'sourcePath': sourcePath,
        'displayName': displayName,
        'mimeType': mimeType,
        'lifecycle': lifecycle.wireName,
        'progress': progress,
        'retryCount': retryCount,
        'createdAtUtc': createdAtUtc.toIso8601String(),
        'updatedAtUtc': updatedAtUtc.toIso8601String(),
        if (workingPath != null) 'workingPath': workingPath,
        if (thumbnailPath != null) 'thumbnailPath': thumbnailPath,
        if (sizeBytesOriginal != null) 'sizeBytesOriginal': sizeBytesOriginal,
        if (sizeBytesPrepared != null) 'sizeBytesPrepared': sizeBytesPrepared,
        if (sha256PreparedHex != null) 'sha256PreparedHex': sha256PreparedHex,
        if (durationMs != null) 'durationMs': durationMs,
        if (chunkPlanJson != null) 'chunkPlanJson': chunkPlanJson,
        if (nextAttemptUtc != null)
          'nextAttemptUtc': nextAttemptUtc!.toIso8601String(),
        if (lastError != null) 'lastError': lastError,
        'paused': paused,
        'cancelRequested': cancelRequested,
        if (serverFileId != null) 'serverFileId': serverFileId,
        if (serverDownloadUrl != null) 'serverDownloadUrl': serverDownloadUrl,
        if (serverMimeType != null) 'serverMimeType': serverMimeType,
        if (serverSizeBytes != null) 'serverSizeBytes': serverSizeBytes,
      };

  factory MediaUploadTask.fromJson(Map<String, Object?> j) {
    return MediaUploadTask(
      id: '${j['id'] ?? ''}',
      kind: MediaUploadKind.values.firstWhere(
        (e) => e.name == '${j['kind'] ?? ''}',
        orElse: () => MediaUploadKind.other,
      ),
      purpose: '${j['purpose'] ?? ''}',
      sourcePath: '${j['sourcePath'] ?? ''}',
      displayName: '${j['displayName'] ?? ''}',
      mimeType: '${j['mimeType'] ?? 'application/octet-stream'}',
      lifecycle: MediaUploadLifecycleWire.parse(j['lifecycle'] as String?),
      progress: (j['progress'] as num?)?.toDouble() ?? 0,
      retryCount: (j['retryCount'] as num?)?.toInt() ?? 0,
      createdAtUtc: DateTime.tryParse('${j['createdAtUtc'] ?? ''}')?.toUtc() ??
          DateTime.now().toUtc(),
      updatedAtUtc: DateTime.tryParse('${j['updatedAtUtc'] ?? ''}')?.toUtc() ??
          DateTime.now().toUtc(),
      workingPath: j['workingPath'] as String?,
      thumbnailPath: j['thumbnailPath'] as String?,
      sizeBytesOriginal: (j['sizeBytesOriginal'] as num?)?.toInt(),
      sizeBytesPrepared: (j['sizeBytesPrepared'] as num?)?.toInt(),
      sha256PreparedHex: j['sha256PreparedHex'] as String?,
      durationMs: (j['durationMs'] as num?)?.toInt(),
      chunkPlanJson: j['chunkPlanJson'] as String?,
      nextAttemptUtc: j['nextAttemptUtc'] != null
          ? DateTime.tryParse('${j['nextAttemptUtc']}')?.toUtc()
          : null,
      lastError: j['lastError'] as String?,
      paused: j['paused'] == true,
      cancelRequested: j['cancelRequested'] == true,
      serverFileId: j['serverFileId'] as String?,
      serverDownloadUrl: j['serverDownloadUrl'] as String?,
      serverMimeType: j['serverMimeType'] as String?,
      serverSizeBytes: (j['serverSizeBytes'] as num?)?.toInt(),
    );
  }
}

extension ChunkUploadPlanJson on ChunkUploadPlan {
  String toWireJson() =>
      '{"total":$totalBytes,"chunk":$chunkSizeBytes,"count":$chunkCount}';

  static ChunkUploadPlan? tryParse(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    // Minimal parse without full JSON dep for this wire format.
    try {
      final t = RegExp(r'"total":(\d+)').firstMatch(raw)?.group(1);
      final c = RegExp(r'"chunk":(\d+)').firstMatch(raw)?.group(1);
      final n = RegExp(r'"count":(\d+)').firstMatch(raw)?.group(1);
      if (t != null && c != null && n != null) {
        return ChunkUploadPlan(
          totalBytes: int.parse(t),
          chunkSizeBytes: int.parse(c),
          chunkCount: int.parse(n),
        );
      }
    } catch (_) {}
    return null;
  }
}

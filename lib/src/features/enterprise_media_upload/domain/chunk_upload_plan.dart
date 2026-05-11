import 'package:meta/meta.dart';

/// Describes how bytes are sent to storage (single POST today; multi-part S3 later).
@immutable
class ChunkUploadPlan {
  const ChunkUploadPlan({
    required this.totalBytes,
    required this.chunkSizeBytes,
    required this.chunkCount,
  });

  final int totalBytes;
  final int chunkSizeBytes;
  final int chunkCount;

  /// Current backend: one multipart body to `/api/mobile/uploads`.
  factory ChunkUploadPlan.singlePart(int totalBytes) {
    return ChunkUploadPlan(
      totalBytes: totalBytes,
      chunkSizeBytes: totalBytes,
      chunkCount: 1,
    );
  }

  /// Future MinIO/S3 multipart — chunk size hint only; worker not implemented yet.
  factory ChunkUploadPlan.multiPartHint({
    required int totalBytes,
    required int chunkSizeBytes,
  }) {
    final raw = (totalBytes / chunkSizeBytes).ceil();
    final chunks = raw < 1 ? 1 : (raw > 10000 ? 10000 : raw);
    return ChunkUploadPlan(
      totalBytes: totalBytes,
      chunkSizeBytes: chunkSizeBytes,
      chunkCount: chunks,
    );
  }
}

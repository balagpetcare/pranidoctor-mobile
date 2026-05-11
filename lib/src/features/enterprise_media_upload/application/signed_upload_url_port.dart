import 'package:meta/meta.dart';

import 'package:pranidoctor_mobile/src/features/enterprise_media_upload/domain/media_upload_kind.dart';

/// Future MinIO/S3 direct upload — returns null to fall back to `UploadRepository`.
@immutable
class SignedUploadInstruction {
  const SignedUploadInstruction({
    required this.method,
    required this.uploadUrl,
    required this.headers,
    this.callbackUrl,
  });

  final String method;
  final String uploadUrl;
  final Map<String, String> headers;

  /// Optional server callback after PUT completes.
  final String? callbackUrl;
}

abstract class SignedUploadUrlResolver {
  Future<SignedUploadInstruction?> resolve({
    required MediaUploadKind kind,
    required String contentType,
    required int sizeBytes,
    required String fileName,
  });
}

class NoOpSignedUploadUrlResolver implements SignedUploadUrlResolver {
  const NoOpSignedUploadUrlResolver();

  @override
  Future<SignedUploadInstruction?> resolve({
    required MediaUploadKind kind,
    required String contentType,
    required int sizeBytes,
    required String fileName,
  }) async =>
      null;
}

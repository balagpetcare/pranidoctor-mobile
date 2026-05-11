/// Result of `POST /api/mobile/uploads` (private object; [storageKey] is for internal use only).
class UploadedFileResult {
  const UploadedFileResult({
    required this.fileId,
    required this.storageKey,
    required this.downloadUrl,
    required this.originalName,
    required this.mimeType,
    required this.sizeBytes,
  });

  final String fileId;
  final String storageKey;
  final String downloadUrl;
  final String originalName;
  final String mimeType;
  final int sizeBytes;
}

/// Backend `MobileUploadPurpose` values for `POST /api/mobile/uploads`.
abstract final class MobileUploadPurpose {
  static const aiTechnicianNidFront = 'AI_TECHNICIAN_NID_FRONT';
  static const aiTechnicianNidBack = 'AI_TECHNICIAN_NID_BACK';
  static const aiTechnicianProfilePhoto = 'AI_TECHNICIAN_PROFILE_PHOTO';
  static const aiTechnicianCoverImage = 'AI_TECHNICIAN_COVER_IMAGE';
  static const aiTechnicianTrainingCertificate =
      'AI_TECHNICIAN_TRAINING_CERTIFICATE';
  static const aiTechnicianAiCertificate = 'AI_TECHNICIAN_AI_CERTIFICATE';
  static const aiTechnicianOther = 'AI_TECHNICIAN_OTHER';
}

/// Maps Prisma `AiTechnicianDocumentType` string to upload `purpose`.
String mobileUploadPurposeForDocumentType(String documentType) {
  switch (documentType) {
    case 'NID_FRONT':
      return MobileUploadPurpose.aiTechnicianNidFront;
    case 'NID_BACK':
      return MobileUploadPurpose.aiTechnicianNidBack;
    case 'PROFILE_PHOTO':
      return MobileUploadPurpose.aiTechnicianProfilePhoto;
    case 'COVER_IMAGE':
      return MobileUploadPurpose.aiTechnicianCoverImage;
    case 'TRAINING_CERTIFICATE':
      return MobileUploadPurpose.aiTechnicianTrainingCertificate;
    case 'AI_CERTIFICATE':
      return MobileUploadPurpose.aiTechnicianAiCertificate;
    case 'COMPANY_ID':
    case 'EXPERIENCE_PROOF':
    case 'OTHER':
    default:
      return MobileUploadPurpose.aiTechnicianOther;
  }
}

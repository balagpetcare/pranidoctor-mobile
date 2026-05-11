/// Enterprise upload categories (maps to `MobileUploadPurpose` where applicable).
enum MediaUploadKind {
  profileImage,
  coverImage,
  certificate,
  nidIdentity,
  servicePhoto,
  livestockImage,
  video,
  prescriptionAttachment,
  verificationFile,
  other,
}

extension MediaUploadKindWire on MediaUploadKind {
  String get wireName => name;
}

import 'package:pranidoctor_mobile/src/features/professional_profile/data/professional_profile_draft.dart';
import 'package:pranidoctor_mobile/src/features/professional_profile/domain/professional_persona.dart';

/// Weighted completion — tuned for autosave drafts until full API sync exists.
double professionalProfileCompletionPercent({
  required ProfessionalPersona persona,
  required ProfessionalProfileDraft d,
}) {
  double filled = 0;
  double total = 0;

  void w(double weight, bool ok) {
    total += weight;
    if (ok) filled += weight;
  }

  w(2.2, d.displayName.trim().isNotEmpty);
  w(1.0, d.publicBio.trim().length >= 20);
  w(2.0, d.professionalTitle.trim().isNotEmpty);
  w(2.0, d.licenseOrRegNumber.trim().isNotEmpty);
  w(1.5, d.serviceAreasCsv.trim().isNotEmpty);
  w(1.2, d.availabilityNotes.trim().isNotEmpty);
  w(1.2, d.experienceSummary.trim().length >= 16);
  w(1.2, d.educationSummary.trim().length >= 12);
  w(1.0, d.pricingNotes.trim().isNotEmpty);
  w(1.8, d.profilePhotoLocalPath != null || d.profilePhotoUploadId != null);
  w(1.5, d.certificateLocalPath != null || d.certificateUploadId != null);
  w(1.5, d.identityLocalPath != null || d.identityUploadId != null);
  w(1.2, d.workGalleryLocalPaths.isNotEmpty || d.workGalleryUploadIds.isNotEmpty);
  w(0.7, d.introVideoLocalPath != null || d.introVideoUploadId != null);

  if (persona == ProfessionalPersona.aiTechnician) {
    w(0.8, d.providerCode.trim().isNotEmpty);
  }

  if (total <= 0) return 0;
  final pct = (filled / total) * 100.0;
  return pct.clamp(0.0, 100.0);
}

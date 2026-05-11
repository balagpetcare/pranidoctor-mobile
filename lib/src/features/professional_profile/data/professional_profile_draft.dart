/// Local + server-backed IDs for professional profile COMMAND 5 drafts.
///
/// Persisted as JSON (SharedPreferences). Server `fileId` fields populate after
/// successful `POST /api/mobile/uploads` where the purpose enum allows the role.
class ProfessionalProfileDraft {
  const ProfessionalProfileDraft({
    this.displayName = '',
    this.publicBio = '',
    this.professionalTitle = '',
    this.licenseOrRegNumber = '',
    this.providerCode = '',
    this.serviceAreasCsv = '',
    this.availabilityNotes = '',
    this.experienceSummary = '',
    this.educationSummary = '',
    this.pricingNotes = '',
    this.profilePhotoLocalPath,
    this.profilePhotoUploadId,
    this.certificateLocalPath,
    this.certificateUploadId,
    this.identityLocalPath,
    this.identityUploadId,
    this.workGalleryLocalPaths = const [],
    this.workGalleryUploadIds = const [],
    this.introVideoLocalPath,
    this.introVideoUploadId,
  });

  final String displayName;
  final String publicBio;
  final String professionalTitle;
  final String licenseOrRegNumber;
  final String providerCode;
  final String serviceAreasCsv;
  final String availabilityNotes;
  final String experienceSummary;
  final String educationSummary;
  final String pricingNotes;

  final String? profilePhotoLocalPath;
  final String? profilePhotoUploadId;
  final String? certificateLocalPath;
  final String? certificateUploadId;
  final String? identityLocalPath;
  final String? identityUploadId;
  final List<String> workGalleryLocalPaths;
  final List<String> workGalleryUploadIds;
  final String? introVideoLocalPath;
  final String? introVideoUploadId;

  ProfessionalProfileDraft copyWith({
    String? displayName,
    String? publicBio,
    String? professionalTitle,
    String? licenseOrRegNumber,
    String? providerCode,
    String? serviceAreasCsv,
    String? availabilityNotes,
    String? experienceSummary,
    String? educationSummary,
    String? pricingNotes,
    String? profilePhotoLocalPath,
    String? profilePhotoUploadId,
    String? certificateLocalPath,
    String? certificateUploadId,
    String? identityLocalPath,
    String? identityUploadId,
    List<String>? workGalleryLocalPaths,
    List<String>? workGalleryUploadIds,
    String? introVideoLocalPath,
    String? introVideoUploadId,
    bool clearProfilePhotoLocalPath = false,
    bool clearCertificateLocalPath = false,
    bool clearIdentityLocalPath = false,
    bool clearIntroVideoLocalPath = false,
  }) {
    return ProfessionalProfileDraft(
      displayName: displayName ?? this.displayName,
      publicBio: publicBio ?? this.publicBio,
      professionalTitle: professionalTitle ?? this.professionalTitle,
      licenseOrRegNumber: licenseOrRegNumber ?? this.licenseOrRegNumber,
      providerCode: providerCode ?? this.providerCode,
      serviceAreasCsv: serviceAreasCsv ?? this.serviceAreasCsv,
      availabilityNotes: availabilityNotes ?? this.availabilityNotes,
      experienceSummary: experienceSummary ?? this.experienceSummary,
      educationSummary: educationSummary ?? this.educationSummary,
      pricingNotes: pricingNotes ?? this.pricingNotes,
      profilePhotoLocalPath: clearProfilePhotoLocalPath
          ? null
          : (profilePhotoLocalPath ?? this.profilePhotoLocalPath),
      profilePhotoUploadId: profilePhotoUploadId ?? this.profilePhotoUploadId,
      certificateLocalPath: clearCertificateLocalPath
          ? null
          : (certificateLocalPath ?? this.certificateLocalPath),
      certificateUploadId: certificateUploadId ?? this.certificateUploadId,
      identityLocalPath: clearIdentityLocalPath
          ? null
          : (identityLocalPath ?? this.identityLocalPath),
      identityUploadId: identityUploadId ?? this.identityUploadId,
      workGalleryLocalPaths: workGalleryLocalPaths ?? this.workGalleryLocalPaths,
      workGalleryUploadIds: workGalleryUploadIds ?? this.workGalleryUploadIds,
      introVideoLocalPath: clearIntroVideoLocalPath
          ? null
          : (introVideoLocalPath ?? this.introVideoLocalPath),
      introVideoUploadId: introVideoUploadId ?? this.introVideoUploadId,
    );
  }

  Map<String, Object?> toJson() => {
        'displayName': displayName,
        'publicBio': publicBio,
        'professionalTitle': professionalTitle,
        'licenseOrRegNumber': licenseOrRegNumber,
        'providerCode': providerCode,
        'serviceAreasCsv': serviceAreasCsv,
        'availabilityNotes': availabilityNotes,
        'experienceSummary': experienceSummary,
        'educationSummary': educationSummary,
        'pricingNotes': pricingNotes,
        'profilePhotoLocalPath': profilePhotoLocalPath,
        'profilePhotoUploadId': profilePhotoUploadId,
        'certificateLocalPath': certificateLocalPath,
        'certificateUploadId': certificateUploadId,
        'identityLocalPath': identityLocalPath,
        'identityUploadId': identityUploadId,
        'workGalleryLocalPaths': workGalleryLocalPaths,
        'workGalleryUploadIds': workGalleryUploadIds,
        'introVideoLocalPath': introVideoLocalPath,
        'introVideoUploadId': introVideoUploadId,
      };

  factory ProfessionalProfileDraft.fromJson(Map<String, Object?>? json) {
    if (json == null || json.isEmpty) return const ProfessionalProfileDraft();
    List<String> strList(Object? key) {
      final v = json[key];
      if (v is! List) return const [];
      return v.map((e) => '$e').where((s) => s.trim().isNotEmpty).toList();
    }

    return ProfessionalProfileDraft(
      displayName: '${json['displayName'] ?? ''}',
      publicBio: '${json['publicBio'] ?? ''}',
      professionalTitle: '${json['professionalTitle'] ?? ''}',
      licenseOrRegNumber: '${json['licenseOrRegNumber'] ?? ''}',
      providerCode: '${json['providerCode'] ?? ''}',
      serviceAreasCsv: '${json['serviceAreasCsv'] ?? ''}',
      availabilityNotes: '${json['availabilityNotes'] ?? ''}',
      experienceSummary: '${json['experienceSummary'] ?? ''}',
      educationSummary: '${json['educationSummary'] ?? ''}',
      pricingNotes: '${json['pricingNotes'] ?? ''}',
      profilePhotoLocalPath: json['profilePhotoLocalPath'] as String?,
      profilePhotoUploadId: json['profilePhotoUploadId'] as String?,
      certificateLocalPath: json['certificateLocalPath'] as String?,
      certificateUploadId: json['certificateUploadId'] as String?,
      identityLocalPath: json['identityLocalPath'] as String?,
      identityUploadId: json['identityUploadId'] as String?,
      workGalleryLocalPaths: strList('workGalleryLocalPaths'),
      workGalleryUploadIds: strList('workGalleryUploadIds'),
      introVideoLocalPath: json['introVideoLocalPath'] as String?,
      introVideoUploadId: json['introVideoUploadId'] as String?,
    );
  }
}

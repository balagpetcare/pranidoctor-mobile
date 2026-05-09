import 'package:pranidoctor_mobile/src/features/providers/data/provider_kind.dart';
import 'package:pranidoctor_mobile/src/features/providers/data/provider_models.dart';

/// Unified view model for provider cards and detail (maps from API DTOs).
class ProviderProfile {
  const ProviderProfile({
    required this.id,
    required this.name,
    required this.kind,
    this.titleOrQualification,
    this.phonePlaceholder,
    this.areaCoverageSummary,
    this.animalTypesSummary = const [],
    this.serviceTypesSummary,
    this.homeVisit = false,
    this.emergency = false,
    this.aiTechnicianService = false,
    this.onlineConsultation = false,
    this.rating,
    this.feeText,
    this.availabilityText,
    this.profilePhotoUrl,
    this.bioOrNotesShort,
  });

  final String id;
  final String name;
  final ProviderKind kind;

  /// Degree / certification / role line for cards.
  final String? titleOrQualification;

  /// Masked or policy-limited; UI may still show placeholder.
  final String? phonePlaceholder;

  /// Single-line area summary from list API.
  final String? areaCoverageSummary;

  /// Animal types as short labels (API strings or localized).
  final List<String> animalTypesSummary;

  /// Primary service label(s) for list row.
  final String? serviceTypesSummary;

  final bool homeVisit;
  final bool emergency;

  /// True when this row is an AI technician offering field/AI support services.
  final bool aiTechnicianService;

  final bool onlineConsultation;
  final num? rating;
  final String? feeText;
  final String? availabilityText;
  final String? profilePhotoUrl;
  final String? bioOrNotesShort;

  ProviderProfile copyWith({
    String? titleOrQualification,
    String? phonePlaceholder,
    String? areaCoverageSummary,
    List<String>? animalTypesSummary,
    String? serviceTypesSummary,
    bool? homeVisit,
    bool? emergency,
    bool? aiTechnicianService,
    bool? onlineConsultation,
    num? rating,
    String? feeText,
    String? availabilityText,
    String? profilePhotoUrl,
    String? bioOrNotesShort,
  }) {
    return ProviderProfile(
      id: id,
      name: name,
      kind: kind,
      titleOrQualification: titleOrQualification ?? this.titleOrQualification,
      phonePlaceholder: phonePlaceholder ?? this.phonePlaceholder,
      areaCoverageSummary: areaCoverageSummary ?? this.areaCoverageSummary,
      animalTypesSummary: animalTypesSummary ?? this.animalTypesSummary,
      serviceTypesSummary: serviceTypesSummary ?? this.serviceTypesSummary,
      homeVisit: homeVisit ?? this.homeVisit,
      emergency: emergency ?? this.emergency,
      aiTechnicianService: aiTechnicianService ?? this.aiTechnicianService,
      onlineConsultation: onlineConsultation ?? this.onlineConsultation,
      rating: rating ?? this.rating,
      feeText: feeText ?? this.feeText,
      availabilityText: availabilityText ?? this.availabilityText,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      bioOrNotesShort: bioOrNotesShort ?? this.bioOrNotesShort,
    );
  }

  factory ProviderProfile.fromDoctorSummary(DoctorSummary d) {
    return ProviderProfile(
      id: d.id,
      name: d.name,
      kind: ProviderKind.doctor,
      titleOrQualification: d.degreeOrQualification,
      phonePlaceholder: d.phone,
      areaCoverageSummary: d.areaText,
      animalTypesSummary: const [],
      serviceTypesSummary: d.serviceType,
      homeVisit: d.homeVisit,
      emergency: d.emergency,
      aiTechnicianService: false,
      onlineConsultation: d.onlineConsultation,
      rating: d.rating,
      feeText: d.fee,
      availabilityText: d.availability,
      profilePhotoUrl: null,
      bioOrNotesShort: null,
    );
  }

  factory ProviderProfile.fromTechnicianSummary(TechnicianSummary t) {
    return ProviderProfile(
      id: t.id,
      name: t.name,
      kind: ProviderKind.aiTechnician,
      titleOrQualification: t.serviceType,
      phonePlaceholder: t.phone,
      areaCoverageSummary: t.areaText,
      animalTypesSummary: List<String>.from(t.supportedAnimalTypes),
      serviceTypesSummary: t.serviceType,
      homeVisit: t.homeVisit,
      emergency: t.emergency,
      aiTechnicianService: true,
      onlineConsultation: t.onlineConsultation,
      rating: t.rating,
      feeText: t.fee,
      availabilityText: t.availability,
      profilePhotoUrl: null,
      bioOrNotesShort: null,
    );
  }
}

/// Detail screen payload (flattened from [DoctorDetail] / [TechnicianDetail]).
class ProviderProfileDetail {
  const ProviderProfileDetail({
    required this.summary,
    this.bioFull,
    this.certification,
    this.experienceYears,
    this.areaRows = const [],
    this.villageRows = const [],
    this.serviceCategoryLabels = const [],
  });

  final ProviderProfile summary;
  final String? bioFull;
  final String? certification;
  final int? experienceYears;

  /// Display lines for coverage (BN name preferred).
  final List<String> areaRows;
  final List<String> villageRows;
  final List<String> serviceCategoryLabels;

  factory ProviderProfileDetail.fromDoctorDetail(DoctorDetail d) {
    final base = ProviderProfile.fromDoctorSummary(
      d,
    ).copyWith(bioOrNotesShort: d.bio, profilePhotoUrl: d.profilePhotoUrl);
    return ProviderProfileDetail(
      summary: base,
      bioFull: d.bio,
      certification: null,
      experienceYears: d.experienceYears,
      areaRows: d.areas.map((a) => a.nameBn ?? a.name).toList(),
      villageRows: d.villages.map((v) => v.name).toList(),
      serviceCategoryLabels: d.serviceCategories.map((c) => c.name).toList(),
    );
  }

  factory ProviderProfileDetail.fromTechnicianDetail(TechnicianDetail t) {
    final base = ProviderProfile.fromTechnicianSummary(t).copyWith(
      titleOrQualification: t.certification ?? t.serviceType,
      bioOrNotesShort: t.bio,
    );
    return ProviderProfileDetail(
      summary: base,
      bioFull: t.bio,
      certification: t.certification,
      experienceYears: null,
      areaRows: t.areas.map((a) => a.nameBn ?? a.name).toList(),
      villageRows: t.villages.map((v) => v.name).toList(),
      serviceCategoryLabels: t.serviceCategories.map((c) => c.name).toList(),
    );
  }
}

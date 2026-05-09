// Mobile models for `/api/mobile/providers/*` JSON (camelCase).

class PaginationInfo {
  const PaginationInfo({
    required this.limit,
    required this.offset,
    required this.total,
    required this.hasMore,
  });

  final int limit;
  final int offset;
  final int total;
  final bool hasMore;

  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    return PaginationInfo(
      limit: (json['limit'] as num?)?.toInt() ?? 20,
      offset: (json['offset'] as num?)?.toInt() ?? 0,
      total: (json['total'] as num?)?.toInt() ?? 0,
      hasMore: json['hasMore'] as bool? ?? false,
    );
  }
}

class ProviderCallAction {
  const ProviderCallAction({required this.enabled, this.phone, this.reason});

  final bool enabled;
  final String? phone;
  final String? reason;

  factory ProviderCallAction.fromJson(Object? json) {
    if (json is! Map<String, dynamic>) {
      return const ProviderCallAction(enabled: false);
    }
    return ProviderCallAction(
      enabled: json['enabled'] as bool? ?? false,
      phone: json['phone'] as String?,
      reason: json['reason'] as String?,
    );
  }
}

class ProviderBookAction {
  const ProviderBookAction({
    required this.enabled,
    this.providerId,
    this.kind,
    this.reason,
  });

  final bool enabled;
  final String? providerId;
  final String? kind;
  final String? reason;

  factory ProviderBookAction.fromJson(Object? json) {
    if (json is! Map<String, dynamic>) {
      return const ProviderBookAction(enabled: false);
    }
    return ProviderBookAction(
      enabled: json['enabled'] as bool? ?? false,
      providerId: json['providerId'] as String?,
      kind: json['kind'] as String?,
      reason: json['reason'] as String?,
    );
  }
}

class DoctorSummary {
  const DoctorSummary({
    required this.id,
    required this.name,
    required this.homeVisit,
    required this.emergency,
    required this.onlineConsultation,
    this.degreeOrQualification,
    this.serviceType,
    this.areaText,
    this.fee,
    this.availability,
    this.phone,
    this.rating,
    this.callAction,
    this.bookAction,
  });

  final String id;
  final String name;
  final bool homeVisit;
  final bool emergency;
  final bool onlineConsultation;
  final String? degreeOrQualification;
  final String? serviceType;
  final String? areaText;
  final String? fee;
  final String? availability;
  final String? phone;
  final num? rating;
  final ProviderCallAction? callAction;
  final ProviderBookAction? bookAction;

  factory DoctorSummary.fromJson(Map<String, dynamic> json) {
    return DoctorSummary(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      degreeOrQualification: json['degreeOrQualification'] as String?,
      serviceType: json['serviceType'] as String?,
      areaText: json['areaText'] as String?,
      fee: json['fee']?.toString(),
      availability: json['availability'] as String?,
      homeVisit: json['homeVisit'] as bool? ?? false,
      emergency: json['emergency'] as bool? ?? false,
      onlineConsultation: json['onlineConsultation'] as bool? ?? false,
      phone: json['phone'] as String?,
      rating: json['rating'] as num?,
      callAction: ProviderCallAction.fromJson(json['callAction']),
      bookAction: ProviderBookAction.fromJson(json['bookAction']),
    );
  }
}

class DoctorArea {
  const DoctorArea({
    required this.id,
    required this.name,
    this.nameBn,
    this.slug,
    this.type,
    this.priority,
  });

  final String id;
  final String name;
  final String? nameBn;
  final String? slug;
  final String? type;
  final int? priority;

  factory DoctorArea.fromJson(Map<String, dynamic> json) {
    return DoctorArea(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      nameBn: json['nameBn'] as String?,
      slug: json['slug'] as String?,
      type: json['type'] as String?,
      priority: (json['priority'] as num?)?.toInt(),
    );
  }
}

class DoctorVillage {
  const DoctorVillage({
    required this.id,
    required this.name,
    this.slug,
    this.priority,
  });

  final String id;
  final String name;
  final String? slug;
  final int? priority;

  factory DoctorVillage.fromJson(Map<String, dynamic> json) {
    return DoctorVillage(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String?,
      priority: (json['priority'] as num?)?.toInt(),
    );
  }
}

class DoctorServiceCategory {
  const DoctorServiceCategory({
    required this.id,
    required this.name,
    required this.slug,
  });

  final String id;
  final String name;
  final String slug;

  factory DoctorServiceCategory.fromJson(Map<String, dynamic> json) {
    return DoctorServiceCategory(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
    );
  }
}

class DoctorDetail extends DoctorSummary {
  const DoctorDetail({
    required super.id,
    required super.name,
    required super.homeVisit,
    required super.emergency,
    required super.onlineConsultation,
    super.degreeOrQualification,
    super.serviceType,
    super.areaText,
    super.fee,
    super.availability,
    super.phone,
    super.rating,
    super.callAction,
    super.bookAction,
    this.bio,
    this.profilePhotoUrl,
    this.experienceYears,
    this.areas = const [],
    this.villages = const [],
    this.serviceCategories = const [],
  });

  final String? bio;
  final String? profilePhotoUrl;
  final int? experienceYears;
  final List<DoctorArea> areas;
  final List<DoctorVillage> villages;
  final List<DoctorServiceCategory> serviceCategories;

  factory DoctorDetail.fromJson(Map<String, dynamic> json) {
    final base = DoctorSummary.fromJson(json);
    final areasRaw = json['areas'];
    final villagesRaw = json['villages'];
    final catsRaw = json['serviceCategories'];
    return DoctorDetail(
      id: base.id,
      name: base.name,
      degreeOrQualification: base.degreeOrQualification,
      serviceType: base.serviceType,
      areaText: base.areaText,
      fee: base.fee,
      availability: base.availability,
      homeVisit: base.homeVisit,
      emergency: base.emergency,
      onlineConsultation: base.onlineConsultation,
      phone: base.phone,
      rating: base.rating,
      callAction: base.callAction,
      bookAction: base.bookAction,
      bio: json['bio'] as String?,
      profilePhotoUrl: json['profilePhotoUrl'] as String?,
      experienceYears: (json['experienceYears'] as num?)?.toInt(),
      areas: areasRaw is List<dynamic>
          ? areasRaw
                .map((e) => DoctorArea.fromJson(e as Map<String, dynamic>))
                .toList()
          : const [],
      villages: villagesRaw is List<dynamic>
          ? villagesRaw
                .map((e) => DoctorVillage.fromJson(e as Map<String, dynamic>))
                .toList()
          : const [],
      serviceCategories: catsRaw is List<dynamic>
          ? catsRaw
                .map(
                  (e) =>
                      DoctorServiceCategory.fromJson(e as Map<String, dynamic>),
                )
                .toList()
          : const [],
    );
  }
}

class TechnicianSummary {
  const TechnicianSummary({
    required this.id,
    required this.name,
    required this.homeVisit,
    required this.emergency,
    required this.onlineConsultation,
    this.serviceType,
    this.areaText,
    this.fee,
    this.availability,
    this.supportedAnimalTypes = const [],
    this.phone,
    this.rating,
    this.callAction,
    this.bookAction,
  });

  final String id;
  final String name;
  final bool homeVisit;
  final bool emergency;
  final bool onlineConsultation;
  final String? serviceType;
  final String? areaText;
  final String? fee;
  final String? availability;
  final List<String> supportedAnimalTypes;
  final String? phone;
  final num? rating;
  final ProviderCallAction? callAction;
  final ProviderBookAction? bookAction;

  factory TechnicianSummary.fromJson(Map<String, dynamic> json) {
    final rawTypes = json['supportedAnimalTypes'];
    return TechnicianSummary(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      serviceType: json['serviceType'] as String?,
      areaText: json['areaText'] as String?,
      fee: json['fee']?.toString(),
      availability: json['availability'] as String?,
      homeVisit: json['homeVisit'] as bool? ?? false,
      emergency: json['emergency'] as bool? ?? false,
      onlineConsultation: json['onlineConsultation'] as bool? ?? false,
      supportedAnimalTypes: rawTypes is List<dynamic>
          ? rawTypes.map((e) => e.toString()).toList()
          : const [],
      phone: json['phone'] as String?,
      rating: json['rating'] as num?,
      callAction: ProviderCallAction.fromJson(json['callAction']),
      bookAction: ProviderBookAction.fromJson(json['bookAction']),
    );
  }
}

class TechnicianDetail extends TechnicianSummary {
  const TechnicianDetail({
    required super.id,
    required super.name,
    required super.homeVisit,
    required super.emergency,
    required super.onlineConsultation,
    super.serviceType,
    super.areaText,
    super.fee,
    super.availability,
    super.supportedAnimalTypes,
    super.phone,
    super.rating,
    super.callAction,
    super.bookAction,
    this.bio,
    this.certification,
    this.metadataJson,
    this.areas = const [],
    this.villages = const [],
    this.serviceCategories = const [],
  });

  final String? bio;
  final String? certification;
  final Object? metadataJson;
  final List<DoctorArea> areas;
  final List<DoctorVillage> villages;
  final List<DoctorServiceCategory> serviceCategories;

  factory TechnicianDetail.fromJson(Map<String, dynamic> json) {
    final base = TechnicianSummary.fromJson(json);
    final areasRaw = json['areas'];
    final villagesRaw = json['villages'];
    final catsRaw = json['serviceCategories'];
    return TechnicianDetail(
      id: base.id,
      name: base.name,
      serviceType: base.serviceType,
      areaText: base.areaText,
      fee: base.fee,
      availability: base.availability,
      homeVisit: base.homeVisit,
      emergency: base.emergency,
      onlineConsultation: base.onlineConsultation,
      supportedAnimalTypes: base.supportedAnimalTypes,
      phone: base.phone,
      rating: base.rating,
      callAction: base.callAction,
      bookAction: base.bookAction,
      bio: json['bio'] as String?,
      certification: json['certification'] as String?,
      metadataJson: json['metadataJson'],
      areas: areasRaw is List<dynamic>
          ? areasRaw
                .map((e) => DoctorArea.fromJson(e as Map<String, dynamic>))
                .toList()
          : const [],
      villages: villagesRaw is List<dynamic>
          ? villagesRaw
                .map((e) => DoctorVillage.fromJson(e as Map<String, dynamic>))
                .toList()
          : const [],
      serviceCategories: catsRaw is List<dynamic>
          ? catsRaw
                .map(
                  (e) =>
                      DoctorServiceCategory.fromJson(e as Map<String, dynamic>),
                )
                .toList()
          : const [],
    );
  }
}

/// Row from `GET /api/mobile/ai-services/technicians`.
class AiTechnicianForServiceSummary {
  AiTechnicianForServiceSummary({
    required this.id,
    required this.displayName,
    this.district,
    this.upazila,
    required this.serviceAreaSummary,
    required this.verified,
    required this.acceptsEmergency,
    this.startingPriceBdt,
    required this.serviceTitles,
    this.ratingAverage,
    required this.ratingCount,
    required this.completedServicesCount,
  });

  final String id;
  final String displayName;
  final String? district;
  final String? upazila;
  final String serviceAreaSummary;
  final bool verified;
  final bool acceptsEmergency;
  final String? startingPriceBdt;
  final List<String> serviceTitles;
  final double? ratingAverage;
  final int ratingCount;
  final int completedServicesCount;

  factory AiTechnicianForServiceSummary.fromJson(Map<String, dynamic> j) {
    final titles = (j['serviceTitles'] as List<dynamic>? ?? [])
        .map((e) => e.toString())
        .toList();
    return AiTechnicianForServiceSummary(
      id: j['id'] as String,
      displayName: j['displayName'] as String? ?? '',
      district: j['district'] as String?,
      upazila: j['upazila'] as String?,
      serviceAreaSummary: j['serviceAreaSummary'] as String? ?? '',
      verified: j['verified'] as bool? ?? false,
      acceptsEmergency: j['acceptsEmergency'] as bool? ?? false,
      startingPriceBdt: j['startingPriceBdt'] as String?,
      serviceTitles: titles,
      ratingAverage: (j['ratingAverage'] as num?)?.toDouble(),
      ratingCount: (j['ratingCount'] as num?)?.toInt() ?? 0,
      completedServicesCount:
          (j['completedServicesCount'] as num?)?.toInt() ?? 0,
    );
  }
}

class AiTechnicianPublicServiceDto {
  AiTechnicianPublicServiceDto({
    required this.id,
    required this.title,
    required this.animalType,
    this.breedOrSemenType,
    this.description,
    required this.basePrice,
    this.visitFee,
    this.emergencyFee,
    required this.followUpIncluded,
  });

  final String id;
  final String title;
  final String animalType;
  final String? breedOrSemenType;
  final String? description;
  final String basePrice;
  final String? visitFee;
  final String? emergencyFee;
  final bool followUpIncluded;

  factory AiTechnicianPublicServiceDto.fromJson(Map<String, dynamic> j) {
    return AiTechnicianPublicServiceDto(
      id: j['id'] as String,
      title: j['title'] as String? ?? '',
      animalType: j['animalType'] as String? ?? 'OTHER',
      breedOrSemenType: j['breedOrSemenType'] as String?,
      description: j['description'] as String?,
      basePrice: j['basePrice']?.toString() ?? '0',
      visitFee: j['visitFee']?.toString(),
      emergencyFee: j['emergencyFee']?.toString(),
      followUpIncluded: j['followUpIncluded'] as bool? ?? false,
    );
  }
}

class AiTechnicianDivisionAreaDto {
  AiTechnicianDivisionAreaDto({
    required this.id,
    required this.district,
    required this.upazila,
    this.unionOrArea,
  });

  final String id;
  final String district;
  final String upazila;
  final String? unionOrArea;

  factory AiTechnicianDivisionAreaDto.fromJson(Map<String, dynamic> j) {
    return AiTechnicianDivisionAreaDto(
      id: j['id'] as String,
      district: j['district'] as String? ?? '',
      upazila: j['upazila'] as String? ?? '',
      unionOrArea: j['unionOrArea'] as String?,
    );
  }
}

/// `GET /api/mobile/ai-services/technicians/[id]` → `data.technician`.
class AiTechnicianPublicDetail {
  AiTechnicianPublicDetail({
    required this.id,
    required this.displayName,
    this.district,
    this.upazila,
    this.unionOrArea,
    this.bio,
    this.experienceYears,
    required this.verified,
    required this.acceptsEmergency,
    this.serviceFeeBdt,
    required this.completedServicesCount,
    this.ratingAverage,
    required this.ratingCount,
    required this.divisionCoverageAreas,
    required this.services,
  });

  final String id;
  final String displayName;
  final String? district;
  final String? upazila;
  final String? unionOrArea;
  final String? bio;
  final int? experienceYears;
  final bool verified;
  final bool acceptsEmergency;
  final String? serviceFeeBdt;
  final int completedServicesCount;
  final double? ratingAverage;
  final int ratingCount;
  final List<AiTechnicianDivisionAreaDto> divisionCoverageAreas;
  final List<AiTechnicianPublicServiceDto> services;

  factory AiTechnicianPublicDetail.fromJson(Map<String, dynamic> j) {
    final areas = (j['divisionCoverageAreas'] as List<dynamic>? ?? [])
        .map(
          (e) =>
              AiTechnicianDivisionAreaDto.fromJson(e as Map<String, dynamic>),
        )
        .toList();
    final svcs = (j['services'] as List<dynamic>? ?? [])
        .map(
          (e) =>
              AiTechnicianPublicServiceDto.fromJson(e as Map<String, dynamic>),
        )
        .toList();
    return AiTechnicianPublicDetail(
      id: j['id'] as String,
      displayName: j['displayName'] as String? ?? '',
      district: j['district'] as String?,
      upazila: j['upazila'] as String?,
      unionOrArea: j['unionOrArea'] as String?,
      bio: j['bio'] as String?,
      experienceYears: (j['experienceYears'] as num?)?.toInt(),
      verified: j['verified'] as bool? ?? false,
      acceptsEmergency: j['acceptsEmergency'] as bool? ?? false,
      serviceFeeBdt: j['serviceFeeBdt'] as String?,
      completedServicesCount:
          (j['completedServicesCount'] as num?)?.toInt() ?? 0,
      ratingAverage: (j['ratingAverage'] as num?)?.toDouble(),
      ratingCount: (j['ratingCount'] as num?)?.toInt() ?? 0,
      divisionCoverageAreas: areas,
      services: svcs,
    );
  }
}

class AiFarmerServiceRequestRow {
  AiFarmerServiceRequestRow({
    required this.id,
    required this.status,
    required this.animalType,
    this.breed,
    this.animalAge,
    this.lastHeatDate,
    this.heatSymptoms,
    this.previousAiHistory,
    this.healthIssueNote,
    this.district,
    this.upazila,
    this.unionOrArea,
    this.addressDetail,
    this.preferredTime,
    required this.isEmergency,
    this.technicianProfileId,
    this.serviceId,
    this.estimatedFee,
    this.finalFee,
    this.paymentStatus,
    this.declineReason,
    required this.createdAt,
    this.updatedAt,
    this.technicianDisplayName,
    this.farmerDisplayName,
    this.hasAiReview,
  });

  final String id;
  final String status;
  final String animalType;
  final String? breed;
  final String? animalAge;
  final String? lastHeatDate;
  final String? heatSymptoms;
  final String? previousAiHistory;
  final String? healthIssueNote;
  final String? district;
  final String? upazila;
  final String? unionOrArea;
  final String? addressDetail;
  final String? preferredTime;
  final bool isEmergency;
  final String? technicianProfileId;
  final String? serviceId;
  final String? estimatedFee;
  final String? finalFee;
  final String? paymentStatus;
  final String? declineReason;
  final String createdAt;
  final String? updatedAt;
  final String? technicianDisplayName;

  /// Present on technician list/detail API when customer has a display name.
  final String? farmerDisplayName;

  /// True when this request already has a native AI technician review.
  final bool? hasAiReview;

  factory AiFarmerServiceRequestRow.fromJson(Map<String, dynamic> j) {
    return AiFarmerServiceRequestRow(
      id: j['id'] as String,
      status: j['status'] as String? ?? 'PENDING',
      animalType: j['animalType'] as String? ?? 'OTHER',
      breed: j['breed'] as String?,
      animalAge: j['animalAge'] as String?,
      lastHeatDate: j['lastHeatDate'] as String?,
      heatSymptoms: j['heatSymptoms'] as String?,
      previousAiHistory: j['previousAiHistory'] as String?,
      healthIssueNote: j['healthIssueNote'] as String?,
      district: j['district'] as String?,
      upazila: j['upazila'] as String?,
      unionOrArea: j['unionOrArea'] as String?,
      addressDetail: j['addressDetail'] as String?,
      preferredTime: j['preferredTime'] as String?,
      isEmergency: j['isEmergency'] as bool? ?? false,
      technicianProfileId: j['technicianProfileId'] as String?,
      serviceId: j['serviceId'] as String?,
      estimatedFee: j['estimatedFee'] as String?,
      finalFee: j['finalFee'] as String?,
      paymentStatus: j['paymentStatus'] as String?,
      declineReason: j['declineReason'] as String?,
      createdAt: j['createdAt'] as String? ?? '',
      updatedAt: j['updatedAt'] as String?,
      technicianDisplayName: j['technicianDisplayName'] as String?,
      farmerDisplayName: j['farmerDisplayName'] as String?,
      hasAiReview: j['hasAiReview'] as bool?,
    );
  }
}

// Mobile DTOs for GET/POST /api/mobile/ai-technician/* (Prisma enums as strings).

import 'package:flutter/foundation.dart' show debugPrint;

class AiTechnicianMeResult {
  const AiTechnicianMeResult({this.profile, this.serverMessage});

  final AiTechnicianProfile? profile;
  final String? serverMessage;

  bool get hasApplication => profile != null;
}

class AiTechnicianProfile {
  final String id;
  final String userId;
  final String status;
  final String providerStatus;
  final String? displayName;
  final String? phone;
  final String? email;
  final String? nidNumber;
  final String? dateOfBirth;
  final String? gender;
  final String? presentAddress;
  final String? district;
  final String? upazila;
  final String? unionOrArea;
  final String? districtId;
  final String? upazilaId;
  final String? unionId;
  final int? experienceYears;
  final String? trainingProvider;
  final String? certificateNumber;
  final String? certification;
  final String? bio;
  final String? serviceFeeBdt;
  final bool acceptsEmergency;
  final String? verifiedAt;
  final String? adminNote;
  final String? correctionNote;
  final String? reviewedAt;
  final String? publishedAt;
  final String createdAt;
  final String updatedAt;
  final List<AiTechnicianDocument> documents;
  final List<AiTechnicianDivisionArea> divisionCoverageAreas;
  final AiTechnicianServicesSummary servicesSummary;

  AiTechnicianProfile({
    required this.id,
    required this.userId,
    required this.status,
    required this.providerStatus,
    this.displayName,
    this.phone,
    this.email,
    this.nidNumber,
    this.dateOfBirth,
    this.gender,
    this.presentAddress,
    this.district,
    this.upazila,
    this.unionOrArea,
    this.districtId,
    this.upazilaId,
    this.unionId,
    this.experienceYears,
    this.trainingProvider,
    this.certificateNumber,
    this.certification,
    this.bio,
    this.serviceFeeBdt,
    required this.acceptsEmergency,
    this.verifiedAt,
    this.adminNote,
    this.correctionNote,
    this.reviewedAt,
    this.publishedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.documents,
    required this.divisionCoverageAreas,
    required this.servicesSummary,
  });

  static String? _normalizeGender(String? raw) {
    const allowed = {'MALE', 'FEMALE', 'OTHER', 'UNKNOWN'};
    final t = raw?.trim();
    if (t == null || t.isEmpty) return null;
    if (allowed.contains(t)) return t;
    return null;
  }

  factory AiTechnicianProfile.fromJson(Map<String, dynamic> j) {
    return AiTechnicianProfile(
      id: j['id'] as String,
      userId: j['userId'] as String,
      status: j['status'] as String? ?? 'DRAFT',
      providerStatus: j['providerStatus'] as String? ?? 'PENDING_VERIFICATION',
      displayName: j['displayName'] as String?,
      phone: j['phone'] as String?,
      email: j['email'] as String?,
      nidNumber: j['nidNumber'] as String?,
      dateOfBirth: j['dateOfBirth'] as String?,
      gender: _normalizeGender(j['gender'] as String?),
      presentAddress: j['presentAddress'] as String?,
      district: j['district'] as String?,
      upazila: j['upazila'] as String?,
      unionOrArea: j['unionOrArea'] as String?,
      districtId: j['districtId'] as String?,
      upazilaId: j['upazilaId'] as String?,
      unionId: j['unionId'] as String?,
      experienceYears: (j['experienceYears'] as num?)?.toInt(),
      trainingProvider: j['trainingProvider'] as String?,
      certificateNumber: j['certificateNumber'] as String?,
      certification: j['certification'] as String?,
      bio: j['bio'] as String?,
      serviceFeeBdt: j['serviceFeeBdt'] as String?,
      acceptsEmergency: j['acceptsEmergency'] as bool? ?? false,
      verifiedAt: j['verifiedAt'] as String?,
      adminNote: j['adminNote'] as String?,
      correctionNote: j['correctionNote'] as String?,
      reviewedAt: j['reviewedAt'] as String?,
      publishedAt: j['publishedAt'] as String?,
      createdAt: j['createdAt'] as String? ?? '',
      updatedAt: j['updatedAt'] as String? ?? '',
      documents: (j['documents'] as List<dynamic>? ?? [])
          .map((e) => AiTechnicianDocument.fromJson(e as Map<String, dynamic>))
          .toList(),
      divisionCoverageAreas:
          (j['divisionCoverageAreas'] as List<dynamic>? ?? [])
              .map(
                (e) => AiTechnicianDivisionArea.fromJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList(),
      servicesSummary: AiTechnicianServicesSummary.fromJson(
        j['servicesSummary'] as Map<String, dynamic>? ?? const {},
      ),
    );
  }

  bool get isEditable =>
      status == 'DRAFT' ||
      status == 'NEEDS_CORRECTION' ||
      status == 'NEEDS_MORE_INFO';

  Map<String, dynamic> toApplyBody() {
    final m = <String, dynamic>{};
    void put(String k, Object? v) {
      if (v == null) return;
      if (v is String && v.trim().isEmpty) return;
      m[k] = v;
    }

    put('displayName', displayName);
    put('phone', phone);
    put('email', email);
    put('nidNumber', nidNumber);
    put('dateOfBirth', dateOfBirth);
    put('gender', gender);
    put('presentAddress', presentAddress);
    put('district', district);
    put('upazila', upazila);
    put('unionOrArea', unionOrArea);
    put('districtId', districtId);
    put('upazilaId', upazilaId);
    put('unionId', unionId);
    if (experienceYears != null) m['experienceYears'] = experienceYears;
    put('trainingProvider', trainingProvider);
    put('certificateNumber', certificateNumber);
    put('certification', certification);
    put('bio', bio);
    put('serviceFeeBdt', serviceFeeBdt);
    m['acceptsEmergency'] = acceptsEmergency;
    return m;
  }
}

class AiTechnicianDocument {
  final String id;
  final String type;
  final String title;
  final String? fileUrl;
  final String? storageKey;
  final String? uploadedFileId;
  final String? mimeType;
  final String reviewStatus;
  final String uploadedAt;
  final String createdAt;

  AiTechnicianDocument({
    required this.id,
    required this.type,
    required this.title,
    this.fileUrl,
    this.storageKey,
    this.uploadedFileId,
    this.mimeType,
    required this.reviewStatus,
    required this.uploadedAt,
    required this.createdAt,
  });

  factory AiTechnicianDocument.fromJson(Map<String, dynamic> j) {
    return AiTechnicianDocument(
      id: j['id'] as String,
      type: j['type'] as String? ?? 'OTHER',
      title: j['title'] as String? ?? '',
      fileUrl: j['fileUrl'] as String?,
      storageKey: j['storageKey'] as String?,
      uploadedFileId: j['uploadedFileId'] as String?,
      mimeType: j['mimeType'] as String?,
      reviewStatus: j['reviewStatus'] as String? ?? 'PENDING_REVIEW',
      uploadedAt: j['uploadedAt'] as String? ?? '',
      createdAt: j['createdAt'] as String? ?? '',
    );
  }
}

class AiTechnicianDivisionArea {
  final String id;
  final String district;
  final String upazila;
  final String? unionOrArea;
  final String? districtId;
  final String? upazilaId;
  final String? unionId;
  final bool isActive;
  final String createdAt;

  AiTechnicianDivisionArea({
    required this.id,
    required this.district,
    required this.upazila,
    this.unionOrArea,
    this.districtId,
    this.upazilaId,
    this.unionId,
    required this.isActive,
    required this.createdAt,
  });

  factory AiTechnicianDivisionArea.fromJson(Map<String, dynamic> j) {
    return AiTechnicianDivisionArea(
      id: j['id'] as String,
      district: j['district'] as String? ?? '',
      upazila: j['upazila'] as String? ?? '',
      unionOrArea: j['unionOrArea'] as String?,
      districtId: j['districtId'] as String?,
      upazilaId: j['upazilaId'] as String?,
      unionId: j['unionId'] as String?,
      isActive: j['isActive'] as bool? ?? true,
      createdAt: j['createdAt'] as String? ?? '',
    );
  }
}

class AiTechnicianServicesSummary {
  final int count;
  final List<Map<String, dynamic>> items;

  AiTechnicianServicesSummary({required this.count, required this.items});

  factory AiTechnicianServicesSummary.fromJson(Map<String, dynamic> j) {
    final items = (j['items'] as List<dynamic>? ?? [])
        .map((e) => e as Map<String, dynamic>)
        .toList();
    return AiTechnicianServicesSummary(
      count: (j['count'] as num?)?.toInt() ?? items.length,
      items: items,
    );
  }
}

/// Prisma `AiTechnicianDocumentType` values (keep in sync with backend).
abstract final class AiTechnicianDocumentTypes {
  static const values = <String>[
    'NID_FRONT',
    'NID_BACK',
    'PROFILE_PHOTO',
    'COVER_IMAGE',
    'TRAINING_CERTIFICATE',
    'AI_CERTIFICATE',
    'COMPANY_ID',
    'EXPERIENCE_PROOF',
    'OTHER',
  ];

  static String labelBn(String code) {
    switch (code) {
      case 'NID_FRONT':
        return 'এনআইডি (সামনে)';
      case 'NID_BACK':
        return 'এনআইডি (পিছনে)';
      case 'PROFILE_PHOTO':
        return 'প্রোফাইল ছবি';
      case 'COVER_IMAGE':
        return 'কভার ছবি';
      case 'TRAINING_CERTIFICATE':
        return 'সার্টিফিকেট';
      case 'AI_CERTIFICATE':
        return 'এআই সার্টিফিকেট';
      case 'COMPANY_ID':
        return 'কোম্পানি পরিচয়পত্র';
      case 'EXPERIENCE_PROOF':
        return 'অভিজ্ঞতার প্রমাণ';
      case 'OTHER':
        return 'অন্যান্য';
      default:
        return code;
    }
  }
}

/// User-facing copy for application pipeline status.
abstract final class AiTechnicianStatusCopy {
  static String titleBn(String? status) {
    final normalized = status?.trim();
    if (normalized == null || normalized.isEmpty) {
      return 'অবস্থা পাওয়া যায়নি';
    }
    switch (normalized) {
      case 'DRAFT':
        return 'খসড়া';
      case 'SUBMITTED':
        return 'জমা হয়েছে';
      case 'UNDER_REVIEW':
      case 'PENDING_VERIFICATION':
        return 'যাচাই অপেক্ষমান';
      case 'NEEDS_CORRECTION':
      case 'NEEDS_MORE_INFO':
        return 'আরও তথ্য প্রয়োজন';
      case 'APPROVED':
        return 'অনুমোদিত';
      case 'PUBLISHED':
        return 'প্রকাশিত';
      case 'REJECTED':
        return 'বাতিল';
      case 'SUSPENDED':
        return 'স্থগিত';
      case 'ACTIVE':
        return 'সক্রিয়';
      case 'INACTIVE':
        return 'নিষ্ক্রিয়';
      case 'VERIFIED':
        return 'যাচাইকৃত';
      default:
        assert(() {
          debugPrint('Unknown AI Technician status: $normalized');
          return true;
        }());
        return 'অবস্থা পাওয়া যায়নি';
    }
  }

  static String messageBn(String? status) {
    final normalized = status?.trim();
    if (normalized == null || normalized.isEmpty) {
      return 'বর্তমান অবস্থার তথ্য এখনো পাওয়া যায়নি।';
    }
    switch (normalized) {
      case 'DRAFT':
        return 'আপনার তথ্য এখনো খসড়া। ফর্ম সম্পূর্ণ করে জমা দিন।';
      case 'SUBMITTED':
        return 'আপনার আবেদন জমা হয়েছে। অ্যাডমিন যাচাই করার পর আপনাকে জানানো হবে।';
      case 'UNDER_REVIEW':
      case 'PENDING_VERIFICATION':
        return 'আপনার আবেদন যাচাই চলছে। অনুগ্রহ করে অপেক্ষা করুন।';
      case 'NEEDS_CORRECTION':
      case 'NEEDS_MORE_INFO':
        return 'অ্যাডমিন সংশোধন চেয়েছেন। নিচের নোট দেখে ফর্ম আপডেট করে আবার জমা দিন।';
      case 'APPROVED':
        return 'অনুমোদিত হয়েছে। প্রকাশের পর খামারিদের কাছে দেখা যাবে।';
      case 'PUBLISHED':
        return 'প্রোফাইল প্রকাশিত। এখন আপনি এআই টেকনিশিয়ান হিসেবে সেবা দিতে পারেন।';
      case 'REJECTED':
        return 'দুঃখিত, এই আবেদন প্রত্যাখ্যান করা হয়েছে।';
      case 'SUSPENDED':
        return 'আপনার টেকনিশিয়ান প্রোফাইল স্থগিত করা হয়েছে। সাপোর্টে যোগাযোগ করুন।';
      default:
        return 'বর্তমান অবস্থার তথ্য এখনো পাওয়া যায়নি।';
    }
  }

  static String providerStatusBn(String? status) {
    final normalized = status?.trim();
    if (normalized == null || normalized.isEmpty) {
      return 'অবস্থা পাওয়া যায়নি';
    }
    switch (normalized) {
      case 'PENDING_VERIFICATION':
        return 'যাচাই অপেক্ষমান';
      case 'APPROVED':
        return 'অনুমোদিত';
      case 'REJECTED':
        return 'বাতিল হয়েছে';
      case 'NEEDS_MORE_INFO':
        return 'আরও তথ্য প্রয়োজন';
      default:
        return titleBn(normalized);
    }
  }
}

/// One public-facing review line on technician dashboard (`recentReviews`).
class AiTechnicianReviewSnippet {
  AiTechnicianReviewSnippet({
    required this.id,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  final String id;
  final int rating;
  final String? comment;
  final String createdAt;

  factory AiTechnicianReviewSnippet.fromJson(Map<String, dynamic> j) {
    return AiTechnicianReviewSnippet(
      id: j['id'] as String,
      rating: (j['rating'] as num?)?.toInt() ?? 0,
      comment: j['comment'] as String?,
      createdAt: j['createdAt'] as String? ?? '',
    );
  }
}

/// `GET /api/mobile/ai-technician/dashboard`
class AiTechnicianDashboardData {
  const AiTechnicianDashboardData({
    this.profile,
    this.profileStatus,
    required this.isPublished,
    this.providerStatus,
    required this.acceptsEmergency,
    required this.todayRequestsCount,
    required this.pendingRequestsCount,
    required this.completedServicesCount,
    required this.totalEarningsBdt,
    this.ratingAverage,
    required this.ratingCount,
    required this.activeServices,
    this.adminNote,
    this.correctionNote,
    this.recentReviews = const [],
  });

  final AiTechnicianProfile? profile;
  final String? profileStatus;
  final bool isPublished;
  final String? providerStatus;
  final bool acceptsEmergency;
  final int todayRequestsCount;
  final int pendingRequestsCount;
  final int completedServicesCount;
  final String totalEarningsBdt;
  final double? ratingAverage;
  final int ratingCount;
  final List<AiTechnicianServiceRow> activeServices;
  final String? adminNote;
  final String? correctionNote;
  final List<AiTechnicianReviewSnippet> recentReviews;

  factory AiTechnicianDashboardData.fromJson(Map<String, dynamic> j) {
    final rawProfile = j['profile'];
    return AiTechnicianDashboardData(
      profile: rawProfile is Map<String, dynamic>
          ? AiTechnicianProfile.fromJson(rawProfile)
          : null,
      profileStatus: j['profileStatus'] as String?,
      isPublished: j['isPublished'] as bool? ?? false,
      providerStatus: j['providerStatus'] as String?,
      acceptsEmergency: j['acceptsEmergency'] as bool? ?? false,
      todayRequestsCount: (j['todayRequestsCount'] as num?)?.toInt() ?? 0,
      pendingRequestsCount: (j['pendingRequestsCount'] as num?)?.toInt() ?? 0,
      completedServicesCount:
          (j['completedServicesCount'] as num?)?.toInt() ?? 0,
      totalEarningsBdt: j['totalEarningsBdt'] as String? ?? '0',
      ratingAverage: (j['ratingAverage'] as num?)?.toDouble(),
      ratingCount: (j['ratingCount'] as num?)?.toInt() ?? 0,
      activeServices: (j['activeServices'] as List<dynamic>? ?? [])
          .map(
            (e) => AiTechnicianServiceRow.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
      adminNote: j['adminNote'] as String?,
      correctionNote: j['correctionNote'] as String?,
      recentReviews: (j['recentReviews'] as List<dynamic>? ?? [])
          .map(
            (e) =>
                AiTechnicianReviewSnippet.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    );
  }
}

/// Technician-owned service / gig row (`AiTechnicianService`).
class AiTechnicianServiceRow {
  AiTechnicianServiceRow({
    required this.id,
    this.aiTechnicianId,
    required this.title,
    required this.animalType,
    this.breedOrSemenType,
    this.description,
    required this.basePrice,
    this.visitFee,
    this.emergencyFee,
    this.repeatServicePolicy,
    required this.followUpIncluded,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String? aiTechnicianId;
  final String title;
  final String animalType;
  final String? breedOrSemenType;
  final String? description;
  final String basePrice;
  final String? visitFee;
  final String? emergencyFee;
  final String? repeatServicePolicy;
  final bool followUpIncluded;
  final String status;
  final String createdAt;
  final String updatedAt;

  bool get isEditable => status == 'DRAFT' || status == 'PENDING_REVIEW';

  factory AiTechnicianServiceRow.fromJson(Map<String, dynamic> j) {
    return AiTechnicianServiceRow(
      id: j['id'] as String,
      aiTechnicianId: j['aiTechnicianId'] as String?,
      title: j['title'] as String? ?? '',
      animalType: j['animalType'] as String? ?? 'OTHER',
      breedOrSemenType: j['breedOrSemenType'] as String?,
      description: j['description'] as String?,
      basePrice: j['basePrice']?.toString() ?? '0',
      visitFee: j['visitFee']?.toString(),
      emergencyFee: j['emergencyFee']?.toString(),
      repeatServicePolicy: j['repeatServicePolicy'] as String?,
      followUpIncluded: j['followUpIncluded'] as bool? ?? false,
      status: j['status'] as String? ?? 'DRAFT',
      createdAt: j['createdAt'] as String? ?? '',
      updatedAt: j['updatedAt'] as String? ?? '',
    );
  }

  Map<String, dynamic> toCreateBody() {
    return <String, dynamic>{
      'title': title.trim(),
      'animalType': animalType,
      if (breedOrSemenType != null && breedOrSemenType!.trim().isNotEmpty)
        'breedOrSemenType': breedOrSemenType!.trim(),
      if (description != null && description!.trim().isNotEmpty)
        'description': description!.trim(),
      'basePrice': basePrice.trim(),
      if (visitFee != null && visitFee!.trim().isNotEmpty)
        'visitFee': visitFee!.trim(),
      if (emergencyFee != null && emergencyFee!.trim().isNotEmpty)
        'emergencyFee': emergencyFee!.trim(),
      if (repeatServicePolicy != null && repeatServicePolicy!.trim().isNotEmpty)
        'repeatServicePolicy': repeatServicePolicy!.trim(),
      'followUpIncluded': followUpIncluded,
    };
  }

  Map<String, dynamic> toPatchBody() {
    return toCreateBody();
  }
}

abstract final class AiTechnicianAnimalTypes {
  static const values = <String>[
    'CATTLE',
    'GOAT',
    'POULTRY',
    'DOG',
    'CAT',
    'OTHER',
  ];

  static String labelBn(String code) {
    switch (code) {
      case 'CATTLE':
        return 'গরু / মহিষ';
      case 'GOAT':
        return 'ছাগল';
      case 'POULTRY':
        return 'হাঁস-মুরগি';
      case 'DOG':
        return 'কুকুর';
      case 'CAT':
        return 'বিড়াল';
      case 'OTHER':
        return 'অন্যান্য';
      default:
        return code;
    }
  }
}

abstract final class AiTechnicianServiceStatusCopy {
  static String titleBn(String? status) {
    final normalized = status?.trim();
    if (normalized == null || normalized.isEmpty) {
      return 'অবস্থা পাওয়া যায়নি';
    }
    switch (normalized) {
      case 'DRAFT':
        return 'খসড়া';
      case 'PENDING_REVIEW':
        return 'অ্যাডমিন অনুমোদনের অপেক্ষায়';
      case 'ACTIVE':
        return 'সক্রিয়';
      case 'INACTIVE':
        return 'নিষ্ক্রিয়';
      case 'REJECTED':
        return 'প্রত্যাখ্যাত';
      default:
        return 'অবস্থা পাওয়া যায়নি';
    }
  }
}

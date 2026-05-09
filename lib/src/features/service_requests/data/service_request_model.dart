// Service request / booking — API types (camelCase, matches pranidoctor-web DTOs).
// ignore_for_file: constant_identifier_names

enum ServiceRequestType {
  DOCTOR_HOME_VISIT,
  EMERGENCY_DOCTOR,
  AI_SERVICE,
  ONLINE_CONSULTATION_LATER;

  static ServiceRequestType fromJson(String v) {
    return ServiceRequestType.values.byName(v);
  }

  String get slug {
    return switch (this) {
      ServiceRequestType.DOCTOR_HOME_VISIT => 'doctor-visit',
      ServiceRequestType.EMERGENCY_DOCTOR => 'emergency',
      ServiceRequestType.AI_SERVICE => 'ai-service',
      ServiceRequestType.ONLINE_CONSULTATION_LATER => 'online-consultation',
    };
  }

  String get labelBn {
    return switch (this) {
      ServiceRequestType.DOCTOR_HOME_VISIT => 'ডাক্তার — বাড়িতে পরিদর্শন',
      ServiceRequestType.EMERGENCY_DOCTOR => 'জরুরি ডাক্তার',
      ServiceRequestType.AI_SERVICE => 'AI সেবা',
      ServiceRequestType.ONLINE_CONSULTATION_LATER => 'অনলাইন পরামর্শ (পরে)',
    };
  }
}

enum ServiceRequestStatus {
  PENDING,
  ACCEPTED,
  ASSIGNED,
  IN_PROGRESS,
  COMPLETED,
  CANCELLED,
  REJECTED;

  static ServiceRequestStatus fromJson(String v) {
    return ServiceRequestStatus.values.byName(v);
  }

  String get labelBn {
    return switch (this) {
      ServiceRequestStatus.PENDING => 'অপেক্ষমান',
      ServiceRequestStatus.ACCEPTED => 'গ্রহণ হয়েছে',
      ServiceRequestStatus.ASSIGNED => 'নিয়োগ হয়েছে',
      ServiceRequestStatus.IN_PROGRESS => 'চলছে',
      ServiceRequestStatus.COMPLETED => 'সম্পন্ন',
      ServiceRequestStatus.CANCELLED => 'বাতিল',
      ServiceRequestStatus.REJECTED => 'প্রত্যাখ্যাত',
    };
  }
}

class ServiceCategoryOption {
  const ServiceCategoryOption({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
  });

  final String id;
  final String name;
  final String slug;
  final String? description;

  factory ServiceCategoryOption.fromJson(Map<String, dynamic> json) {
    return ServiceCategoryOption(
      id: _optString(json['id']) ?? '',
      name: _optString(json['name']) ?? '',
      slug: _optString(json['slug']) ?? '',
      description: _optString(json['description']),
    );
  }
}

class ServiceRequestAnimalRef {
  const ServiceRequestAnimalRef({
    required this.id,
    required this.name,
    required this.species,
    required this.active,
  });

  final String id;
  final String name;
  final String species;
  final bool active;

  factory ServiceRequestAnimalRef.fromJson(Map<String, dynamic> json) {
    return ServiceRequestAnimalRef(
      id: _optString(json['id']) ?? '',
      name: _optString(json['name']) ?? '—',
      species: _optString(json['species']) ?? '—',
      active: json['active'] is bool ? json['active'] as bool : true,
    );
  }
}

class ServiceRequest {
  const ServiceRequest({
    required this.id,
    required this.customerId,
    required this.animalId,
    required this.serviceCategoryId,
    required this.serviceType,
    required this.status,
    required this.submittedAt,
    required this.createdAt,
    required this.updatedAt,
    this.problemOrSymptom,
    this.description,
    this.areaId,
    this.villageId,
    this.locationText,
    this.preferredTime,
    this.scheduledStart,
    this.scheduledEnd,
    this.assignedDoctorId,
    this.assignedTechnicianId,
    this.isEmergency = false,
    this.emergencyNotes,
    this.urgency,
    this.assignedAt,
    this.startedAt,
    this.completedAt,
    this.cancelledAt,
    this.cancelReason,
    this.serviceCategory,
    this.animal,
    this.assignedDoctor,
    this.assignedTechnician,
  });

  final String id;
  final String customerId;
  final String animalId;
  final String serviceCategoryId;
  final ServiceRequestType serviceType;
  final ServiceRequestStatus status;
  final DateTime submittedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  final String? problemOrSymptom;
  final String? description;
  final String? areaId;
  final String? villageId;
  final String? locationText;
  final String? preferredTime;
  final DateTime? scheduledStart;
  final DateTime? scheduledEnd;
  final String? assignedDoctorId;
  final String? assignedTechnicianId;
  final bool isEmergency;
  final String? emergencyNotes;
  final String? urgency;
  final DateTime? assignedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;
  final String? cancelReason;

  final ServiceCategoryOption? serviceCategory;
  final ServiceRequestAnimalRef? animal;
  final Map<String, dynamic>? assignedDoctor;
  final Map<String, dynamic>? assignedTechnician;

  /// Display name from mobile API `assignedDoctor` / `assignedTechnician` objects (`displayName`).
  String? get assignedDoctorDisplayName =>
      _displayNameFromProviderRef(assignedDoctor);

  String? get assignedTechnicianDisplayName =>
      _displayNameFromProviderRef(assignedTechnician);

  String? get assignedDoctorPhone => _phoneFromProviderRef(assignedDoctor);

  String? get assignedTechnicianPhone =>
      _phoneFromProviderRef(assignedTechnician);

  /// Human-readable urgency (API may omit; booking sometimes merges into [description]).
  String get urgencyDisplayBn {
    final raw = urgency?.trim();
    if (raw == null || raw.isEmpty) {
      return isEmergency ? 'জরুরি' : '—';
    }
    switch (raw) {
      case 'normal':
        return 'সাধারণ';
      case 'urgent':
        return 'দ্রুত';
      case 'emergency':
        return 'জরুরি';
      default:
        return raw;
    }
  }

  static String? _displayNameFromProviderRef(Map<String, dynamic>? ref) {
    if (ref == null) return null;
    final d = ref['displayName'];
    if (d is! String) return null;
    final t = d.trim();
    return t.isEmpty ? null : t;
  }

  static String? _phoneFromProviderRef(Map<String, dynamic>? ref) {
    if (ref == null) return null;
    for (final key in ['phone', 'mobile', 'phoneNumber']) {
      final v = ref[key];
      final s = _optString(v);
      if (s != null) return s;
    }
    return null;
  }

  factory ServiceRequest.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? asMap(dynamic v) => _asMap(v);

    final now = DateTime.now();

    ServiceRequestAnimalRef? animalParsed;
    final animalMap = asMap(json['animal']);
    if (animalMap != null) {
      try {
        animalParsed = ServiceRequestAnimalRef.fromJson(animalMap);
      } catch (_) {
        animalParsed = null;
      }
    }

    ServiceCategoryOption? categoryParsed;
    final catMap = asMap(json['serviceCategory']);
    if (catMap != null) {
      try {
        categoryParsed = ServiceCategoryOption.fromJson(catMap);
      } catch (_) {
        categoryParsed = null;
      }
    }

    return ServiceRequest(
      id: _optString(json['id']) ?? '',
      customerId: _optString(json['customerId']) ?? '',
      animalId: _optString(json['animalId']) ?? '',
      serviceCategoryId: _optString(json['serviceCategoryId']) ?? '',
      serviceType: _parseServiceType(json['serviceType']),
      status: _parseStatus(json['status']),
      submittedAt: _parseDateTime(json['submittedAt']) ?? now,
      createdAt: _parseDateTime(json['createdAt']) ?? now,
      updatedAt: _parseDateTime(json['updatedAt']) ?? now,
      problemOrSymptom: _optString(json['problemOrSymptom']),
      description: _optString(json['description']),
      areaId: _optString(json['areaId']),
      villageId: _optString(json['villageId']),
      locationText: _optString(json['locationText']),
      preferredTime: _optString(json['preferredTime']),
      scheduledStart: _parseDateTime(json['scheduledStart']),
      scheduledEnd: _parseDateTime(json['scheduledEnd']),
      assignedDoctorId: _optString(json['assignedDoctorId']),
      assignedTechnicianId: _optString(json['assignedTechnicianId']),
      isEmergency: json['isEmergency'] is bool
          ? json['isEmergency'] as bool
          : false,
      emergencyNotes: _optString(json['emergencyNotes']),
      urgency: _optString(json['urgency']),
      assignedAt: _parseDateTime(json['assignedAt']),
      startedAt: _parseDateTime(json['startedAt']),
      completedAt: _parseDateTime(json['completedAt']),
      cancelledAt: _parseDateTime(json['cancelledAt']),
      cancelReason: _optString(json['cancelReason']),
      serviceCategory: categoryParsed,
      animal: animalParsed,
      assignedDoctor: asMap(json['assignedDoctor']),
      assignedTechnician: asMap(json['assignedTechnician']),
    );
  }

  bool get canCustomerCancel {
    return status == ServiceRequestStatus.PENDING ||
        status == ServiceRequestStatus.ACCEPTED ||
        status == ServiceRequestStatus.ASSIGNED;
  }
}

String? _optString(dynamic v) {
  if (v == null) return null;
  if (v is String) {
    final t = v.trim();
    return t.isEmpty ? null : t;
  }
  return v.toString();
}

Map<String, dynamic>? _asMap(dynamic v) => v is Map<String, dynamic> ? v : null;

DateTime? _parseDateTime(dynamic v) {
  if (v == null) return null;
  if (v is String) return DateTime.tryParse(v);
  return null;
}

ServiceRequestType _parseServiceType(dynamic v) {
  if (v is! String) return ServiceRequestType.DOCTOR_HOME_VISIT;
  try {
    return ServiceRequestType.fromJson(v);
  } catch (_) {
    return ServiceRequestType.DOCTOR_HOME_VISIT;
  }
}

ServiceRequestStatus _parseStatus(dynamic v) {
  if (v is! String) return ServiceRequestStatus.PENDING;
  try {
    return ServiceRequestStatus.fromJson(v);
  } catch (_) {
    return ServiceRequestStatus.PENDING;
  }
}

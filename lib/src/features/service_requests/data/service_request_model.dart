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
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      description: json['description'] as String?,
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
      id: json['id'] as String,
      name: json['name'] as String,
      species: json['species'] as String,
      active: json['active'] as bool,
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

  static String? _displayNameFromProviderRef(Map<String, dynamic>? ref) {
    if (ref == null) return null;
    final d = ref['displayName'];
    if (d is! String) return null;
    final t = d.trim();
    return t.isEmpty ? null : t;
  }

  factory ServiceRequest.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? asMap(dynamic v) =>
        v is Map<String, dynamic> ? v : null;

    return ServiceRequest(
      id: json['id'] as String,
      customerId: json['customerId'] as String,
      animalId: json['animalId'] as String,
      serviceCategoryId: json['serviceCategoryId'] as String,
      serviceType: ServiceRequestType.fromJson(json['serviceType'] as String),
      status: ServiceRequestStatus.fromJson(json['status'] as String),
      submittedAt: DateTime.parse(json['submittedAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      problemOrSymptom: json['problemOrSymptom'] as String?,
      description: json['description'] as String?,
      areaId: json['areaId'] as String?,
      villageId: json['villageId'] as String?,
      locationText: json['locationText'] as String?,
      preferredTime: json['preferredTime'] as String?,
      scheduledStart: json['scheduledStart'] == null
          ? null
          : DateTime.tryParse(json['scheduledStart'] as String),
      scheduledEnd: json['scheduledEnd'] == null
          ? null
          : DateTime.tryParse(json['scheduledEnd'] as String),
      assignedDoctorId: json['assignedDoctorId'] as String?,
      assignedTechnicianId: json['assignedTechnicianId'] as String?,
      isEmergency: json['isEmergency'] as bool? ?? false,
      emergencyNotes: json['emergencyNotes'] as String?,
      urgency: json['urgency'] as String?,
      assignedAt: json['assignedAt'] == null
          ? null
          : DateTime.tryParse(json['assignedAt'] as String),
      startedAt: json['startedAt'] == null
          ? null
          : DateTime.tryParse(json['startedAt'] as String),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.tryParse(json['completedAt'] as String),
      cancelledAt: json['cancelledAt'] == null
          ? null
          : DateTime.tryParse(json['cancelledAt'] as String),
      cancelReason: json['cancelReason'] as String?,
      serviceCategory: asMap(json['serviceCategory']) == null
          ? null
          : ServiceCategoryOption.fromJson(asMap(json['serviceCategory'])!),
      animal: asMap(json['animal']) == null
          ? null
          : ServiceRequestAnimalRef.fromJson(asMap(json['animal'])!),
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

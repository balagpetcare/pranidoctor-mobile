// AI technician job / request DTOs (camelCase). Tolerates unknown JSON keys.

/// High-level UI phase for status cards (maps from API `status` + flags).
enum TechnicianWorkflowPhase {
  newRequest,
  accepted,
  active,
  serviceRecorded,
  completed,
  rejectedOrCancelled;

  String get labelBn {
    return switch (this) {
      TechnicianWorkflowPhase.newRequest => 'নতুন অনুরোধ',
      TechnicianWorkflowPhase.accepted => 'গ্রহণ হয়েছে',
      TechnicianWorkflowPhase.active => 'চলমান',
      TechnicianWorkflowPhase.serviceRecorded => 'রেকর্ড সংরক্ষিত',
      TechnicianWorkflowPhase.completed => 'সম্পন্ন',
      TechnicianWorkflowPhase.rejectedOrCancelled => 'বাতিল / প্রত্যাখ্যান',
    };
  }
}

class TechnicianAnimalSummary {
  const TechnicianAnimalSummary({
    required this.name,
    this.species,
    this.breed,
    this.animalType,
  });

  final String name;
  final String? species;
  final String? breed;
  final String? animalType;

  factory TechnicianAnimalSummary.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const TechnicianAnimalSummary(name: '—');
    }
    return TechnicianAnimalSummary(
      name: (json['name'] as String?)?.trim().isNotEmpty == true
          ? json['name'] as String
          : '—',
      species: json['species'] as String?,
      breed: json['breed'] as String?,
      animalType: json['animalType'] as String?,
    );
  }
}

class TechnicianCustomerSummary {
  const TechnicianCustomerSummary({this.displayName, this.phoneHint});

  final String? displayName;
  final String? phoneHint;

  factory TechnicianCustomerSummary.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const TechnicianCustomerSummary();
    return TechnicianCustomerSummary(
      displayName: json['displayName'] as String?,
      phoneHint: json['phoneHint'] as String? ?? json['phone'] as String?,
    );
  }

  String get displayLineBn {
    final n = displayName?.trim();
    if (n != null && n.isNotEmpty) return n;
    final p = phoneHint?.trim();
    if (p != null && p.isNotEmpty) return 'গ্রাহক: $p';
    return 'গ্রাহক —';
  }
}

class TechnicianAiServiceRecord {
  const TechnicianAiServiceRecord({
    this.animalType,
    this.breed,
    this.semenOrBreedTypeNote,
    this.servicePerformedAt,
    this.technicianNote,
    this.followUpReminderNote,
    this.billingNote,
  });

  final String? animalType;
  final String? breed;
  final String? semenOrBreedTypeNote;
  final DateTime? servicePerformedAt;
  final String? technicianNote;
  final String? followUpReminderNote;
  final String? billingNote;

  factory TechnicianAiServiceRecord.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const TechnicianAiServiceRecord();
    DateTime? parseDt(dynamic v) =>
        v == null ? null : DateTime.tryParse(v.toString());
    return TechnicianAiServiceRecord(
      animalType: json['animalType'] as String?,
      breed: json['breed'] as String?,
      semenOrBreedTypeNote:
          json['semenOrBreedTypeNote'] as String? ??
          json['semenType'] as String?,
      servicePerformedAt: parseDt(json['servicePerformedAt']),
      technicianNote: json['technicianNote'] as String?,
      followUpReminderNote: json['followUpReminderNote'] as String?,
      billingNote: json['billingNote'] as String?,
    );
  }
}

/// Input from AI service record form (sent to API).
class TechnicianAiRecordInput {
  const TechnicianAiRecordInput({
    required this.animalType,
    required this.breed,
    this.semenOrBreedTypeNote = '',
    required this.servicePerformedAt,
    required this.technicianNote,
    this.followUpReminderNote = '',
    this.billingNote = '',
  });

  final String animalType;
  final String breed;
  final String semenOrBreedTypeNote;
  final DateTime servicePerformedAt;
  final String technicianNote;
  final String followUpReminderNote;
  final String billingNote;

  Map<String, dynamic> toJson() => {
    'animalType': animalType.trim(),
    'breed': breed.trim(),
    'semenOrBreedTypeNote': semenOrBreedTypeNote.trim(),
    'servicePerformedAt': servicePerformedAt.toUtc().toIso8601String(),
    'technicianNote': technicianNote.trim(),
    'followUpReminderNote': followUpReminderNote.trim(),
    'billingNote': billingNote.trim(),
  };
}

class TechnicianIncomingRequest {
  const TechnicianIncomingRequest({
    required this.id,
    required this.status,
    required this.phase,
    this.animal,
    this.customer,
    this.locationText,
    this.problemOrSymptom,
    this.submittedAt,
  });

  final String id;
  final String status;
  final TechnicianWorkflowPhase phase;
  final TechnicianAnimalSummary? animal;
  final TechnicianCustomerSummary? customer;
  final String? locationText;
  final String? problemOrSymptom;
  final DateTime? submittedAt;

  factory TechnicianIncomingRequest.fromJson(Map<String, dynamic> json) {
    final status = json['status'] as String? ?? 'PENDING';
    final hasRecord = json['hasAiRecord'] as bool? ?? false;
    return TechnicianIncomingRequest(
      id: json['id'] as String? ?? json['jobId'] as String? ?? '',
      status: status,
      phase: _phaseFrom(status: status, hasAiRecord: hasRecord),
      animal: json['animal'] is Map<String, dynamic>
          ? TechnicianAnimalSummary.fromJson(
              json['animal'] as Map<String, dynamic>,
            )
          : null,
      customer: json['customer'] is Map<String, dynamic>
          ? TechnicianCustomerSummary.fromJson(
              json['customer'] as Map<String, dynamic>,
            )
          : null,
      locationText: json['locationText'] as String?,
      problemOrSymptom: json['problemOrSymptom'] as String?,
      submittedAt: json['submittedAt'] == null
          ? null
          : DateTime.tryParse(json['submittedAt'].toString()),
    );
  }
}

class TechnicianJobSummary {
  const TechnicianJobSummary({
    required this.id,
    required this.status,
    required this.phase,
    this.animal,
    this.customer,
    this.locationText,
    this.submittedAt,
    this.hasAiRecord = false,
  });

  final String id;
  final String status;
  final TechnicianWorkflowPhase phase;
  final TechnicianAnimalSummary? animal;
  final TechnicianCustomerSummary? customer;
  final String? locationText;
  final DateTime? submittedAt;
  final bool hasAiRecord;

  factory TechnicianJobSummary.fromJson(Map<String, dynamic> json) {
    final status = json['status'] as String? ?? 'ASSIGNED';
    final hasRecord = json['hasAiRecord'] as bool? ?? false;
    return TechnicianJobSummary(
      id: json['id'] as String? ?? json['jobId'] as String? ?? '',
      status: status,
      phase: _phaseFrom(status: status, hasAiRecord: hasRecord),
      animal: json['animal'] is Map<String, dynamic>
          ? TechnicianAnimalSummary.fromJson(
              json['animal'] as Map<String, dynamic>,
            )
          : null,
      customer: json['customer'] is Map<String, dynamic>
          ? TechnicianCustomerSummary.fromJson(
              json['customer'] as Map<String, dynamic>,
            )
          : null,
      locationText: json['locationText'] as String?,
      submittedAt: json['submittedAt'] == null
          ? null
          : DateTime.tryParse(json['submittedAt'].toString()),
      hasAiRecord: hasRecord,
    );
  }
}

class TechnicianJobDetail {
  const TechnicianJobDetail({
    required this.id,
    required this.status,
    required this.phase,
    this.serviceRequestId,
    this.animal,
    this.customer,
    this.locationText,
    this.problemOrSymptom,
    this.description,
    this.preferredTime,
    this.submittedAt,
    this.assignedAt,
    this.startedAt,
    this.completedAt,
    this.hasAiRecord = false,
    this.aiRecord,
  });

  final String id;
  final String status;
  final TechnicianWorkflowPhase phase;
  final String? serviceRequestId;
  final TechnicianAnimalSummary? animal;
  final TechnicianCustomerSummary? customer;
  final String? locationText;
  final String? problemOrSymptom;
  final String? description;
  final String? preferredTime;
  final DateTime? submittedAt;
  final DateTime? assignedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final bool hasAiRecord;
  final TechnicianAiServiceRecord? aiRecord;

  bool get canAccept {
    final s = status.toUpperCase();
    return s == 'PENDING' || s == 'ASSIGNED';
  }

  bool get canReject {
    return phase != TechnicianWorkflowPhase.completed &&
        phase != TechnicianWorkflowPhase.rejectedOrCancelled;
  }

  bool get canEditRecord {
    return phase != TechnicianWorkflowPhase.completed &&
        phase != TechnicianWorkflowPhase.rejectedOrCancelled;
  }

  /// Complete only after AI service record exists (or phase already reflects it).
  bool get canComplete {
    if (phase == TechnicianWorkflowPhase.completed ||
        phase == TechnicianWorkflowPhase.rejectedOrCancelled) {
      return false;
    }
    return hasAiRecord || phase == TechnicianWorkflowPhase.serviceRecorded;
  }

  factory TechnicianJobDetail.fromJson(Map<String, dynamic> json) {
    final status = json['status'] as String? ?? 'ASSIGNED';
    final hasRecord = json['hasAiRecord'] as bool? ?? false;
    final recordJson = json['aiRecord'] ?? json['aiServiceRecord'];
    return TechnicianJobDetail(
      id: json['id'] as String? ?? json['jobId'] as String? ?? '',
      status: status,
      phase: _phaseFrom(status: status, hasAiRecord: hasRecord),
      serviceRequestId: json['serviceRequestId'] as String?,
      animal: json['animal'] is Map<String, dynamic>
          ? TechnicianAnimalSummary.fromJson(
              json['animal'] as Map<String, dynamic>,
            )
          : null,
      customer: json['customer'] is Map<String, dynamic>
          ? TechnicianCustomerSummary.fromJson(
              json['customer'] as Map<String, dynamic>,
            )
          : null,
      locationText: json['locationText'] as String?,
      problemOrSymptom: json['problemOrSymptom'] as String?,
      description: json['description'] as String?,
      preferredTime: json['preferredTime'] as String?,
      submittedAt: json['submittedAt'] == null
          ? null
          : DateTime.tryParse(json['submittedAt'].toString()),
      assignedAt: json['assignedAt'] == null
          ? null
          : DateTime.tryParse(json['assignedAt'].toString()),
      startedAt: json['startedAt'] == null
          ? null
          : DateTime.tryParse(json['startedAt'].toString()),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.tryParse(json['completedAt'].toString()),
      hasAiRecord: hasRecord,
      aiRecord: recordJson is Map<String, dynamic>
          ? TechnicianAiServiceRecord.fromJson(recordJson)
          : null,
    );
  }

  TechnicianJobDetail copyWith({
    String? status,
    TechnicianWorkflowPhase? phase,
    bool? hasAiRecord,
    TechnicianAiServiceRecord? aiRecord,
    DateTime? startedAt,
    DateTime? completedAt,
  }) {
    final nextStatus = status ?? this.status;
    final nextHas = hasAiRecord ?? this.hasAiRecord;
    final nextPhase =
        phase ?? _phaseFrom(status: nextStatus, hasAiRecord: nextHas);
    return TechnicianJobDetail(
      id: id,
      status: nextStatus,
      phase: nextPhase,
      serviceRequestId: serviceRequestId,
      animal: animal,
      customer: customer,
      locationText: locationText,
      problemOrSymptom: problemOrSymptom,
      description: description,
      preferredTime: preferredTime,
      submittedAt: submittedAt,
      assignedAt: assignedAt,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      hasAiRecord: nextHas,
      aiRecord: aiRecord ?? this.aiRecord,
    );
  }
}

TechnicianWorkflowPhase _phaseFrom({
  required String status,
  required bool hasAiRecord,
}) {
  final s = status.toUpperCase();
  if (s == 'REJECTED' ||
      s == 'CANCELLED' ||
      s == 'CANCELED' ||
      s == 'DECLINED') {
    return TechnicianWorkflowPhase.rejectedOrCancelled;
  }
  if (s == 'COMPLETED') return TechnicianWorkflowPhase.completed;
  if (hasAiRecord) return TechnicianWorkflowPhase.serviceRecorded;
  if (s == 'IN_PROGRESS') return TechnicianWorkflowPhase.active;
  if (s == 'ACCEPTED') return TechnicianWorkflowPhase.accepted;
  // ASSIGNED / PENDING: awaiting technician response in our mobile UX.
  if (s == 'ASSIGNED' || s == 'PENDING') {
    return TechnicianWorkflowPhase.newRequest;
  }
  return TechnicianWorkflowPhase.newRequest;
}

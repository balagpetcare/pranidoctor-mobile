// Doctor workflow — API DTOs (tolerant parsing; backend may evolve).

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

bool _optBool(dynamic v) {
  if (v is bool) return v;
  return false;
}

/// Summary line for customer (doctor view).
class DoctorCustomerSummary {
  const DoctorCustomerSummary({this.displayName, this.phone});

  final String? displayName;
  final String? phone;

  String get displayLineBn {
    final n = displayName?.trim();
    final p = phone?.trim();
    if (n != null && n.isNotEmpty && p != null && p.isNotEmpty) {
      return '$n · $p';
    }
    if (n != null && n.isNotEmpty) return n;
    if (p != null && p.isNotEmpty) return p;
    return '—';
  }

  factory DoctorCustomerSummary.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const DoctorCustomerSummary();
    }
    return DoctorCustomerSummary(
      displayName:
          _optString(json['displayName']) ??
          _optString(json['name']) ??
          _optString(json['fullName']),
      phone:
          _optString(json['phone']) ??
          _optString(json['mobile']) ??
          _optString(json['phoneNumber']),
    );
  }
}

/// Summary for animal on doctor lists/detail.
class DoctorAnimalSummary {
  const DoctorAnimalSummary({required this.name, required this.species});

  final String name;
  final String species;

  String get lineBn => name.trim().isEmpty && species.trim().isEmpty
      ? '—'
      : '${name.trim().isEmpty ? '—' : name} (${species.trim().isEmpty ? '—' : species})';

  factory DoctorAnimalSummary.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const DoctorAnimalSummary(name: '—', species: '—');
    }
    return DoctorAnimalSummary(
      name: _optString(json['name']) ?? '—',
      species: _optString(json['species']) ?? '—',
    );
  }
}

/// Row from GET /api/mobile/doctor/requests (pending / new queue).
class DoctorIncomingRequest {
  const DoctorIncomingRequest({
    required this.requestId,
    this.caseId,
    required this.status,
    this.serviceTypeLabel,
    this.submittedAt,
    this.priorityLabel,
    this.isEmergency = false,
    this.customer = const DoctorCustomerSummary(),
    this.animal = const DoctorAnimalSummary(name: '—', species: '—'),
    this.problemSnippet,
    this.locationSnippet,
  });

  /// Id used for accept/reject PATCH …/requests/:requestId/…
  final String requestId;

  /// Optional case id when backend already created a case shell.
  final String? caseId;

  final String status;
  final String? serviceTypeLabel;
  final DateTime? submittedAt;
  final String? priorityLabel;
  final bool isEmergency;
  final DoctorCustomerSummary customer;
  final DoctorAnimalSummary animal;
  final String? problemSnippet;
  final String? locationSnippet;

  factory DoctorIncomingRequest.fromJson(Map<String, dynamic> json) {
    final requestId =
        _optString(json['requestId']) ??
        _optString(json['id']) ??
        _optString(json['serviceRequestId']) ??
        '';
    final caseId =
        _optString(json['caseId']) ?? _optString(json['doctorCaseId']);
    return DoctorIncomingRequest(
      requestId: requestId,
      caseId: caseId,
      status: _optString(json['status']) ?? 'UNKNOWN',
      serviceTypeLabel:
          _optString(json['serviceTypeLabel']) ??
          _optString(json['serviceType']) ??
          _optString(json['typeLabel']),
      submittedAt:
          _parseDateTime(json['submittedAt']) ??
          _parseDateTime(json['createdAt']),
      priorityLabel:
          _optString(json['priority']) ?? _optString(json['urgency']),
      isEmergency: _optBool(json['isEmergency']),
      customer: DoctorCustomerSummary.fromJson(_asMap(json['customer'])),
      animal: DoctorAnimalSummary.fromJson(_asMap(json['animal'])),
      problemSnippet:
          _optString(json['problemOrSymptom']) ?? _optString(json['problem']),
      locationSnippet:
          _optString(json['locationText']) ?? _optString(json['location']),
    );
  }
}

/// Row from GET /api/mobile/doctor/cases.
class DoctorCaseListItem {
  const DoctorCaseListItem({
    required this.caseId,
    required this.status,
    this.serviceTypeLabel,
    this.submittedAt,
    this.priorityLabel,
    this.isEmergency = false,
    this.customer = const DoctorCustomerSummary(),
    this.animal = const DoctorAnimalSummary(name: '—', species: '—'),
    this.linkedRequestId,
  });

  final String caseId;
  final String status;
  final String? serviceTypeLabel;
  final DateTime? submittedAt;
  final String? priorityLabel;
  final bool isEmergency;
  final DoctorCustomerSummary customer;
  final DoctorAnimalSummary animal;
  final String? linkedRequestId;

  factory DoctorCaseListItem.fromJson(Map<String, dynamic> json) {
    final caseId =
        _optString(json['caseId']) ??
        _optString(json['id']) ??
        _optString(json['doctorCaseId']) ??
        '';
    return DoctorCaseListItem(
      caseId: caseId,
      status: _optString(json['status']) ?? 'UNKNOWN',
      serviceTypeLabel:
          _optString(json['serviceTypeLabel']) ??
          _optString(json['serviceType']),
      submittedAt:
          _parseDateTime(json['submittedAt']) ??
          _parseDateTime(json['updatedAt']),
      priorityLabel:
          _optString(json['priority']) ?? _optString(json['urgency']),
      isEmergency: _optBool(json['isEmergency']),
      customer: DoctorCustomerSummary.fromJson(_asMap(json['customer'])),
      animal: DoctorAnimalSummary.fromJson(_asMap(json['animal'])),
      linkedRequestId:
          _optString(json['requestId']) ?? _optString(json['serviceRequestId']),
    );
  }

  /// Client-side filter for “সক্রিয়” lists when API returns all cases.
  bool get isActiveBn {
    final s = status.toUpperCase();
    return s != 'COMPLETED' &&
        s != 'CANCELLED' &&
        s != 'REJECTED' &&
        s != 'CLOSED';
  }
}

/// GET /api/mobile/doctor/cases/:id
class DoctorCaseDetail {
  const DoctorCaseDetail({
    required this.caseId,
    this.linkedRequestId,
    this.requestIdForActions,
    required this.status,
    this.serviceTypeLabel,
    this.submittedAt,
    this.priorityLabel,
    this.isEmergency = false,
    this.customer = const DoctorCustomerSummary(),
    this.animal = const DoctorAnimalSummary(name: '—', species: '—'),
    this.problemOrSymptom,
    this.description,
    this.locationText,
    this.preferredTime,
    this.existingTreatmentNote,
    this.existingPrescriptionSummary,
  });

  final String caseId;
  final String? linkedRequestId;

  /// Prefer for PATCH …/requests/:id/accept|reject when backend exposes it.
  final String? requestIdForActions;
  final String status;
  final String? serviceTypeLabel;
  final DateTime? submittedAt;
  final String? priorityLabel;
  final bool isEmergency;
  final DoctorCustomerSummary customer;
  final DoctorAnimalSummary animal;
  final String? problemOrSymptom;
  final String? description;
  final String? locationText;
  final String? preferredTime;
  final String? existingTreatmentNote;
  final String? existingPrescriptionSummary;

  String? get effectiveRequestIdForAcceptReject =>
      (linkedRequestId != null && linkedRequestId!.trim().isNotEmpty)
      ? linkedRequestId
      : (requestIdForActions != null && requestIdForActions!.trim().isNotEmpty
            ? requestIdForActions
            : null);

  bool get canAcceptOrReject {
    final s = status.toUpperCase();
    return (s == 'PENDING' || s == 'NEW' || s == 'ASSIGNED_PENDING') &&
        (effectiveRequestIdForAcceptReject?.isNotEmpty ?? false);
  }

  bool get canEditTreatment {
    final s = status.toUpperCase();
    return s != 'COMPLETED' && s != 'CANCELLED' && s != 'REJECTED';
  }

  factory DoctorCaseDetail.fromJson(Map<String, dynamic> json) {
    final nested = _asMap(json['case']) ?? json;
    final caseId =
        _optString(nested['caseId']) ??
        _optString(nested['id']) ??
        _optString(nested['doctorCaseId']) ??
        '';
    final linked =
        _optString(nested['requestId']) ??
        _optString(nested['serviceRequestId']) ??
        _optString(json['requestId']);
    return DoctorCaseDetail(
      caseId: caseId,
      linkedRequestId: linked,
      requestIdForActions:
          _optString(nested['requestIdForActions']) ??
          _optString(nested['incomingRequestId']),
      status: _optString(nested['status']) ?? 'UNKNOWN',
      serviceTypeLabel:
          _optString(nested['serviceTypeLabel']) ??
          _optString(nested['serviceType']),
      submittedAt:
          _parseDateTime(nested['submittedAt']) ??
          _parseDateTime(nested['createdAt']),
      priorityLabel:
          _optString(nested['priority']) ?? _optString(nested['urgency']),
      isEmergency: _optBool(nested['isEmergency']),
      customer: DoctorCustomerSummary.fromJson(_asMap(nested['customer'])),
      animal: DoctorAnimalSummary.fromJson(_asMap(nested['animal'])),
      problemOrSymptom: _optString(nested['problemOrSymptom']),
      description: _optString(nested['description']),
      locationText: _optString(nested['locationText']),
      preferredTime: _optString(nested['preferredTime']),
      existingTreatmentNote:
          _optString(nested['treatmentNote']) ??
          _optString(nested['treatmentNotes']),
      existingPrescriptionSummary:
          _optString(nested['prescription']) ??
          _optString(nested['prescriptionSummary']),
    );
  }
}

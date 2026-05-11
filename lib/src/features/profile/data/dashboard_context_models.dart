// Mobile Profile tab routing — `GET /api/mobile/profile/dashboard-context`.

/// API string values from the backend (`MobileProfileDashboardType`).
enum DashboardType {
  general,
  aiTechnician,
  doctor,
}

DashboardType dashboardTypeFromApiString(Object? raw) {
  if (raw is! String) return DashboardType.general;
  switch (raw.trim()) {
    case 'GENERAL':
      return DashboardType.general;
    case 'AI_TECHNICIAN':
      return DashboardType.aiTechnician;
    case 'DOCTOR':
      return DashboardType.doctor;
    // Legacy payloads — stay on general customer profile + banners
    case 'AI_TECHNICIAN_PENDING':
    case 'AI_TECHNICIAN_REJECTED':
    case 'AI_TECHNICIAN_SUSPENDED':
      return DashboardType.general;
    default:
      return DashboardType.general;
  }
}

class DashboardContextRating {
  const DashboardContextRating({this.average, required this.count});

  final double? average;
  final int count;

  factory DashboardContextRating.fromJson(Object? json) {
    if (json is! Map<String, dynamic>) {
      return const DashboardContextRating(average: null, count: 0);
    }
    final avg = json['average'];
    final c = json['count'];
    return DashboardContextRating(
      average: avg is num ? avg.toDouble() : (avg is String ? double.tryParse(avg) : null),
      count: c is int ? c : int.tryParse('$c') ?? 0,
    );
  }
}

class DashboardContextUser {
  const DashboardContextUser({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    this.avatarUrl,
  });

  final String id;
  final String name;
  final String phone;
  final String email;
  final String? avatarUrl;

  factory DashboardContextUser.fromJson(Object? json) {
    if (json is! Map<String, dynamic>) {
      return const DashboardContextUser(
        id: '',
        name: '',
        phone: '',
        email: '',
      );
    }
    return DashboardContextUser(
      id: '${json['id'] ?? ''}',
      name: '${json['name'] ?? ''}'.trim(),
      phone: '${json['phone'] ?? ''}'.trim(),
      email: '${json['email'] ?? ''}'.trim(),
      avatarUrl: _nullableString(json['avatarUrl']),
    );
  }
}

class DashboardContextAiTechnician {
  const DashboardContextAiTechnician({
    required this.id,
    required this.status,
    this.displayName,
    required this.serviceAreas,
    required this.todayRequestCount,
    required this.pendingRequestCount,
    required this.completedServiceCount,
    required this.rating,
  });

  final String id;
  final String status;
  final String? displayName;
  final List<String> serviceAreas;
  final int todayRequestCount;
  final int pendingRequestCount;
  final int completedServiceCount;
  final DashboardContextRating rating;

  factory DashboardContextAiTechnician.fromJson(Object? json) {
    if (json is! Map<String, dynamic>) {
      return DashboardContextAiTechnician(
        id: '',
        status: '',
        displayName: null,
        serviceAreas: const [],
        todayRequestCount: 0,
        pendingRequestCount: 0,
        completedServiceCount: 0,
        rating: const DashboardContextRating(average: null, count: 0),
      );
    }
    final areas = json['serviceAreas'];
    final list = <String>[];
    if (areas is List) {
      for (final e in areas) {
        if (e is String && e.trim().isNotEmpty) list.add(e.trim());
      }
    }
    return DashboardContextAiTechnician(
      id: '${json['id'] ?? ''}',
      status: '${json['status'] ?? ''}',
      displayName: _nullableString(json['displayName']),
      serviceAreas: list,
      todayRequestCount: _int(json['todayRequestCount']),
      pendingRequestCount: _int(json['pendingRequestCount']),
      completedServiceCount: _int(json['completedServiceCount']),
      rating: DashboardContextRating.fromJson(json['rating']),
    );
  }
}

bool _boolField(Object? raw) {
  if (raw is bool) return raw;
  if (raw is String) {
    final s = raw.trim().toLowerCase();
    return s == 'true' || s == '1' || s == 'yes';
  }
  return false;
}

int? _intOpt(Object? v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.round();
  return int.tryParse('$v');
}

double? _doubleOpt(Object? v) {
  if (v == null) return null;
  if (v is double) return v;
  if (v is num) return v.toDouble();
  return double.tryParse('$v');
}

/// Optional doctor slice from `GET /api/mobile/profile/dashboard-context` (`doctor` key).
///
/// All clinical counters are nullable so the UI can show placeholders until the
/// backend ships full metrics.
class DashboardContextDoctor {
  const DashboardContextDoctor({
    required this.id,
    this.displayName,
    this.specialty,
    this.rating = const DashboardContextRating(average: null, count: 0),
    this.appointmentQueueCount,
    this.emergencyCasesCount,
    this.todayScheduleCount,
    this.activePatientsCount,
    this.pendingPrescriptionsCount,
    this.prescriptionsIssuedThisMonth,
    this.earningsThisMonthBdt,
    this.followUpCasesCount,
    this.telemedicineCapable = false,
    this.telemedicineTodayCount,
    this.completedAppointmentsThisWeek,
    this.acceptsEmergency,
    this.verificationStatus,
    this.verificationRejectionReason,
  });

  final String id;
  final String? displayName;
  final String? specialty;
  final DashboardContextRating rating;
  final int? appointmentQueueCount;
  final int? emergencyCasesCount;
  final int? todayScheduleCount;
  final int? activePatientsCount;
  final int? pendingPrescriptionsCount;
  final int? prescriptionsIssuedThisMonth;
  final double? earningsThisMonthBdt;
  final int? followUpCasesCount;
  final bool telemedicineCapable;
  final int? telemedicineTodayCount;
  final int? completedAppointmentsThisWeek;
  final bool? acceptsEmergency;
  final String? verificationStatus;
  final String? verificationRejectionReason;

  factory DashboardContextDoctor.fromJson(Object? json) {
    if (json is! Map<String, dynamic>) {
      return const DashboardContextDoctor(id: '');
    }
    return DashboardContextDoctor(
      id: '${json['id'] ?? ''}',
      displayName: _nullableString(json['displayName']),
      specialty: _nullableString(json['specialty']),
      rating: DashboardContextRating.fromJson(json['rating']),
      appointmentQueueCount: _intOpt(json['appointmentQueueCount']),
      emergencyCasesCount: _intOpt(json['emergencyCasesCount']),
      todayScheduleCount: _intOpt(json['todayScheduleCount']),
      activePatientsCount: _intOpt(json['activePatientsCount']),
      pendingPrescriptionsCount: _intOpt(json['pendingPrescriptionsCount']),
      prescriptionsIssuedThisMonth: _intOpt(json['prescriptionsIssuedThisMonth']),
      earningsThisMonthBdt: _doubleOpt(json['earningsThisMonthBdt']),
      followUpCasesCount: _intOpt(json['followUpCasesCount']),
      telemedicineCapable: _boolField(json['telemedicineCapable']),
      telemedicineTodayCount: _intOpt(json['telemedicineTodayCount']),
      completedAppointmentsThisWeek: _intOpt(json['completedAppointmentsThisWeek']),
      acceptsEmergency: json['acceptsEmergency'] == null
          ? null
          : _boolField(json['acceptsEmergency']),
      verificationStatus: _nullableString(json['verificationStatus']),
      verificationRejectionReason:
          _nullableString(json['verificationRejectionReason']),
    );
  }

  bool get hasAnyMetrics =>
      appointmentQueueCount != null ||
      emergencyCasesCount != null ||
      todayScheduleCount != null ||
      activePatientsCount != null ||
      pendingPrescriptionsCount != null ||
      prescriptionsIssuedThisMonth != null ||
      earningsThisMonthBdt != null ||
      followUpCasesCount != null ||
      telemedicineTodayCount != null ||
      completedAppointmentsThisWeek != null ||
      verificationStatus != null ||
      verificationRejectionReason != null;
}

class DashboardContext {
  const DashboardContext({
    required this.dashboardType,
    required this.user,
    this.aiTechnician,
    this.doctor,
    this.hasAiTechnicianApplication = false,
    this.aiTechnicianApplicationStatus,
  });

  final DashboardType dashboardType;
  final DashboardContextUser user;
  final DashboardContextAiTechnician? aiTechnician;
  final DashboardContextDoctor? doctor;
  final bool hasAiTechnicianApplication;
  final String? aiTechnicianApplicationStatus;

  factory DashboardContext.fromJson(Object? json) {
    if (json is! Map<String, dynamic>) {
      return const DashboardContext(
        dashboardType: DashboardType.general,
        user: DashboardContextUser(
          id: '',
          name: '',
          phone: '',
          email: '',
        ),
        aiTechnician: null,
        doctor: null,
        hasAiTechnicianApplication: false,
        aiTechnicianApplicationStatus: null,
      );
    }
    final type = dashboardTypeFromApiString(json['dashboardType']);
    final rawDash = json['dashboardType'];
    final rawDashStr = rawDash is String ? rawDash.trim() : '';

    var hasAi = _boolField(json['hasAiTechnicianApplication']);
    if (!hasAi &&
        (rawDashStr == 'AI_TECHNICIAN_PENDING' ||
            rawDashStr == 'AI_TECHNICIAN_REJECTED' ||
            rawDashStr == 'AI_TECHNICIAN_SUSPENDED')) {
      hasAi = true;
    }

    final aiRaw = json['aiTechnician'];
    final statusRaw = json['aiTechnicianApplicationStatus'];
    String? appStatusStr = statusRaw is String && statusRaw.trim().isNotEmpty
        ? statusRaw.trim()
        : null;
    if (appStatusStr == null && rawDashStr == 'AI_TECHNICIAN_REJECTED') {
      appStatusStr = 'REJECTED';
    } else if (appStatusStr == null && rawDashStr == 'AI_TECHNICIAN_SUSPENDED') {
      appStatusStr = 'SUSPENDED';
    } else if (appStatusStr == null && rawDashStr == 'AI_TECHNICIAN_PENDING') {
      appStatusStr = 'UNDER_REVIEW';
    }
    return DashboardContext(
      dashboardType: type,
      user: DashboardContextUser.fromJson(json['user']),
      aiTechnician: aiRaw == null
          ? null
          : DashboardContextAiTechnician.fromJson(aiRaw),
      doctor: json['doctor'] == null
          ? null
          : DashboardContextDoctor.fromJson(json['doctor']),
      hasAiTechnicianApplication: hasAi,
      aiTechnicianApplicationStatus: appStatusStr,
    );
  }
}

String? _nullableString(Object? v) {
  if (v == null) return null;
  final s = '$v'.trim();
  return s.isEmpty ? null : s;
}

int _int(Object? v) {
  if (v is int) return v;
  if (v is num) return v.round();
  return int.tryParse('$v') ?? 0;
}

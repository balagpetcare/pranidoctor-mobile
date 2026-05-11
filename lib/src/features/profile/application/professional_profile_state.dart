import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pranidoctor_mobile/src/features/profile/application/profile_dashboard_providers.dart';
import 'package:pranidoctor_mobile/src/features/profile/data/dashboard_context_models.dart';
import 'package:pranidoctor_mobile/src/features/professional_profile/domain/professional_persona.dart';
import 'package:pranidoctor_mobile/src/features/workspace/domain/professional_role.dart';

enum ProfessionalProfileStatus {
  none,
  draft,
  pending,
  rejected,
  approved,
}

enum ProfessionalProfileRole {
  doctor,
  aiTechnician,
}

extension ProfessionalProfileRoleX on ProfessionalProfileRole {
  ProfessionalRole get workspaceRole {
    switch (this) {
      case ProfessionalProfileRole.doctor:
        return ProfessionalRole.doctor;
      case ProfessionalProfileRole.aiTechnician:
        return ProfessionalRole.aiTechnician;
    }
  }

  ProfessionalPersona get persona {
    switch (this) {
      case ProfessionalProfileRole.doctor:
        return ProfessionalPersona.veterinaryDoctor;
      case ProfessionalProfileRole.aiTechnician:
        return ProfessionalPersona.aiTechnician;
    }
  }

  String get labelBn => workspaceRole.labelBn;

  String get subtitleBn => workspaceRole.subtitleBn;

  IconData get icon => workspaceRole.icon;
}

class ProfessionalProfileState {
  const ProfessionalProfileState({
    required this.status,
    this.role,
    this.rawStatus,
    this.completionPercent,
  });

  final ProfessionalProfileStatus status;
  final ProfessionalProfileRole? role;
  final String? rawStatus;
  final int? completionPercent;

  const ProfessionalProfileState.none()
      : status = ProfessionalProfileStatus.none,
        role = null,
        rawStatus = null,
        completionPercent = null;

  bool get hasApplication => status != ProfessionalProfileStatus.none;

  bool get isApproved => status == ProfessionalProfileStatus.approved;
}

final professionalProfileStateProvider =
    Provider.autoDispose<AsyncValue<ProfessionalProfileState>>((ref) {
  final async = ref.watch(profileDashboardContextProvider);
  return async.whenData(buildProfessionalProfileState);
});

ProfessionalProfileState buildProfessionalProfileState(DashboardContext ctx) {
  final aiState = _buildAiTechnicianState(ctx);
  final doctorState = _buildDoctorState(ctx);

  final preferredRole = switch (ctx.dashboardType) {
    DashboardType.doctor => ProfessionalProfileRole.doctor,
    DashboardType.aiTechnician => ProfessionalProfileRole.aiTechnician,
    _ => null,
  };

  final pick = _pickPrimaryState(
    preferredRole: preferredRole,
    doctorState: doctorState,
    aiState: aiState,
  );

  return pick ?? const ProfessionalProfileState.none();
}

ProfessionalProfileState? _pickPrimaryState({
  required ProfessionalProfileRole? preferredRole,
  required ProfessionalProfileState? doctorState,
  required ProfessionalProfileState? aiState,
}) {
  final states = <ProfessionalProfileState>[
    if (preferredRole == ProfessionalProfileRole.doctor) ...[
      if (doctorState != null) doctorState,
      if (aiState != null) aiState,
    ] else if (preferredRole == ProfessionalProfileRole.aiTechnician) ...[
      if (aiState != null) aiState,
      if (doctorState != null) doctorState,
    ] else ...[
      if (doctorState != null) doctorState,
      if (aiState != null) aiState,
    ],
  ];
  if (states.isEmpty) return null;
  ProfessionalProfileState? best;
  var bestRank = -1;
  for (final state in states) {
    final rank = _statusRank(state.status);
    if (rank > bestRank) {
      bestRank = rank;
      best = state;
    }
  }
  return best;
}

int _statusRank(ProfessionalProfileStatus status) {
  switch (status) {
    case ProfessionalProfileStatus.approved:
      return 5;
    case ProfessionalProfileStatus.pending:
      return 4;
    case ProfessionalProfileStatus.draft:
      return 3;
    case ProfessionalProfileStatus.rejected:
      return 2;
    case ProfessionalProfileStatus.none:
      return 1;
  }
}

ProfessionalProfileState? _buildAiTechnicianState(DashboardContext ctx) {
  if (!ctx.hasAiTechnicianApplication && ctx.aiTechnician == null) {
    if (ctx.dashboardType == DashboardType.aiTechnician) {
      return const ProfessionalProfileState(
        status: ProfessionalProfileStatus.approved,
        role: ProfessionalProfileRole.aiTechnician,
      );
    }
    return null;
  }
  final raw = _mergeStatus(
    ctx.aiTechnician?.status,
    ctx.aiTechnicianApplicationStatus,
  );
  final status =
      _statusFromRaw(raw, fallback: ProfessionalProfileStatus.draft);
  return ProfessionalProfileState(
    status: status,
    role: ProfessionalProfileRole.aiTechnician,
    rawStatus: raw.isEmpty ? null : raw,
  );
}

ProfessionalProfileState? _buildDoctorState(DashboardContext ctx) {
  final doc = ctx.doctor;
  if (doc == null && ctx.dashboardType != DashboardType.doctor) {
    return null;
  }
  if (doc == null && ctx.dashboardType == DashboardType.doctor) {
    return const ProfessionalProfileState(
      status: ProfessionalProfileStatus.approved,
      role: ProfessionalProfileRole.doctor,
    );
  }

  final raw = doc?.verificationStatus?.trim() ?? '';
  final status = raw.isEmpty
      ? ProfessionalProfileStatus.draft
      : _statusFromRaw(raw, fallback: ProfessionalProfileStatus.draft);
  return ProfessionalProfileState(
    status: status,
    role: ProfessionalProfileRole.doctor,
    rawStatus: raw.isEmpty ? null : raw,
  );
}

String _mergeStatus(String? a, String? b) {
  final parts = <String>[];
  if (a != null && a.trim().isNotEmpty) parts.add(a.trim());
  if (b != null && b.trim().isNotEmpty) parts.add(b.trim());
  return parts.join(' ');
}

ProfessionalProfileStatus _statusFromRaw(
  String raw, {
  required ProfessionalProfileStatus fallback,
}) {
  final s = raw.trim().toUpperCase();
  if (s.isEmpty) return fallback;
  if (s.contains('APPROVED') ||
      s.contains('PUBLISHED') ||
      s.contains('VERIFIED') ||
      s.contains('ACTIVE')) {
    return ProfessionalProfileStatus.approved;
  }
  if (s.contains('PENDING') ||
      s.contains('UNDER_REVIEW') ||
      s.contains('IN_REVIEW') ||
      s.contains('SUBMITTED')) {
    return ProfessionalProfileStatus.pending;
  }
  if (s.contains('REJECTED') ||
      s.contains('NEEDS_CORRECTION') ||
      s.contains('NEEDS_MORE_INFO') ||
      s.contains('SUSPENDED') ||
      s.contains('INACTIVE') ||
      s.contains('BLOCKED')) {
    return ProfessionalProfileStatus.rejected;
  }
  if (s.contains('DRAFT')) {
    return ProfessionalProfileStatus.draft;
  }
  return fallback;
}

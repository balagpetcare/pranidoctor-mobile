import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pranidoctor_mobile/src/features/profile/data/dashboard_context_models.dart';
import 'package:pranidoctor_mobile/src/features/profile/application/profile_dashboard_providers.dart';
import 'package:pranidoctor_mobile/src/features/workspace/domain/professional_role.dart';
import 'package:pranidoctor_mobile/src/features/workspace/domain/workspace_entry.dart';
import 'package:pranidoctor_mobile/src/features/workspace/domain/workspace_status.dart';

final availableWorkspacesProvider =
    Provider<AsyncValue<List<WorkspaceEntry>>>((ref) {
  final asyncCtx = ref.watch(profileDashboardContextProvider);
  return asyncCtx.whenData(_entriesFromContext);
});

List<WorkspaceEntry> _entriesFromContext(DashboardContext ctx) {
  final entries = <WorkspaceEntry>[];

  final aiTechStatus = _resolveAiTechnicianStatus(
    ctx.aiTechnician?.status,
    ctx.aiTechnicianApplicationStatus,
  );
  final aiTechVisible = ctx.aiTechnician != null || ctx.hasAiTechnicianApplication;
  if (aiTechVisible) {
    entries.add(
      WorkspaceEntry(
        role: ProfessionalRole.aiTechnician,
        title: ProfessionalRole.aiTechnician.labelBn,
        subtitle: ProfessionalRole.aiTechnician.subtitleBn,
        status: aiTechStatus,
        isVerified: aiTechStatus == WorkspaceStatus.active,
        badge: _badgeForStatus(aiTechStatus),
        routePath: _aiTechnicianRouteForStatus(aiTechStatus),
        ctaLabel: _ctaForStatus(aiTechStatus, activeLabel: 'ড্যাশবোর্ড খুলুন'),
        metadata: {
          'rating': ctx.aiTechnician?.rating.average,
          'pendingRequests': ctx.aiTechnician?.pendingRequestCount,
        },
      ),
    );
  }

  final doctorVisible = ctx.doctor != null || ctx.dashboardType == DashboardType.doctor;
  if (doctorVisible) {
    final doctorStatus =
        _resolveDoctorStatus(ctx.doctor?.verificationStatus ?? '');
    entries.add(
      WorkspaceEntry(
        role: ProfessionalRole.doctor,
        title: ProfessionalRole.doctor.labelBn,
        subtitle: ProfessionalRole.doctor.subtitleBn,
        status: doctorStatus,
        isVerified: doctorStatus == WorkspaceStatus.active,
        badge: _badgeForStatus(doctorStatus),
        routePath: _doctorRouteForStatus(doctorStatus),
        ctaLabel: _ctaForStatus(doctorStatus, activeLabel: 'ড্যাশবোর্ড খুলুন'),
        metadata: {
          'rating': ctx.doctor?.rating.average,
          'queueCount': ctx.doctor?.appointmentQueueCount,
        },
      ),
    );
  }

  return entries;
}

WorkspaceStatus _resolveAiTechnicianStatus(
  String? rawStatus,
  String? rawApplicationStatus,
) {
  final merged = '${rawStatus ?? ''} ${rawApplicationStatus ?? ''}'
      .trim()
      .toUpperCase();
  if (merged.contains('APPROVED') || merged.contains('PUBLISHED')) {
    return WorkspaceStatus.active;
  }
  if (merged.contains('PENDING') ||
      merged.contains('UNDER_REVIEW') ||
      merged.contains('IN_REVIEW')) {
    return WorkspaceStatus.pending;
  }
  if (merged.contains('SUSPENDED') || merged.contains('BLOCKED')) {
    return WorkspaceStatus.suspended;
  }
  if (merged.contains('REJECTED')) {
    return WorkspaceStatus.rejected;
  }
  return WorkspaceStatus.inactive;
}

WorkspaceStatus _resolveDoctorStatus(String rawStatus) {
  final status = rawStatus.trim().toUpperCase();
  if (status.contains('APPROVED') || status.contains('VERIFIED')) {
    return WorkspaceStatus.active;
  }
  if (status.contains('PENDING') || status.contains('UNDER_REVIEW')) {
    return WorkspaceStatus.pending;
  }
  if (status.contains('SUSPENDED') || status.contains('BLOCKED')) {
    return WorkspaceStatus.suspended;
  }
  if (status.contains('REJECTED')) {
    return WorkspaceStatus.rejected;
  }
  return WorkspaceStatus.inactive;
}

WorkspaceBadgeInfo? _badgeForStatus(WorkspaceStatus status) {
  switch (status) {
    case WorkspaceStatus.active:
      return const WorkspaceBadgeInfo(
        label: 'ভেরিফাইড',
        tone: WorkspaceBadgeTone.success,
      );
    case WorkspaceStatus.pending:
      return const WorkspaceBadgeInfo(
        label: 'পরীক্ষাধীন',
        tone: WorkspaceBadgeTone.warning,
      );
    case WorkspaceStatus.suspended:
      return const WorkspaceBadgeInfo(
        label: 'স্থগিত',
        tone: WorkspaceBadgeTone.danger,
      );
    case WorkspaceStatus.rejected:
      return const WorkspaceBadgeInfo(
        label: 'আপডেট দরকার',
        tone: WorkspaceBadgeTone.danger,
      );
    case WorkspaceStatus.inactive:
      return null;
  }
}

String _ctaForStatus(WorkspaceStatus status, {required String activeLabel}) {
  if (status == WorkspaceStatus.active) {
    return activeLabel;
  }
  if (status == WorkspaceStatus.pending) {
    return 'আবেদন অবস্থা';
  }
  if (status == WorkspaceStatus.rejected) {
    return 'আবেদন আপডেট করুন';
  }
  if (status == WorkspaceStatus.suspended) {
    return 'স্থিতি দেখুন';
  }
  return 'বিস্তারিত দেখুন';
}

String _aiTechnicianRouteForStatus(WorkspaceStatus status) {
  switch (status) {
    case WorkspaceStatus.active:
      return ProfessionalRole.aiTechnician.routePath;
    case WorkspaceStatus.pending:
    case WorkspaceStatus.rejected:
    case WorkspaceStatus.suspended:
    case WorkspaceStatus.inactive:
      return '/profile/ai-technician/status';
  }
}

String _doctorRouteForStatus(WorkspaceStatus status) {
  if (status == WorkspaceStatus.active) {
    return ProfessionalRole.doctor.routePath;
  }
  return '/professional/verification/doctor';
}


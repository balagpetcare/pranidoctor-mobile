import 'package:pranidoctor_mobile/src/features/ai_technician_application/presentation/ai_technician_application_entry_screen.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/presentation/ai_technician_application_form_screen.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/presentation/ai_technician_application_status_screen.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/presentation/ai_technician_intro_screen.dart';
import 'package:pranidoctor_mobile/src/features/auth/doctor/presentation/doctor_login_screen.dart';
import 'package:pranidoctor_mobile/src/features/auth/technician/presentation/technician_login_screen.dart';
import 'package:pranidoctor_mobile/src/features/home/home_shell_screen.dart';
import 'package:pranidoctor_mobile/src/features/session/application/session_notifier.dart';
import 'package:pranidoctor_mobile/src/features/session/presentation/admin_gateway_screen.dart';
import 'package:pranidoctor_mobile/src/features/session/presentation/session_forbidden_screen.dart';
import 'package:pranidoctor_mobile/src/features/session/presentation/workspace_gate_screen.dart';
import 'package:pranidoctor_mobile/src/features/technician_ai/presentation/technician_dashboard_screen.dart';
import 'package:pranidoctor_mobile/src/app/workspace/workspace_gate_status.dart';

/// Routes that stay reachable while JWT session exists but workspace role is not resolved yet.
bool isAllowedDuringWorkspaceGate(String path) {
  if (path == WorkspaceGateScreen.routePath) return true;
  if (path == SessionForbiddenScreen.routePath) return true;
  return false;
}

/// AI technician **application** flows (general users) vs approved technician workspace.
bool isAiTechnicianApplicantRoute(String path) {
  if (path == AiTechnicianApplicationEntryScreen.routePath) return true;
  if (path == AiTechnicianIntroScreen.routePath) return true;
  if (path == AiTechnicianApplicationStatusScreen.routePath) return true;
  if (path.startsWith(AiTechnicianApplicationFormScreen.routePath)) return true;
  return false;
}

bool _isDoctorTechnicianPublicEntry(String path) {
  if (path == DoctorLoginScreen.routePath) return true;
  if (path == TechnicianLoginScreen.routePath) return true;
  return false;
}

bool isForbiddenForCustomerRole(String path) {
  if (_isDoctorTechnicianPublicEntry(path)) return false;
  if (path.startsWith('/workspace/')) return true;
  if (path.startsWith('/doctor')) return true;
  if (path.startsWith('/technician')) return true;
  if (path.startsWith('/admin')) return true;
  if (path.startsWith('/profile/ai-technician/')) {
    return !isAiTechnicianApplicantRoute(path);
  }
  return false;
}

/// Primary dashboard destination per persisted/app role.
String defaultLocationForSession(SessionState session) {
  switch (session.role) {
    case AppRole.customer:
    case null:
      return HomeShellScreen.routePath;
    case AppRole.aiTechnician:
      return HomeShellScreen.routePath;
    case AppRole.doctor:
      return HomeShellScreen.routePath;
    case AppRole.technician:
      return TechnicianDashboardScreen.routePath;
    case AppRole.admin:
      return AdminGatewayScreen.routePath;
  }
}

/// GoRouter redirect: workspace separation + customer vs professional areas.
String? redirectForWorkspacePolicy({
  required String location,
  required SessionState auth,
}) {
  final loc = location;

  if (auth.isAuthenticated &&
      auth.workspaceGateStatus == WorkspaceGateStatus.pending &&
      !isAllowedDuringWorkspaceGate(loc)) {
    return WorkspaceGateScreen.routePath;
  }

  final role = auth.role;

  if ((auth.isAuthenticated || auth.professionalShellActive) && role != null) {
    if (loc == HomeShellScreen.routePath && role != AppRole.customer) {
      return null;
    }

    if (role == AppRole.customer &&
        auth.workspaceGateStatus != WorkspaceGateStatus.pending &&
        isForbiddenForCustomerRole(loc)) {
      return SessionForbiddenScreen.routePath;
    }
  }

  return null;
}

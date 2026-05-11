import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pranidoctor_mobile/src/features/ai_technician_application/presentation/ai_technician_dashboard_screen.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/presentation/ai_technician_requests_list_screen.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/presentation/ai_technician_services_list_screen.dart';
import 'package:pranidoctor_mobile/src/features/home/doctor/presentation/doctor_home_screen.dart';
import 'package:pranidoctor_mobile/src/features/session/application/session_notifier.dart';
import 'package:pranidoctor_mobile/src/features/workspace/config/professional_workspace_tab_config.dart';
import 'package:pranidoctor_mobile/src/features/workspace/presentation/tabs/ai_technician_profile_tab_screen.dart';
import 'package:pranidoctor_mobile/src/features/workspace/presentation/tabs/doctor_profile_tab_screen.dart';
import 'package:pranidoctor_mobile/src/features/professional_finance/presentation/professional_wallet_earnings_screen.dart';
import 'package:pranidoctor_mobile/src/features/workspace/presentation/widgets/professional_module_placeholders.dart';

/// Maps tab index → page for [ProfessionalWorkspaceShellScreen].
class ProfessionalWorkspaceTabPage extends ConsumerWidget {
  const ProfessionalWorkspaceTabPage({
    super.key,
    required this.workspaceRole,
    required this.tabIndex,
  });

  final AppRole workspaceRole;
  final int tabIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final defs = professionalNavTabsForRole(workspaceRole);
    if (defs.isEmpty) return const SizedBox.shrink();
    final i = tabIndex.clamp(0, defs.length - 1);
    final id = defs[i].id;

    switch (workspaceRole) {
      case AppRole.aiTechnician:
        return _aiTechnicianPage(context, id);
      case AppRole.doctor:
        return _doctorPage(context, id);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _aiTechnicianPage(BuildContext context, String id) {
    switch (id) {
      case 'dashboard':
        return const AiTechnicianDashboardScreen(embedded: true);
      case 'requests':
        return const AiTechnicianRequestsListScreen(embedded: true);
      case 'services':
        return const AiTechnicianServicesListScreen(embedded: true);
      case 'earnings':
        return const ProfessionalWalletEarningsScreen(embedded: true);
      case 'profile':
        return const AiTechnicianProfileTabScreen();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _doctorPage(BuildContext context, String id) {
    switch (id) {
      case 'dashboard':
        return const DoctorHomeScreen(embedded: true);
      case 'appointments':
        return const DoctorAppointmentsPlaceholder();
      case 'patients':
        return const DoctorPatientsPlaceholder();
      case 'earnings':
        return const ProfessionalWalletEarningsScreen(embedded: true);
      case 'profile':
        return const DoctorProfileTabScreen();
      default:
        return const SizedBox.shrink();
    }
  }
}

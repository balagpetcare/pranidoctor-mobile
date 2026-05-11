import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pranidoctor_mobile/src/features/ai_technician_application/data/ai_technician_models.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/presentation/dashboard/enterprise_technician_dashboard_content.dart';

/// Enterprise AI technician dashboard scroll view (see [EnterpriseTechnicianDashboardContent]).
class AiTechnicianDashboardScrollBody extends ConsumerWidget {
  const AiTechnicianDashboardScrollBody({
    super.key,
    required this.data,
    required this.settingsBusy,
    required this.onEmergencyToggle,
    required this.onOpenRequests,
    required this.onOpenServices,
    required this.onNewService,
    required this.onApplicationStatus,
    required this.onEditProfile,
    required this.onDocuments,
    required this.onSupport,
    required this.onCheckEarnings,
    required this.onUpdateAvailability,
    required this.onOpenEnterpriseInsights,
  });

  final AiTechnicianDashboardData data;
  final bool settingsBusy;
  final ValueChanged<bool> onEmergencyToggle;
  final VoidCallback onOpenRequests;
  final VoidCallback onOpenServices;
  final VoidCallback onNewService;
  final VoidCallback onApplicationStatus;
  final VoidCallback onEditProfile;
  final VoidCallback onDocuments;
  final VoidCallback onSupport;
  final VoidCallback onCheckEarnings;
  final VoidCallback onUpdateAvailability;
  final VoidCallback onOpenEnterpriseInsights;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return EnterpriseTechnicianDashboardContent(
      data: data,
      settingsBusy: settingsBusy,
      onEmergencyToggle: onEmergencyToggle,
      onOpenRequests: onOpenRequests,
      onOpenServices: onOpenServices,
      onNewService: onNewService,
      onApplicationStatus: onApplicationStatus,
      onEditProfile: onEditProfile,
      onDocuments: onDocuments,
      onSupport: onSupport,
      onCheckEarnings: onCheckEarnings,
      onUpdateAvailability: onUpdateAvailability,
      onOpenEnterpriseInsights: onOpenEnterpriseInsights,
    );
  }
}

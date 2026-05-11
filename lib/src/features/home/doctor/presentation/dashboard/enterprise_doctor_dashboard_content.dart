import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_buttons.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_section_header.dart';
import 'package:pranidoctor_mobile/src/features/home/doctor/presentation/dashboard/doctor_dashboard_analytics.dart';
import 'package:pranidoctor_mobile/src/features/home/doctor/presentation/dashboard/doctor_dashboard_kpi_deck.dart';
import 'package:pranidoctor_mobile/src/features/home/doctor/presentation/dashboard/doctor_dashboard_overview_sections.dart';
import 'package:pranidoctor_mobile/src/features/home/doctor/presentation/dashboard/doctor_dashboard_quick_actions.dart';
import 'package:pranidoctor_mobile/src/features/home/doctor/presentation/dashboard/doctor_profile_summary_header.dart';
import 'package:pranidoctor_mobile/src/features/enterprise_insights/presentation/professional_insights_hub_screen.dart';
import 'package:pranidoctor_mobile/src/features/knowledge_hub/presentation/knowledge_hub_home_screen.dart';
import 'package:pranidoctor_mobile/src/features/livestock_booking/presentation/professional_livestock_request_management_screen.dart';
import 'package:pranidoctor_mobile/src/features/profile/data/dashboard_context_models.dart';
import 'package:pranidoctor_mobile/src/features/workspace/application/professional_workspace_tab_provider.dart';
import 'package:pranidoctor_mobile/src/features/workspace/application/workspace_surface_provider.dart';
import 'package:pranidoctor_mobile/src/features/workspace/presentation/professional_workspace_shell_screen.dart';

/// Enterprise veterinary doctor home — metrics from [DashboardContext], availability local.
class EnterpriseDoctorDashboardContent extends ConsumerWidget {
  const EnterpriseDoctorDashboardContent({
    super.key,
    required this.data,
    required this.embedded,
    required this.useShellTabBinder,
    required this.onNewPrescription,
    required this.onUpdateAvailabilityTap,
  });

  final DashboardContext data;
  final bool embedded;

  /// When `true`, only [professionalWorkspaceTabIndexProvider] is updated (already inside shell).
  /// When `false`, switches to professional surface and navigates to the doctor workspace route.
  final bool useShellTabBinder;
  final VoidCallback onNewPrescription;
  final VoidCallback onUpdateAvailabilityTap;

  Future<void> _openProfessionalTab(
    BuildContext context,
    WidgetRef ref,
    int index,
  ) async {
    if (useShellTabBinder) {
      ref.read(professionalWorkspaceTabIndexProvider.notifier).select(index);
      return;
    }
    await ref
        .read(workspaceSurfaceProvider.notifier)
        .setSurface(WorkspaceSurface.professional);
    if (!context.mounted) return;
    ref.read(professionalWorkspaceTabIndexProvider.notifier).select(index);
    if (!context.mounted) return;
    context.go(ProfessionalWorkspaceShellScreen.doctorPath);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doctor = data.doctor;
    final user = data.user;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        if (!embedded) ...[
          Text(
            'চিকিৎসক ড্যাশবোর্ড',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: PraniSpacing.sm),
          Text(
            'অপারেশনাল সারাংশ ও দ্রুত অ্যাকশন',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: PraniSpacing.xl),
        ],
        DoctorProfileSummaryHeader(
          user: user,
          doctor: doctor,
          onUpdateAvailabilityTap: onUpdateAvailabilityTap,
        ),
        const SizedBox(height: PraniSpacing.xl),
        const PraniSectionHeader(
          title: 'মূল সূচক',
          subtitle: 'কিউ, রোগী ও আয়',
          leadingIcon: Icons.speed_rounded,
        ),
        const SizedBox(height: PraniSpacing.md),
        DoctorDashboardKpiDeck(doctor: doctor),
        const SizedBox(height: PraniSpacing.xl),
        DoctorEnterpriseQuickActions(
          onNewPrescription: onNewPrescription,
          onViewPatients: () => _openProfessionalTab(context, ref, 2),
          onUpcomingAppointments: () => _openProfessionalTab(context, ref, 1),
          onEmergencyCases: () => _openProfessionalTab(context, ref, 1),
        ),
        const SizedBox(height: PraniSpacing.md),
        PraniSecondaryButton(
          label: 'সেবা অনুরোধ ও বুকিং',
          icon: Icons.assignment_turned_in_outlined,
          fullWidth: true,
          minimumHeight: 48,
          onPressed: () =>
              context.push(ProfessionalLivestockRequestManagementScreen.routePath),
        ),
        const SizedBox(height: PraniSpacing.xl),
        DoctorAppointmentServiceOverview(
          doctor: doctor,
          onOpenAppointments: () => _openProfessionalTab(context, ref, 1),
        ),
        const SizedBox(height: PraniSpacing.xl),
        DoctorPrescriptionSummaryCard(doctor: doctor),
        const SizedBox(height: PraniSpacing.xl),
        DoctorPatientManagementOverview(
          doctor: doctor,
          onOpenPatients: () => _openProfessionalTab(context, ref, 2),
        ),
        const SizedBox(height: PraniSpacing.xl),
        DoctorTelemedicineArchitectureCard(doctor: doctor),
        const SizedBox(height: PraniSpacing.xl),
        DoctorPerformanceAnalyticsSection(doctor: doctor),
        const SizedBox(height: PraniSpacing.xl),
        const PraniSectionHeader(
          title: 'অতিরিক্ত',
          subtitle: 'শিক্ষণীয় সম্পদ',
          leadingIcon: Icons.menu_book_outlined,
        ),
        const SizedBox(height: PraniSpacing.md),
        PraniSecondaryButton(
          label: 'জ্ঞানকেন্দ্র',
          icon: Icons.menu_book_outlined,
          fullWidth: true,
          minimumHeight: 48,
          onPressed: () => context.push(KnowledgeHubHomeScreen.routePath),
        ),
        const SizedBox(height: PraniSpacing.md),
        PraniSecondaryButton(
          label: 'আয় ও বিলিং (ট্যাব)',
          icon: Icons.account_balance_wallet_outlined,
          fullWidth: true,
          minimumHeight: 48,
          onPressed: () => _openProfessionalTab(context, ref, 3),
        ),
        const SizedBox(height: PraniSpacing.md),
        PraniSecondaryButton(
          label: 'এন্টারপ্রাইজ বিশ্লেষণ ও অফলাইন',
          icon: Icons.insights_outlined,
          fullWidth: true,
          minimumHeight: 48,
          onPressed: () =>
              context.push(ProfessionalInsightsHubScreen.routePath),
        ),
        const SizedBox(height: PraniSpacing.xxl),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_buttons.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_section_header.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/application/ai_technician_dashboard_ui_helpers.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/data/ai_technician_models.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/presentation/dashboard/technician_enterprise_quick_actions.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/presentation/dashboard/technician_kpi_and_overview.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/presentation/dashboard/technician_profile_summary_header.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/presentation/widgets/technician_active_services_section.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/presentation/widgets/technician_status_summary_card.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/presentation/widgets/technician_weekly_performance_card.dart';

/// Enterprise AI technician home — composes reusable sections + existing data providers.
class EnterpriseTechnicianDashboardContent extends ConsumerWidget {
  const EnterpriseTechnicianDashboardContent({
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
    final p = data.profile!;
    final st = data.profileStatus ?? p.status;
    final published = data.isPublished;
    final approvedLike = st == 'APPROVED' || st == 'PUBLISHED';
    final completion = aiTechnicianProfileCompletionPercent(p);
    final providerCode = (data.providerStatus?.trim().isNotEmpty ?? false)
        ? data.providerStatus!.trim()
        : p.providerStatus;

    final effectiveRating = aiTechnicianEffectiveRatingAverage(
      dashboardRatingAverage: data.ratingAverage,
      recentReviews: data.recentReviews,
    );

    final ratingStatValue = effectiveRating != null
        ? effectiveRating.toStringAsFixed(1)
        : '—';

    String ratingHelper() {
      if (data.ratingCount > 0) return '${data.ratingCount}টি রিভিউ';
      if (data.recentReviews.isNotEmpty && data.ratingAverage == null) {
        return 'সাম্প্রতিক রিভিউ থেকে গড়';
      }
      return 'এখনও রিভিউ নেই';
    }

    final completionPct = aiTechnicianCompletionRatePercentLabel(
      completedServicesCount: data.completedServicesCount,
      pendingRequestsCount: data.pendingRequestsCount,
    );

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        TechnicianStatusSummaryCard(
          profile: p,
          applicationStatus: st,
          published: published,
          completionPercent: completion,
          correctionNote: data.correctionNote,
          adminNote: data.adminNote,
          approvedLike: approvedLike,
          providerStatusCodeOverride: providerCode,
        ),
        const SizedBox(height: PraniSpacing.xl),
        TechnicianProfileSummaryHeader(
          profile: p,
          data: data,
          ratingLabel: ratingStatValue,
          ratingHelper: ratingHelper(),
          settingsBusy: settingsBusy,
          onEmergencyToggle: onEmergencyToggle,
        ),
        const SizedBox(height: PraniSpacing.xl),
        const PraniSectionHeader(
          title: 'মূল সূচক',
          subtitle: 'আজ ও সামগ্রিক',
          leadingIcon: Icons.speed_rounded,
        ),
        const SizedBox(height: PraniSpacing.md),
        TechnicianDashboardKpiDeck(data: data, ratingLabel: ratingStatValue),
        const SizedBox(height: PraniSpacing.xl),
        TechnicianServiceRequestOverview(onOpenAll: onOpenRequests),
        const SizedBox(height: PraniSpacing.xl),
        TechnicianMonthlyAndInsightsStrip(data: data),
        const SizedBox(height: PraniSpacing.lg),
        TechnicianNearbyRepeatRow(data: data),
        const SizedBox(height: PraniSpacing.xl),
        if (approvedLike) ...[
          const PraniSectionHeader(
            title: 'পারফরম্যান্স বিশ্লেষণ',
            subtitle: 'রিভিউ ও সম্পাদনা হার',
            leadingIcon: Icons.analytics_outlined,
          ),
          const SizedBox(height: PraniSpacing.md),
          TechnicianWeeklyPerformanceCard(
            ratingAverage: effectiveRating,
            ratingCount: data.ratingCount,
            completedServicesCount: data.completedServicesCount,
            recentReviews: data.recentReviews,
            completionRateValue: completionPct,
            completionRateHint: completionPct != null
                ? 'সম্পন্ন সেবা বনাম অপেক্ষমাণ অনুরোধ (আনুমানিক)'
                : 'সম্পন্ন ও অপেক্ষমাণ উভয়ই শূন্য হলে হার দেখানো যায় না।',
          ),
          const SizedBox(height: PraniSpacing.xl),
        ],
        TechnicianEnterpriseQuickActions(
          approvedLike: approvedLike,
          onStartNewService: onNewService,
          onViewRequests: onOpenRequests,
          onCheckEarnings: onCheckEarnings,
          onUpdateAvailability: onUpdateAvailability,
        ),
        const SizedBox(height: PraniSpacing.md),
        PraniSecondaryButton(
          label: 'এন্টারপ্রাইজ বিশ্লেষণ ও অফলাইন',
          icon: Icons.insights_outlined,
          fullWidth: true,
          onPressed: onOpenEnterpriseInsights,
        ),
        const SizedBox(height: PraniSpacing.xl),
        const PraniSectionHeader(
          title: 'অ্যাকাউন্ট ও সহায়তা',
          subtitle: 'প্রোফাইল ও নথি',
          leadingIcon: Icons.manage_accounts_outlined,
        ),
        const SizedBox(height: PraniSpacing.sm),
        Wrap(
          spacing: PraniSpacing.xs,
          runSpacing: PraniSpacing.xs,
          children: [
            PraniSecondaryButton(
              label: 'প্রোফাইল সম্পাদনা',
              icon: Icons.edit_outlined,
              style: PraniSecondaryStyle.outlined,
              onPressed: onEditProfile,
            ),
            PraniSecondaryButton(
              label: 'নথি',
              icon: Icons.folder_open_outlined,
              style: PraniSecondaryStyle.outlined,
              onPressed: onDocuments,
            ),
            PraniSecondaryButton(
              label: 'সাপোর্ট',
              icon: Icons.support_agent_outlined,
              style: PraniSecondaryStyle.outlined,
              onPressed: onSupport,
            ),
            PraniSecondaryButton(
              label: 'আবেদনের অবস্থা',
              icon: Icons.info_outline_rounded,
              style: PraniSecondaryStyle.outlined,
              onPressed: onApplicationStatus,
            ),
          ],
        ),
        const SizedBox(height: PraniSpacing.xl),
        TechnicianActiveServicesSection(
          approvedLike: approvedLike,
          services: data.activeServices,
          onOpenServicesList: onOpenServices,
          onOpenNewService: onNewService,
        ),
        const SizedBox(height: PraniSpacing.lg),
        PraniSecondaryButton(
          label: 'আবেদনের বিস্তারিত',
          fullWidth: true,
          style: PraniSecondaryStyle.outlined,
          onPressed: onApplicationStatus,
        ),
        const SizedBox(height: PraniSpacing.xl),
      ],
    );
  }
}

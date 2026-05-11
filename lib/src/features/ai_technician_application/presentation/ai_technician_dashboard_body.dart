import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_buttons.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_section_header.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/application/ai_technician_dashboard_ui_helpers.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/application/ai_technician_providers.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/application/ai_technician_request_pipeline_counts.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/data/ai_technician_models.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/presentation/widgets/technician_active_services_section.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/presentation/widgets/technician_dashboard_stat_card.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/presentation/widgets/technician_emergency_availability_card.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/presentation/widgets/technician_earnings_summary_card.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/presentation/widgets/technician_quick_actions_grid.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/presentation/widgets/technician_request_status_grid.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/presentation/widgets/technician_status_summary_card.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/presentation/widgets/technician_weekly_performance_card.dart';

/// Main scrollable dashboard composition (counts via existing list API).
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

  static String? _pipelineDisplay(
    AsyncValue<Map<String, AiTechnicianRequestPipelineCount>> async,
    String tab,
  ) {
    return async.when(
      data: (m) => m[tab]?.displayText,
      loading: () => '…',
      error: (_, _) => null,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = data.profile!;
    final st = data.profileStatus ?? p.status;
    final published = data.isPublished;
    final approvedLike = st == 'APPROVED' || st == 'PUBLISHED';
    final completion = aiTechnicianProfileCompletionPercent(p);
    final totalServicesCount = p.servicesSummary.count > 0
        ? p.servicesSummary.count
        : data.activeServices.length;

    final providerCode = (data.providerStatus?.trim().isNotEmpty ?? false)
        ? data.providerStatus!.trim()
        : p.providerStatus;

    final pipelineAsync = ref.watch(aiTechnicianRequestPipelineCountsProvider);

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
        return 'সাম্প্রতিক রিভিউ থেকে গড় (আনুমানিক)';
      }
      return 'এখনও রিভিউ নেই';
    }

    final completionPct = aiTechnicianCompletionRatePercentLabel(
      completedServicesCount: data.completedServicesCount,
      pendingRequestsCount: data.pendingRequestsCount,
    );

    final requestSubtitle = pipelineAsync.when(
      data: (_) =>
          'ট্যাব অনুযায়ী সংখ্যা বিদ্যমান তালিকা API থেকে (সর্বোচ্চ ২০০/ট্যাব)। আরও অনুরোধ থাকলে সংখ্যার পর + চিহ্ন।',
      loading: () => 'ট্যাব অনুযায়ী সংখ্যা লোড হচ্ছে…',
      error: (_, _) =>
          'ট্যাব অনুযায়ী সংখ্যা আনা যায়নি। তালিকা স্ক্রিনে বিস্তারিত দেখুন।',
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
        const PraniSectionHeader(
          title: 'পারফরম্যান্স সারাংশ',
          subtitle: 'আজ ও সামগ্রিক সংখ্যা',
          leadingIcon: Icons.insights_outlined,
        ),
        const SizedBox(height: PraniSpacing.md),
        TechnicianDashboardKpiGrid(
          items: [
            TechnicianDashboardStatItem(
              title: 'আজকের অনুরোধ',
              value: '${data.todayRequestsCount}',
              icon: Icons.today_outlined,
              helper: 'আজ জমা হওয়া অনুরোধ',
            ),
            TechnicianDashboardStatItem(
              title: 'অপেক্ষমাণ অনুরোধ',
              value: '${data.pendingRequestsCount}',
              icon: Icons.hourglass_empty_rounded,
              helper: 'এখনো সম্পন্ন নয়',
            ),
            TechnicianDashboardStatItem(
              title: 'সম্পন্ন সেবা',
              value: '${data.completedServicesCount}',
              icon: Icons.task_alt_rounded,
              helper: 'মোট সম্পন্ন কাজ',
            ),
            TechnicianDashboardStatItem(
              title: 'মোট আয়',
              value: '৳${data.totalEarningsBdt}',
              icon: Icons.account_balance_wallet_outlined,
              helper: 'সর্বমোট উপার্জন',
            ),
            TechnicianDashboardStatItem(
              title: 'রেটিং',
              value: ratingStatValue,
              icon: Icons.star_rounded,
              helper: ratingHelper(),
            ),
            TechnicianDashboardStatItem(
              title: 'মোট সার্ভিস',
              value: '$totalServicesCount',
              icon: Icons.miscellaneous_services_rounded,
              helper: 'নিবন্ধিত সার্ভিস',
            ),
          ],
        ),
        const SizedBox(height: PraniSpacing.xl),
        PraniSectionHeader(
          title: 'অনুরোধ মনিটরিং',
          subtitle: requestSubtitle,
          leadingIcon: Icons.monitor_heart_outlined,
          actionLabel: 'তালিকা',
          onAction: onOpenRequests,
        ),
        const SizedBox(height: PraniSpacing.sm),
        TechnicianRequestStatusGrid(
          infoTitle: 'অনুরোধের অবস্থা',
          infoSubtitle:
              'প্রতিটি সারিতে ট্যাব অনুযায়ী অনুরোধের সংখ্যা (তালিকার সাথে মিলিয়ে দেখুন)।',
          rows: [
            TechnicianRequestStatusRowData(
              label: 'নতুন অনুরোধ',
              icon: Icons.fiber_new_rounded,
              displayValue: _pipelineDisplay(pipelineAsync, 'new'),
            ),
            TechnicianRequestStatusRowData(
              label: 'গৃহীত',
              icon: Icons.check_circle_outline_rounded,
              displayValue: _pipelineDisplay(pipelineAsync, 'accepted'),
            ),
            TechnicianRequestStatusRowData(
              label: 'চলমান',
              icon: Icons.sync_rounded,
              displayValue: _pipelineDisplay(pipelineAsync, 'ongoing'),
            ),
            TechnicianRequestStatusRowData(
              label: 'সম্পন্ন',
              icon: Icons.done_all_rounded,
              displayValue: _pipelineDisplay(pipelineAsync, 'completed'),
            ),
            TechnicianRequestStatusRowData(
              label: 'বাতিল',
              icon: Icons.cancel_outlined,
              displayValue: _pipelineDisplay(pipelineAsync, 'cancelled'),
            ),
          ],
          onOpenRequests: onOpenRequests,
        ),
        const SizedBox(height: PraniSpacing.xl),
        PraniSectionHeader(
          title: 'জরুরি উপলব্ধতা',
          subtitle: published
              ? 'জরুরি কল গ্রহণের অবস্থা'
              : 'প্রকাশিত প্রোফাইলের পর চালু করা যাবে',
          leadingIcon: Icons.emergency_share_outlined,
        ),
        const SizedBox(height: PraniSpacing.md),
        TechnicianEmergencyAvailabilityCard(
          acceptsEmergency: data.acceptsEmergency,
          published: published,
          busy: settingsBusy,
          profileUpdatedAtIso: p.updatedAt,
          onToggle: onEmergencyToggle,
        ),
        const SizedBox(height: PraniSpacing.xl),
        TechnicianActiveServicesSection(
          approvedLike: approvedLike,
          services: data.activeServices,
          onOpenServicesList: onOpenServices,
          onOpenNewService: onNewService,
        ),
        const SizedBox(height: PraniSpacing.xl),
        const PraniSectionHeader(
          title: 'আয়ের সারাংশ',
          subtitle: 'সময়ভিত্তিক ভাগ শীঘ্রই যুক্ত হবে',
          leadingIcon: Icons.payments_outlined,
        ),
        const SizedBox(height: PraniSpacing.md),
        TechnicianEarningsSummaryCard(
          dashboardConfirmedTotalBdt: data.totalEarningsBdt,
          summaryNote:
              'আজ/সপ্তাহ/মাস ও অপেক্ষমাণ পেমেন্ট ভাগ শীঘ্রই সার্ভার থেকে যুক্ত হবে। নিচের মোট ড্যাশবোর্ডের সাথে মিলিয়ে দেখুন।',
        ),
        const SizedBox(height: PraniSpacing.xl),
        if (approvedLike) ...[
          const PraniSectionHeader(
            title: 'সাম্প্রতিক রিভিউ ও পারফরম্যান্স',
            subtitle: 'সাপ্তাহিক সারাংশ ও মানদণ্ড',
            leadingIcon: Icons.reviews_outlined,
          ),
          const SizedBox(height: PraniSpacing.md),
          TechnicianWeeklyPerformanceCard(
            ratingAverage: effectiveRating,
            ratingCount: data.ratingCount,
            completedServicesCount: data.completedServicesCount,
            recentReviews: data.recentReviews,
            completionRateValue: completionPct,
            completionRateHint: completionPct != null
                ? 'সম্পন্ন সেবা বনাম অপেক্ষমাণ অনুরোধ (ড্যাশবোর্ড সংখ্যা, আনুমানিক)'
                : 'সম্পন্ন ও অপেক্ষমাণ উভয়ই শূন্য হলে হার দেখানো যায় না।',
          ),
          const SizedBox(height: PraniSpacing.xl),
        ],
        const PraniSectionHeader(
          title: 'দ্রুত কাজ',
          subtitle: 'প্রায় ব্যবহৃত নেভিগেশন',
          leadingIcon: Icons.bolt_outlined,
        ),
        const SizedBox(height: PraniSpacing.md),
        TechnicianQuickActionsGrid(
          approvedLike: approvedLike,
          onOpenRequests: onOpenRequests,
          onNewService: onNewService,
          onOpenServices: onOpenServices,
          onEditProfile: onEditProfile,
          onDocuments: onDocuments,
          onSupport: onSupport,
          onApplicationStatus: onApplicationStatus,
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

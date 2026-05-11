import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pranidoctor_mobile/src/design_system/prani_page_insets.dart';
import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_empty_state.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_error_state.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_loading_state.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_scaffold.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/application/ai_technician_dashboard_error_mapper.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/application/ai_technician_providers.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/application/technician_presence_provider.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/data/ai_technician_api_exception.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/presentation/ai_technician_application_entry_screen.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/presentation/ai_technician_application_form_screen.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/presentation/ai_technician_application_status_screen.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/presentation/ai_technician_dashboard_body.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/presentation/ai_technician_services_list_screen.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/presentation/ai_technician_requests_list_screen.dart';
import 'package:pranidoctor_mobile/src/features/profile/application/profile_dashboard_providers.dart';
import 'package:pranidoctor_mobile/src/features/profile/presentation/help_support_screen.dart';
import 'package:pranidoctor_mobile/src/features/professional_finance/presentation/professional_wallet_earnings_screen.dart';
import 'package:pranidoctor_mobile/src/features/enterprise_insights/presentation/professional_insights_hub_screen.dart';
import 'package:pranidoctor_mobile/src/features/workspace/application/professional_workspace_tab_provider.dart';

/// Home for approved / published AI technicians: stats, earnings, services teaser.
class AiTechnicianDashboardScreen extends ConsumerStatefulWidget {
  const AiTechnicianDashboardScreen({super.key, this.embedded = false});

  /// When `true` (Profile tab shell), hide the AppBar back affordance and refresh
  /// the profile routing context after pull-to-refresh.
  final bool embedded;

  static const routePath = '/profile/ai-technician/dashboard';
  static const routeName = 'aiTechnicianDashboard';

  @override
  ConsumerState<AiTechnicianDashboardScreen> createState() =>
      _AiTechnicianDashboardScreenState();
}

class _AiTechnicianDashboardScreenState
    extends ConsumerState<AiTechnicianDashboardScreen> {
  bool _settingsBusy = false;
  bool _scheduledCancelRecovery = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(
        ref.read(technicianPresenceProvider.notifier).hydrateFromPrefs(),
      );
    });
  }

  void _showAvailabilityBottomSheet() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Consumer(
              builder: (context, ref, _) {
                final presence = ref.watch(technicianPresenceProvider);
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'উপস্থিতি আপডেট',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: PraniSpacing.md),
                    SegmentedButton<TechnicianPresenceMode>(
                      segments: [
                        ButtonSegment(
                          value: TechnicianPresenceMode.online,
                          label: Text(TechnicianPresenceMode.online.labelBn),
                          icon: const Icon(Icons.wifi_rounded, size: 18),
                        ),
                        ButtonSegment(
                          value: TechnicianPresenceMode.busy,
                          label: Text(TechnicianPresenceMode.busy.labelBn),
                          icon: const Icon(Icons.do_not_disturb_on_rounded, size: 18),
                        ),
                        ButtonSegment(
                          value: TechnicianPresenceMode.offline,
                          label: Text(TechnicianPresenceMode.offline.labelBn),
                          icon: const Icon(Icons.cloud_off_rounded, size: 18),
                        ),
                      ],
                      selected: {presence},
                      onSelectionChanged: (s) {
                        ref
                            .read(technicianPresenceProvider.notifier)
                            .setMode(s.first);
                      },
                    ),
                    const SizedBox(height: PraniSpacing.lg),
                    Text(
                      'জরুরি সেবা চালু/বন্ধ করতে ড্যাশবোর্ডের প্রোফাইল কার্ডের '
                      '“জরুরি সেবা” অংশ ব্যবহার করুন।',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            height: 1.45,
                          ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> _refresh() async {
    if (!mounted) return;
    ref.invalidate(aiTechnicianDashboardProvider);
    ref.invalidate(aiTechnicianMeProvider);
    ref.invalidate(aiTechnicianRequestPipelineCountsProvider);
    try {
      await ref.read(aiTechnicianDashboardProvider.future);
    } catch (e) {
      if (!mounted) return;
      if (isCancelledAiTechnicianError(e)) {
        return;
      }
    }
    if (!mounted) return;
    if (widget.embedded) {
      ref.invalidate(profileDashboardContextProvider);
    }
  }

  Future<void> _onEmergencyToggle(bool value) async {
    setState(() => _settingsBusy = true);
    try {
      await ref
          .read(aiTechnicianRepositoryProvider)
          .patchSettings(acceptsEmergency: value);
      if (!mounted) return;
      ref.invalidate(aiTechnicianDashboardProvider);
      ref.invalidate(aiTechnicianMeProvider);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('সেটিং সংরক্ষিত হয়েছে')));
      }
    } catch (e) {
      if (!mounted) return;
      final msg = e is AiTechnicianApiException
          ? e.message
          : 'সংরক্ষণ করা যায়নি';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } finally {
      if (mounted) setState(() => _settingsBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(aiTechnicianDashboardProvider);
    final hPad = PraniPageInsets.horizontalPadding(context);

    return PraniScaffold(
      title: widget.embedded ? null : 'এআই টেকনিশিয়ান ড্যাশবোর্ড',
      showBackButton: !widget.embedded,
      resizeToAvoidBottomInset: true,
      padding: EdgeInsets.fromLTRB(
        hPad,
        PraniSpacing.md,
        hPad,
        PraniSpacing.lg,
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: async.when(
          loading: () => const Center(
            child: PraniLoadingState(
              message: 'ড্যাশবোর্ড লোড হচ্ছে…',
              compact: false,
            ),
          ),
          error: (e, _) {
            if (isCancelledAiTechnicianError(e)) {
              if (!_scheduledCancelRecovery) {
                _scheduledCancelRecovery = true;
                SchedulerBinding.instance.addPostFrameCallback((_) {
                  if (!mounted) return;
                  ref.invalidate(aiTechnicianDashboardProvider);
                  ref.invalidate(aiTechnicianRequestPipelineCountsProvider);
                });
              }
              return const Center(
                child: PraniLoadingState(
                  message: 'ড্যাশবোর্ড লোড হচ্ছে…',
                  compact: false,
                ),
              );
            }

            if (e is AiTechnicianApiException) {
              final c = e.code;
              if (c == 'NOT_FOUND' || c == 'NO_PROFILE') {
                SchedulerBinding.instance.addPostFrameCallback((_) {
                  if (!context.mounted) return;
                  context.pushReplacement(
                    AiTechnicianApplicationEntryScreen.routePath,
                  );
                });
                return const Center(
                  child: PraniLoadingState(
                    message: 'ড্যাশবোর্ড লোড হচ্ছে…',
                    compact: false,
                  ),
                );
              }
            }

            final pres = aiTechnicianDashboardErrorPresentation(e);
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                const SizedBox(height: PraniSpacing.section),
                PraniErrorState(
                  title: pres.title,
                  message: pres.message,
                  retryLabel: 'আবার চেষ্টা করুন',
                  onRetry: () {
                    if (!mounted) return;
                    ref.invalidate(aiTechnicianDashboardProvider);
                    ref.invalidate(aiTechnicianRequestPipelineCountsProvider);
                  },
                  boxed: true,
                ),
              ],
            );
          },
          data: (d) {
            _scheduledCancelRecovery = false;
            if (d.profile == null) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const SizedBox(height: PraniSpacing.section),
                  PraniEmptyState(
                    title: 'প্রোফাইল নেই',
                    message:
                        'এআই টেকনিশিয়ান হিসেবে আবেদন শুরু করুন। সঠিক অ্যাকাউন্টে লগইন আছে কিনা নিশ্চিত করুন।',
                    icon: Icons.engineering_outlined,
                    actionLabel: 'আবেদন শুরু করুন',
                    onAction: () => context.pushReplacement(
                      AiTechnicianApplicationFormScreen.routePath,
                      extra: 0,
                    ),
                    boxed: true,
                  ),
                ],
              );
            }
            return AiTechnicianDashboardScrollBody(
              data: d,
              settingsBusy: _settingsBusy,
              onEmergencyToggle: _onEmergencyToggle,
              onOpenRequests: () {
                if (widget.embedded) {
                  ref
                      .read(professionalWorkspaceTabIndexProvider.notifier)
                      .select(1);
                } else {
                  context.push(AiTechnicianRequestsListScreen.routePath);
                }
              },
              onOpenServices: () {
                if (widget.embedded) {
                  ref
                      .read(professionalWorkspaceTabIndexProvider.notifier)
                      .select(2);
                } else {
                  context.push(AiTechnicianServicesListScreen.routePath);
                }
              },
              onNewService: () => context.push(
                '${AiTechnicianServicesListScreen.routePath}/new',
              ),
              onApplicationStatus: () =>
                  context.push(AiTechnicianApplicationStatusScreen.routePath),
              onEditProfile: () {
                final p = d.profile!;
                if (p.isEditable) {
                  context.push(AiTechnicianApplicationFormScreen.routePath);
                } else {
                  context.push(AiTechnicianApplicationStatusScreen.routePath);
                }
              },
              onDocuments: () {
                final p = d.profile!;
                if (p.isEditable) {
                  context.push(AiTechnicianApplicationFormScreen.routePath);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('নথি দেখতে আবেদনের অবস্থা স্ক্রিনে যান।'),
                    ),
                  );
                  context.push(AiTechnicianApplicationStatusScreen.routePath);
                }
              },
              onSupport: () => context.push(HelpSupportScreen.routePath),
              onCheckEarnings: () {
                if (widget.embedded) {
                  ref
                      .read(professionalWorkspaceTabIndexProvider.notifier)
                      .select(3);
                } else {
                  context.push(ProfessionalWalletEarningsScreen.routePath);
                }
              },
              onUpdateAvailability: _showAvailabilityBottomSheet,
              onOpenEnterpriseInsights: () =>
                  context.push(ProfessionalInsightsHubScreen.routePath),
            );
          },
        ),
      ),
    );
  }
}

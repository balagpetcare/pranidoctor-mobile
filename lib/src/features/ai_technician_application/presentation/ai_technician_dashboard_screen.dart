import 'package:flutter/material.dart';
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
import 'package:pranidoctor_mobile/src/features/ai_technician_application/data/ai_technician_api_exception.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/presentation/ai_technician_application_form_screen.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/presentation/ai_technician_application_status_screen.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/presentation/ai_technician_dashboard_body.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/presentation/ai_technician_services_list_screen.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/presentation/ai_technician_requests_list_screen.dart';
import 'package:pranidoctor_mobile/src/features/profile/presentation/help_support_screen.dart';

/// Home for approved / published AI technicians: stats, earnings, services teaser.
class AiTechnicianDashboardScreen extends ConsumerStatefulWidget {
  const AiTechnicianDashboardScreen({super.key});

  static const routePath = '/profile/ai-technician/dashboard';
  static const routeName = 'aiTechnicianDashboard';

  @override
  ConsumerState<AiTechnicianDashboardScreen> createState() =>
      _AiTechnicianDashboardScreenState();
}

class _AiTechnicianDashboardScreenState
    extends ConsumerState<AiTechnicianDashboardScreen> {
  bool _settingsBusy = false;

  Future<void> _refresh() async {
    ref.invalidate(aiTechnicianDashboardProvider);
    ref.invalidate(aiTechnicianMeProvider);
    ref.invalidate(aiTechnicianRequestPipelineCountsProvider);
    await ref.read(aiTechnicianDashboardProvider.future);
    if (!mounted) return;
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
      title: 'এআই টেকনিশিয়ান ড্যাশবোর্ড',
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
            child: PraniLoadingState(message: 'লোড হচ্ছে…', compact: false),
          ),
          error: (e, _) {
            final pres = aiTechnicianDashboardErrorPresentation(e);
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                const SizedBox(height: PraniSpacing.section),
                PraniErrorState(
                  title: pres.title,
                  message: pres.message,
                  retryLabel: 'আবার চেষ্টা',
                  onRetry: () {
                    ref.invalidate(aiTechnicianDashboardProvider);
                    ref.invalidate(aiTechnicianRequestPipelineCountsProvider);
                  },
                  boxed: true,
                ),
              ],
            );
          },
          data: (d) {
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
              onOpenRequests: () =>
                  context.push(AiTechnicianRequestsListScreen.routePath),
              onOpenServices: () =>
                  context.push(AiTechnicianServicesListScreen.routePath),
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
            );
          },
        ),
      ),
    );
  }
}

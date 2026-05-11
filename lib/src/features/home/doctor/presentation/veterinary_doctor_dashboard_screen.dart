import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pranidoctor_mobile/src/app/screen_padding.dart';
import 'package:pranidoctor_mobile/src/design_system/prani_page_insets.dart';
import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_error_state.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_loading_state.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_scaffold.dart';
import 'package:pranidoctor_mobile/src/features/home/doctor/application/doctor_availability_notifier.dart';
import 'package:pranidoctor_mobile/src/features/home/doctor/presentation/dashboard/enterprise_doctor_dashboard_content.dart';
import 'package:pranidoctor_mobile/src/features/profile/application/profile_dashboard_providers.dart';
import 'package:pranidoctor_mobile/src/features/profile/data/dashboard_context_models.dart';
import 'package:pranidoctor_mobile/src/features/workspace/presentation/widgets/professional_module_placeholders.dart';

/// Veterinary doctor enterprise dashboard (workspace shell + profile gate + standalone).
class VeterinaryDoctorDashboardScreen extends ConsumerStatefulWidget {
  const VeterinaryDoctorDashboardScreen({
    super.key,
    this.embedded = false,

    /// When already inside [ProfessionalWorkspaceShellScreen] doctor tab — tab switches only.
    /// When opened from the customer Profile gate, set `false` so shortcuts open the workspace.
    this.useShellTabBinder = false,
  });

  final bool embedded;
  final bool useShellTabBinder;

  @override
  ConsumerState<VeterinaryDoctorDashboardScreen> createState() =>
      _VeterinaryDoctorDashboardScreenState();
}

class _VeterinaryDoctorDashboardScreenState
    extends ConsumerState<VeterinaryDoctorDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(
        ref.read(doctorAvailabilityProvider.notifier).hydrateFromPrefs(),
      );
    });
  }

  Future<void> _refresh() async {
    ref.invalidate(profileDashboardContextProvider);
    try {
      await ref.read(profileDashboardContextProvider.future);
    } catch (_) {}
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
                final availability = ref.watch(doctorAvailabilityProvider);
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'উপস্থিতি ও জরুরি',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: PraniSpacing.md),
                    SegmentedButton<DoctorPresenceMode>(
                      segments: [
                        ButtonSegment(
                          value: DoctorPresenceMode.online,
                          label: Text(DoctorPresenceMode.online.labelBn),
                          icon: const Icon(Icons.wifi_rounded, size: 18),
                        ),
                        ButtonSegment(
                          value: DoctorPresenceMode.busy,
                          label: Text(DoctorPresenceMode.busy.labelBn),
                          icon: const Icon(Icons.do_not_disturb_on_rounded, size: 18),
                        ),
                        ButtonSegment(
                          value: DoctorPresenceMode.offline,
                          label: Text(DoctorPresenceMode.offline.labelBn),
                          icon: const Icon(Icons.cloud_off_rounded, size: 18),
                        ),
                      ],
                      selected: {availability.mode},
                      onSelectionChanged: (s) {
                        ref
                            .read(doctorAvailabilityProvider.notifier)
                            .setMode(s.first);
                      },
                    ),
                    const SizedBox(height: PraniSpacing.lg),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('জরুরি কেস গ্রহণ (লোকাল)'),
                      value: availability.emergencyAvailable,
                      onChanged: (v) {
                        ref
                            .read(doctorAvailabilityProvider.notifier)
                            .setEmergencyAvailable(v);
                      },
                    ),
                    const SizedBox(height: PraniSpacing.sm),
                    Text(
                      'সার্ভার-নিশ্চিত জরুরি সেটিং এলে প্রোফাইল কার্ডে চিপ হিসেবে দেখা যাবে।',
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

  void _onNewPrescription() {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (ctx) => Scaffold(
          appBar: AppBar(
            title: const Text('নতুন প্রেসক্রিপশন'),
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
          ),
          body: const DoctorPrescriptionComposerPlaceholder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final asyncCtx = ref.watch(profileDashboardContextProvider);
    final hPad = PraniPageInsets.horizontalPadding(context);

    return PraniScaffold(
      title: widget.embedded ? null : 'চিকিৎসক ড্যাশবোর্ড',
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
        child: asyncCtx.when(
          loading: () => const Center(
            child: PraniLoadingState(
              message: 'ড্যাশবোর্ড লোড হচ্ছে…',
              compact: false,
            ),
          ),
          error: (e, _) => Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: pdReadableMaxWidth(context)),
              child: PraniErrorState(
                title: 'লোড করা যায়নি',
                message: 'অনুগ্রহ করে নেটওয়ার্ক যাচাই করে আবার চেষ্টা করুন।',
                retryLabel: 'আবার চেষ্টা',
                onRetry: () {
                  ref.invalidate(profileDashboardContextProvider);
                },
                boxed: true,
              ),
            ),
          ),
          data: (ctx) {
            if (ctx.dashboardType != DashboardType.doctor) {
              return Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: pdReadableMaxWidth(context),
                  ),
                  child: PraniErrorState(
                    title: 'প্রোফাইল মিলছে না',
                    message:
                        'এই অ্যাকাউন্টে চিকিৎসক ড্যাশবোর্ড সক্রিয় নয়। প্রোফাইল রিফ্রেশ করুন।',
                    retryLabel: 'রিফ্রেশ',
                    onRetry: () {
                      ref.invalidate(profileDashboardContextProvider);
                    },
                    boxed: true,
                  ),
                ),
              );
            }
            return EnterpriseDoctorDashboardContent(
              data: ctx,
              embedded: widget.embedded,
              useShellTabBinder: widget.useShellTabBinder,
              onNewPrescription: _onNewPrescription,
              onUpdateAvailabilityTap: _showAvailabilityBottomSheet,
            );
          },
        ),
      ),
    );
  }
}

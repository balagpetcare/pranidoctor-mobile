import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_buttons.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_error_state.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_info_card.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_loading_state.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/application/ai_technician_providers.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/data/ai_technician_api_exception.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/presentation/ai_technician_application_form_screen.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/presentation/ai_technician_application_status_screen.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/presentation/ai_technician_dashboard_screen.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/presentation/ai_technician_intro_screen.dart';
import 'package:pranidoctor_mobile/src/features/auth/login_entry_screen.dart';
import 'package:pranidoctor_mobile/src/features/session/application/session_notifier.dart';

/// Resolver from Profile: loads technician state, then replaces with
/// wizard / status / dashboard — or prompts login when unauthenticated.
class AiTechnicianApplicationEntryScreen extends ConsumerStatefulWidget {
  const AiTechnicianApplicationEntryScreen({super.key});

  static const routePath = '/profile/ai-technician/entry';
  static const routeName = 'aiTechnicianApplicationEntry';

  @override
  ConsumerState<AiTechnicianApplicationEntryScreen> createState() =>
      _AiTechnicianApplicationEntryScreenState();
}

class _AiTechnicianApplicationEntryScreenState
    extends ConsumerState<AiTechnicianApplicationEntryScreen> {
  Object? _error;
  bool _busy = true;
  bool _needsLogin = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _resolve());
  }

  Future<void> _resolve() async {
    if (!mounted) return;
    setState(() {
      _busy = true;
      _error = null;
      _needsLogin = false;
    });

    if (!ref.read(sessionNotifierProvider).isAuthenticated) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _needsLogin = true;
      });
      return;
    }

    try {
      ref.invalidate(aiTechnicianMeProvider);
      final me = await ref.read(aiTechnicianMeProvider.future);
      if (!mounted) return;

      if (kDebugMode) {
        debugPrint(
          'AiTechnician ENTRY API success: profile=${me.profile != null}',
        );
      }
      if (me.profile == null) {
        if (kDebugMode) {
          debugPrint(
            'AiTechnician ENTRY route=/profile/ai-technician/entry → intro (new user)',
          );
        }
        if (!context.mounted) return;
        context.pushReplacement(AiTechnicianIntroScreen.routePath);
        return;
      }

      final p = me.profile!;
      if (kDebugMode) {
        debugPrint(
          'AiTechnician ENTRY route=/profile/ai-technician/entry '
          'status=${p.status} isEditable=${p.isEditable}',
        );
      }

      if (p.isEditable) {
        final prefs = await SharedPreferences.getInstance();
        final uid = p.userId;
        int? initialFromPrefs;
        if (prefs.getString(
              AiTechnicianApplicationFormScreen.kWizardUserPrefsKey,
            ) ==
            uid) {
          final s = AiTechnicianApplicationFormScreen.readWizardStepForResume(
            prefs,
            uid,
          );
          if (s != null) {
            initialFromPrefs = s.clamp(
              0,
              AiTechnicianApplicationFormScreen.totalSteps - 1,
            );
          }
        }
        if (!mounted) return;
        if (kDebugMode) {
          debugPrint(
            'AiTechnician ENTRY → form initialStep=$initialFromPrefs '
            '(DRAFT / editable)',
          );
        }
        if (!context.mounted) return;
        context.pushReplacement(
          AiTechnicianApplicationFormScreen.routePath,
          extra: initialFromPrefs,
        );
        return;
      }

      final st = p.status;
      if (st == 'APPROVED' || st == 'PUBLISHED') {
        if (!mounted) return;
        if (kDebugMode) {
          debugPrint('AiTechnician ENTRY → dashboard status=$st');
        }
        if (!context.mounted) return;
        context.pushReplacement(AiTechnicianDashboardScreen.routePath);
        return;
      }

      const submittedLike = {
        'SUBMITTED',
        'UNDER_REVIEW',
        'PENDING_VERIFICATION',
      };
      if (submittedLike.contains(st)) {
        if (!mounted) return;
        if (kDebugMode) {
          debugPrint(
            'AiTechnician ENTRY → status (submitted pipeline) status=$st',
          );
        }
        if (!context.mounted) return;
        context.pushReplacement(AiTechnicianApplicationStatusScreen.routePath);
        return;
      }

      if (!mounted) return;
      if (kDebugMode) {
        debugPrint('AiTechnician ENTRY → status (default) status=$st');
      }
      if (!context.mounted) return;
      context.pushReplacement(AiTechnicianApplicationStatusScreen.routePath);
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('AiTechnician ENTRY API error: $e\n$st');
      }
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = e;
      });
    }
  }

  String _errorMessage(Object e) {
    if (e is AiTechnicianApiException) {
      final c = e.code;
      if (c == 'FORBIDDEN') {
        return 'গ্রাহক প্রোফাইল প্রয়োজন বা অনুমতি নেই। প্রোফাইল ট্যাবে যান।';
      }
      if (c == 'UNAUTHORIZED') {
        return 'লগইন প্রয়োজন বা সেশন শেষ হয়েছে। পুনরায় লগইন করুন।';
      }
      if (c == 'NETWORK' || c == 'TIMEOUT') {
        return 'ইন্টারনেট সংযোগ পরীক্ষা করে আবার চেষ্টা করুন।';
      }
      return e.message;
    }
    // For non-API exceptions (provider errors, state issues, etc.)
    if (kDebugMode) {
      return 'আবেদন লোড করতে সমস্যা: ${e.toString()}';
    }
    return 'আবেদন লোড করা যায়নি। আবার চেষ্টা করুন।';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        title: const Text('এআই টেকনিশিয়ান আবেদন'),
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
      ),
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _busy
                  ? const Center(
                      child: PraniLoadingState(
                        message: 'আপনার আবেদন অবস্থা লোড হচ্ছে…',
                        compact: false,
                      ),
                    )
                  : _needsLogin
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 400),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              PraniInfoCard(
                                title: 'লগইন প্রয়োজন',
                                subtitle:
                                    'এআই টেকনিশিয়ান আবেদন বা ড্যাশবোর্ড দেখতে মোবাইল নম্বর দিয়ে প্রবেশ করুন।',
                                leadingIcon: const Icon(
                                  Icons.lock_outline_rounded,
                                ),
                                padding: const EdgeInsets.all(20),
                              ),
                              const SizedBox(height: PraniSpacing.lg),
                              PraniPrimaryButton(
                                label: 'লগইন / OTP',
                                onPressed: () => context.push(
                                  '${LoginEntryScreen.routePath}?next=${Uri.encodeComponent(AiTechnicianApplicationEntryScreen.routePath)}',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 400),
                          child: PraniErrorState(
                            title: 'খোলা যায়নি',
                            message: _errorMessage(_error ?? 'অজানা ত্রুটি'),
                            retryLabel: 'আবার চেষ্টা',
                            onRetry: _resolve,
                            boxed: true,
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

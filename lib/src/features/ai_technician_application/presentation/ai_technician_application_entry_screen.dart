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
import 'package:pranidoctor_mobile/src/features/ai_technician_application/data/ai_technician_models.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/presentation/ai_technician_application_form_screen.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/presentation/ai_technician_application_status_screen.dart';
import 'package:pranidoctor_mobile/src/features/workspace/application/workspace_surface_provider.dart';
import 'package:pranidoctor_mobile/src/features/workspace/presentation/professional_workspace_shell_screen.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (kDebugMode) {
        debugPrint('AiTechnician ENTRY: start route=${AiTechnicianApplicationEntryScreen.routePath}');
      }
      _resolve();
    });
  }

  /// [forceRefresh]: invalidate cached `/me` before loading (user retry).
  Future<void> _resolve({bool forceRefresh = false, int recoverAttempt = 0}) async {
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
      if (kDebugMode) {
        debugPrint('AiTechnician ENTRY: decision=needs_login');
      }
      return;
    }

    try {
      if (forceRefresh) {
        ref.invalidate(aiTechnicianMeProvider);
      }
      final me = await ref.read(aiTechnicianMeProvider.future);
      if (!mounted) return;

      if (kDebugMode) {
        final label = me.profile == null
            ? 'not_found'
            : '${me.profile!.status} editable=${me.profile!.isEditable}';
        debugPrint('AiTechnician ENTRY: me=$label');
      }

      await _routeFromMe(me);
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('AiTechnician ENTRY: error=$e attempt=$recoverAttempt\n$st');
      }

      if (isCancelledAiTechnicianError(e) && recoverAttempt < 2) {
        if (kDebugMode) {
          debugPrint(
            'AiTechnician ENTRY: status=cancelled → retry '
            'attempt=${recoverAttempt + 1}',
          );
        }
        await Future<void>.delayed(const Duration(milliseconds: 80));
        if (!mounted) return;
        return _resolve(forceRefresh: true, recoverAttempt: recoverAttempt + 1);
      }

      if (isCancelledAiTechnicianError(e)) {
        if (kDebugMode) {
          debugPrint(
            'AiTechnician ENTRY: cancelled after retries — staying idle',
          );
        }
        if (!mounted) return;
        setState(() {
          _busy = false;
          _error = null;
        });
        return;
      }

      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = e;
      });
      if (kDebugMode) {
        debugPrint('AiTechnician ENTRY: decision=error_ui');
      }
    }
  }

  Future<void> _routeFromMe(AiTechnicianMeResult me) async {
    if (me.profile == null) {
      if (kDebugMode) {
        debugPrint(
          'AiTechnician ENTRY: decision=not_found → ${AiTechnicianApplicationFormScreen.routePath}',
        );
      }
      if (!mounted) return;
      if (!context.mounted) return;
      context.pushReplacement(
        AiTechnicianApplicationFormScreen.routePath,
        extra: 0,
      );
      return;
    }

    final p = me.profile!;
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
          'AiTechnician ENTRY: decision=draft_form step=$initialFromPrefs',
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
        debugPrint(
          'AiTechnician ENTRY: decision=approved → ${ProfessionalWorkspaceShellScreen.technicianPath}',
        );
      }
      await ref
          .read(workspaceSurfaceProvider.notifier)
          .setSurface(WorkspaceSurface.professional);
      if (!mounted) return;
      context.pushReplacement(ProfessionalWorkspaceShellScreen.technicianPath);
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
          'AiTechnician ENTRY: decision=pending_pipeline → ${AiTechnicianApplicationStatusScreen.routePath}',
        );
      }
      if (!context.mounted) return;
      context.pushReplacement(AiTechnicianApplicationStatusScreen.routePath);
      return;
    }

    if (!mounted) return;
    if (kDebugMode) {
      debugPrint(
        'AiTechnician ENTRY: decision=status_default → ${AiTechnicianApplicationStatusScreen.routePath} ($st)',
      );
    }
    if (!context.mounted) return;
    context.pushReplacement(AiTechnicianApplicationStatusScreen.routePath);
  }

  String _errorMessage(Object e) {
    if (e is AiTechnicianApiException) {
      final c = e.code;
      if (c == 'CANCELLED') {
        return 'অনুরোধ সম্পূর্ণ হয়নি। আবার চেষ্টা করুন।';
      }
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
                            onRetry: () => _resolve(forceRefresh: true),
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

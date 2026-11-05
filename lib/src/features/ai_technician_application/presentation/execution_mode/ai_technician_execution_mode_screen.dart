import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:pranidoctor_mobile/src/design_system/prani_page_insets.dart';
import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_scaffold.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/presentation/execution_mode/execution_engine_widgets.dart';

class AiTechnicianExecutionModeScreen extends StatefulWidget {
  const AiTechnicianExecutionModeScreen({super.key});

  static const routePath = '/profile/ai-technician/execution';

  @override
  State<AiTechnicianExecutionModeScreen> createState() =>
      _AiTechnicianExecutionModeScreenState();
}

class _AiTechnicianExecutionModeScreenState
    extends State<AiTechnicianExecutionModeScreen> {
  int _stepIndex = 0;
  bool _stepVerified = false;
  bool _locked = true;
  bool _timerRunning = false;
  Duration _elapsed = Duration.zero;
  Timer? _ticker;
  final TextEditingController _notes = TextEditingController();

  final List<ExecutionStepModel> _steps = ExecutionModeCopy.demoSteps;

  @override
  void dispose() {
    _ticker?.cancel();
    _notes.dispose();
    super.dispose();
  }

  void _toggleTimer() {
    if (_timerRunning) {
      _ticker?.cancel();
      setState(() => _timerRunning = false);
      return;
    }
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _elapsed += const Duration(seconds: 1));
    });
    setState(() => _timerRunning = true);
  }

  void _resetStepState() {
    _stepVerified = false;
    _locked = true;
  }

  void _goNext() {
    if (_locked) return;
    if (_stepIndex < _steps.length - 1) {
      setState(() {
        _stepIndex += 1;
        _resetStepState();
      });
    } else {
      _showCompletionSheet();
    }
  }

  void _goPrevious() {
    if (_stepIndex == 0) return;
    setState(() {
      _stepIndex -= 1;
      _resetStepState();
    });
  }

  void _showCompletionSheet() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => ExecutionCompletionSheet(
        title: ExecutionModeCopy.completionTitle,
        subtitle: ExecutionModeCopy.completionSubtitle,
        onConfirm: () => ctx.pop(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hPad = PraniPageInsets.horizontalPadding(context);
    final step = _steps[_stepIndex];

    return PraniScaffold(
      title: ExecutionModeCopy.screenTitle,
      padding: EdgeInsets.zero,
      backgroundColor: Theme.of(context).colorScheme.surface,
      bottomNavigationBar: ExecutionActionBar(
        isLocked: _locked,
        onPrevious: _goPrevious,
        onNext: _goNext,
        onEmergency: () => showDialog<void>(
          context: context,
          builder: (ctx) => ExecutionEmergencyDialog(
            title: ExecutionModeCopy.emergencyTitle,
            message: ExecutionModeCopy.emergencyMessage,
            onConfirm: () => ctx.pop(),
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(
          hPad,
          PraniSpacing.md,
          hPad,
          PraniSpacing.lg,
        ),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: ExecutionHeader(
                title: step.title,
                subtitle: ExecutionModeCopy.headerSubtitle,
                offlineLabel: ExecutionModeCopy.offlineLabel,
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.only(top: PraniSpacing.lg),
              sliver: SliverToBoxAdapter(
                child: ExecutionProgressTracker(
                  currentStep: _stepIndex + 1,
                  totalSteps: _steps.length,
                  completionPercent: (_stepIndex + 1) / _steps.length,
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.only(top: PraniSpacing.lg),
              sliver: SliverToBoxAdapter(
                child: ExecutionInstructionCard(
                  instruction: step.instruction,
                  onVoicePlayback: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(ExecutionModeCopy.voicePlaceholder),
                      ),
                    );
                  },
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.only(top: PraniSpacing.lg),
              sliver: SliverToBoxAdapter(
                child: ExecutionTimerCard(
                  elapsed: _elapsed,
                  isRunning: _timerRunning,
                  onToggle: _toggleTimer,
                  onReset: () => setState(() => _elapsed = Duration.zero),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.only(top: PraniSpacing.lg),
              sliver: SliverToBoxAdapter(
                child: ExecutionToolChips(tools: step.requiredTools),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.only(top: PraniSpacing.lg),
              sliver: SliverToBoxAdapter(
                child: ExecutionSafetyAlert(message: step.safetyNote),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.only(top: PraniSpacing.lg),
              sliver: SliverToBoxAdapter(
                child: ExecutionAiGuidanceCard(
                  title: ExecutionModeCopy.aiTitle,
                  message: ExecutionModeCopy.aiMessage,
                  onAction: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(ExecutionModeCopy.aiPlaceholder),
                      ),
                    );
                  },
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.only(top: PraniSpacing.lg),
              sliver: SliverToBoxAdapter(
                child: ExecutionMediaReferenceCard(
                  title: ExecutionModeCopy.mediaTitle,
                  subtitle: ExecutionModeCopy.mediaSubtitle,
                  onOpen: () => showModalBottomSheet<void>(
                    context: context,
                    showDragHandle: true,
                    builder: (ctx) => const ExecutionMediaReferenceSheet(),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.only(top: PraniSpacing.lg),
              sliver: SliverToBoxAdapter(
                child: ExecutionNotesCard(
                  controller: _notes,
                  label: ExecutionModeCopy.notesLabel,
                  helper: ExecutionModeCopy.notesHelper,
                  onVoiceAssist: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(ExecutionModeCopy.notesAiPlaceholder),
                      ),
                    );
                  },
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.only(top: PraniSpacing.lg),
              sliver: SliverToBoxAdapter(
                child: ExecutionEvidenceCard(
                  title: ExecutionModeCopy.photoTitle,
                  subtitle: ExecutionModeCopy.photoSubtitle,
                  onCapture: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(ExecutionModeCopy.photoPlaceholder),
                      ),
                    );
                  },
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.only(top: PraniSpacing.lg),
              sliver: SliverToBoxAdapter(
                child: ExecutionStepVerification(
                  verified: _stepVerified,
                  locked: _locked,
                  onVerify: (v) {
                    setState(() {
                      _stepVerified = v;
                      _locked = !v;
                    });
                  },
                  onUnlock: () => setState(() => _locked = false),
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: PraniSpacing.xxl),
            ),
          ],
        ),
      ),
    );
  }
}

class ExecutionModeCopy {
  static const String screenTitle = 'এক্সিকিউশন মোড';
  static const String headerSubtitle = 'লাইভ ইনসেমিনেশন প্রটোকল';
  static const String offlineLabel = 'অফলাইন সক্রিয়';
  static const String voicePlaceholder = 'ভয়েস গাইড শীঘ্রই যুক্ত হবে';
  static const String aiPlaceholder = 'AI রিয়েল-টাইম গাইডেন্স শীঘ্রই উপলব্ধ';
  static const String notesAiPlaceholder = 'AI নোট সহায়ক শীঘ্রই যুক্ত হবে';
  static const String photoPlaceholder = 'ফটো ক্যাপচার শীঘ্রই উপলব্ধ';
  static const String completionTitle = 'মিশন সম্পন্ন';
  static const String completionSubtitle =
      'সব ধাপ যাচাই হয়েছে। রিপোর্ট জমা দিতে প্রস্তুত।';
  static const String emergencyTitle = 'জরুরি সহায়তা';
  static const String emergencyMessage =
      'জরুরি সহায়তার জন্য কল বা সুপারভাইজারকে জানান।';
  static const String aiTitle = 'AI গাইডেন্স';
  static const String aiMessage = 'প্রধান ভেট প্রটোকল ও টাইমিং অনুসরণ করুন।';
  static const String mediaTitle = 'রেফারেন্স মিডিয়া';
  static const String mediaSubtitle = 'প্রয়োজন হলে দেখুন';
  static const String notesLabel = 'ফিল্ড নোট';
  static const String notesHelper = 'সংক্ষিপ্ত পর্যবেক্ষণ লিখুন';
  static const String photoTitle = 'ফটো প্রমাণ';
  static const String photoSubtitle = 'প্রয়োজনে ছবি যুক্ত করুন';

  static const List<ExecutionStepModel> demoSteps = [
    ExecutionStepModel(
      title: 'ধাপ ১',
      instruction: 'প্রাণীর অবস্থান স্থির করুন এবং জীবাণুমুক্ত প্রস্তুতি নিশ্চিত করুন।',
      requiredTools: ['গ্লাভস', 'স্যানিটাইজার', 'লুব্রিকেন্ট'],
      safetyNote: 'প্রাণী শান্ত না হলে সাহায্য নিন।',
    ),
    ExecutionStepModel(
      title: 'ধাপ ২',
      instruction: 'সঠিক টাইমিং নিশ্চিত করে ইনসেমিনেশন শুরু করুন।',
      requiredTools: ['স্ট্রো', 'থার্মাল কন্টেইনার'],
      safetyNote: 'ভুল প্রবেশ করলে তাৎক্ষণিকভাবে থামুন।',
    ),
    ExecutionStepModel(
      title: 'ধাপ ৩',
      instruction: 'ইনসেমিনেশন সম্পন্ন করে ধাপ যাচাই করুন।',
      requiredTools: ['টাইমার', 'ফর্ম নোট'],
      safetyNote: 'অস্বাভাবিক প্রতিক্রিয়ায় জরুরি প্রটোকল অনুসরণ করুন।',
    ),
  ];
}

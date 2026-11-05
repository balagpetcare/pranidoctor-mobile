import 'package:flutter/material.dart';

import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_buttons.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_form_fields.dart';

class ExecutionStepModel {
  const ExecutionStepModel({
    required this.title,
    required this.instruction,
    required this.requiredTools,
    required this.safetyNote,
  });

  final String title;
  final String instruction;
  final List<String> requiredTools;
  final String safetyNote;
}

class ExecutionHeader extends StatelessWidget {
  const ExecutionHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.offlineLabel,
  });

  final String title;
  final String subtitle;
  final String offlineLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(PraniSpacing.xl),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(PraniRadius.lg),
        boxShadow: PraniShadows.elevatedCardShadow(
          Theme.of(context).brightness,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: PraniTextStyles.pageTitleProminent(
                    scheme,
                    Theme.of(context).textTheme,
                  ),
                ),
                const SizedBox(height: PraniSpacing.xs),
                Text(
                  subtitle,
                  style: PraniTextStyles.bodyMuted(
                    scheme,
                    Theme.of(context).textTheme,
                  ),
                ),
              ],
            ),
          ),
          ExecutionStatusChip(label: offlineLabel),
        ],
      ),
    );
  }
}

class ExecutionStatusChip extends StatelessWidget {
  const ExecutionStatusChip({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: PraniSpacing.md,
        vertical: PraniSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: scheme.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(PraniRadius.pill),
      ),
      child: Text(
        label,
        style: PraniTextStyles.label(scheme, Theme.of(context).textTheme)
            .copyWith(color: scheme.primary),
      ),
    );
  }
}

class ExecutionEngineCopy {
  static const String stepLabel = 'ধাপ';
  static const String voiceLabel = 'ভয়েস নির্দেশনা';
  static const String toolsLabel = 'প্রয়োজনীয় টুল';
  static const String timerStart = 'স্টার্ট';
  static const String timerPause = 'পজ';
  static const String timerReset = 'রিসেট';
  static const String aiSettings = 'সেটিংস';
  static const String captureLabel = 'ধরুন';
  static const String verifyTitle = 'ধাপ যাচাই';
  static const String verifyChecklist = 'ধাপ সম্পন্ন নিশ্চিত করুন';
  static const String unlockStep = 'লকড ধাপ আনলক';
  static const String previousStep = 'পূর্বের ধাপ';
  static const String nextStep = 'পরের ধাপ';
  static const String verifyStep = 'ভেরিফাই করুন';
  static const String emergency = 'জরুরি';
  static const String mediaComingSoon = 'মিডিয়া শীঘ্রই যুক্ত হবে';
  static const String completionConfirm = 'ঠিক আছে';
  static const String emergencyDismiss = 'বন্ধ করুন';
}

class ExecutionProgressTracker extends StatelessWidget {
  const ExecutionProgressTracker({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.completionPercent,
  });

  final int currentStep;
  final int totalSteps;
  final double completionPercent;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(PraniSpacing.lg),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(PraniRadius.md),
        boxShadow: PraniShadows.elevatedCardShadow(
          Theme.of(context).brightness,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${ExecutionEngineCopy.stepLabel} $currentStep / $totalSteps',
            style: PraniTextStyles.subheading(
              scheme,
              Theme.of(context).textTheme,
            ),
          ),
          const SizedBox(height: PraniSpacing.xs),
          ClipRRect(
            borderRadius: BorderRadius.circular(PraniRadius.pill),
            child: LinearProgressIndicator(
              value: completionPercent.clamp(0, 1),
              minHeight: 8,
              backgroundColor: PraniColors.surfaceAlt,
            ),
          ),
        ],
      ),
    );
  }
}

class ExecutionInstructionCard extends StatelessWidget {
  const ExecutionInstructionCard({
    super.key,
    required this.instruction,
    required this.onVoicePlayback,
  });

  final String instruction;
  final VoidCallback onVoicePlayback;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final width = MediaQuery.sizeOf(context).width;
    final fontSize = width < 360 ? 20.0 : 22.0;
    return Container(
      padding: const EdgeInsets.all(PraniSpacing.xl),
      decoration: BoxDecoration(
        color: scheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(PraniRadius.lg),
        boxShadow: PraniShadows.elevatedCardShadow(
          Theme.of(context).brightness,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.record_voice_over, color: scheme.primary),
              const SizedBox(width: PraniSpacing.sm),
              Text(
                ExecutionEngineCopy.voiceLabel,
                style: PraniTextStyles.subheading(
                  scheme,
                  Theme.of(context).textTheme,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: onVoicePlayback,
                icon: Icon(Icons.play_circle_fill, color: scheme.primary),
              ),
            ],
          ),
          const SizedBox(height: PraniSpacing.md),
          Text(
            instruction,
            style: PraniTextStyles.display(
              scheme,
              Theme.of(context).textTheme,
            ).copyWith(fontSize: fontSize),
          ),
        ],
      ),
    );
  }
}

class ExecutionTimerCard extends StatelessWidget {
  const ExecutionTimerCard({
    super.key,
    required this.elapsed,
    required this.isRunning,
    required this.onToggle,
    required this.onReset,
  });

  final Duration elapsed;
  final bool isRunning;
  final VoidCallback onToggle;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(PraniSpacing.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(PraniRadius.md),
        boxShadow: PraniShadows.elevatedCardShadow(
          Theme.of(context).brightness,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.timer_outlined,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: PraniSpacing.sm),
          Expanded(
            child: Text(
              _formatTimer(elapsed),
              style: PraniTextStyles.sectionTitleProminent(
                Theme.of(context).colorScheme,
                Theme.of(context).textTheme,
              ),
            ),
          ),
          TextButton(
            onPressed: onToggle,
            child: Text(
              isRunning
                  ? ExecutionEngineCopy.timerPause
                  : ExecutionEngineCopy.timerStart,
            ),
          ),
          TextButton(
            onPressed: onReset,
            child: const Text(ExecutionEngineCopy.timerReset),
          ),
        ],
      ),
    );
  }
}

class ExecutionToolChips extends StatelessWidget {
  const ExecutionToolChips({super.key, required this.tools});

  final List<String> tools;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          ExecutionEngineCopy.toolsLabel,
          style: PraniTextStyles.subheading(
            Theme.of(context).colorScheme,
            Theme.of(context).textTheme,
          ),
        ),
        const SizedBox(height: PraniSpacing.sm),
        Wrap(
          spacing: PraniSpacing.sm,
          runSpacing: PraniSpacing.sm,
          children: tools
              .map((tool) => Chip(label: Text(tool)))
              .toList(),
        ),
      ],
    );
  }
}

class ExecutionSafetyAlert extends StatelessWidget {
  const ExecutionSafetyAlert({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(PraniSpacing.lg),
      decoration: BoxDecoration(
        color: PraniColors.warningBright.withOpacity(0.2),
        borderRadius: BorderRadius.circular(PraniRadius.md),
        border: Border.all(color: PraniColors.warning),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: PraniColors.warning),
          const SizedBox(width: PraniSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: PraniTextStyles.body(
                scheme,
                Theme.of(context).textTheme,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ExecutionAiGuidanceCard extends StatelessWidget {
  const ExecutionAiGuidanceCard({
    super.key,
    required this.title,
    required this.message,
    required this.onAction,
  });

  final String title;
  final String message;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(PraniSpacing.lg),
      decoration: BoxDecoration(
        color: scheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(PraniRadius.md),
        boxShadow: PraniShadows.elevatedCardShadow(
          Theme.of(context).brightness,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.auto_awesome, color: scheme.primary),
          const SizedBox(width: PraniSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: PraniTextStyles.subheading(
                    scheme,
                    Theme.of(context).textTheme,
                  ),
                ),
                const SizedBox(height: PraniSpacing.xs),
                Text(
                  message,
                  style: PraniTextStyles.bodyMuted(
                    scheme,
                    Theme.of(context).textTheme,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onAction,
            child: const Text(ExecutionEngineCopy.aiSettings),
          ),
        ],
      ),
    );
  }
}

class ExecutionMediaReferenceCard extends StatelessWidget {
  const ExecutionMediaReferenceCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onOpen,
  });

  final String title;
  final String subtitle;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(PraniSpacing.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(PraniRadius.md),
        boxShadow: PraniShadows.elevatedCardShadow(
          Theme.of(context).brightness,
        ),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.video_library_outlined),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onOpen,
      ),
    );
  }
}

class ExecutionNotesCard extends StatelessWidget {
  const ExecutionNotesCard({
    super.key,
    required this.controller,
    required this.label,
    required this.helper,
    required this.onVoiceAssist,
  });

  final TextEditingController controller;
  final String label;
  final String helper;
  final VoidCallback onVoiceAssist;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(PraniSpacing.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(PraniRadius.md),
        boxShadow: PraniShadows.elevatedCardShadow(
          Theme.of(context).brightness,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: PraniTextStyles.subheading(
                  Theme.of(context).colorScheme,
                  Theme.of(context).textTheme,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: onVoiceAssist,
                icon: const Icon(Icons.mic),
              ),
            ],
          ),
          const SizedBox(height: PraniSpacing.sm),
          PraniTextArea(
            controller: controller,
            minLines: 3,
            maxLines: 4,
            decoration: InputDecoration(helperText: helper),
          ),
        ],
      ),
    );
  }
}

class ExecutionEvidenceCard extends StatelessWidget {
  const ExecutionEvidenceCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onCapture,
  });

  final String title;
  final String subtitle;
  final VoidCallback onCapture;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(PraniSpacing.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(PraniRadius.md),
        boxShadow: PraniShadows.elevatedCardShadow(
          Theme.of(context).brightness,
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.photo_camera_outlined),
          const SizedBox(width: PraniSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: PraniTextStyles.subheading(
                    Theme.of(context).colorScheme,
                    Theme.of(context).textTheme,
                  ),
                ),
                const SizedBox(height: PraniSpacing.xs),
                Text(
                  subtitle,
                  style: PraniTextStyles.bodyMuted(
                    Theme.of(context).colorScheme,
                    Theme.of(context).textTheme,
                  ),
                ),
              ],
            ),
          ),
          PraniSecondaryButton(
            label: ExecutionEngineCopy.captureLabel,
            onPressed: onCapture,
            style: PraniSecondaryStyle.outlined,
          ),
        ],
      ),
    );
  }
}

class ExecutionStepVerification extends StatelessWidget {
  const ExecutionStepVerification({
    super.key,
    required this.verified,
    required this.locked,
    required this.onVerify,
    required this.onUnlock,
  });

  final bool verified;
  final bool locked;
  final ValueChanged<bool> onVerify;
  final VoidCallback onUnlock;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(PraniSpacing.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(PraniRadius.md),
        boxShadow: PraniShadows.elevatedCardShadow(
          Theme.of(context).brightness,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ExecutionEngineCopy.verifyTitle,
            style: PraniTextStyles.subheading(
              Theme.of(context).colorScheme,
              Theme.of(context).textTheme,
            ),
          ),
          const SizedBox(height: PraniSpacing.sm),
          CheckboxListTile(
            value: verified,
            onChanged: (v) => onVerify(v ?? false),
            title: const Text(ExecutionEngineCopy.verifyChecklist),
            contentPadding: EdgeInsets.zero,
          ),
          if (locked)
            TextButton(
              onPressed: onUnlock,
              child: const Text(ExecutionEngineCopy.unlockStep),
            ),
        ],
      ),
    );
  }
}

class ExecutionActionBar extends StatelessWidget {
  const ExecutionActionBar({
    super.key,
    required this.isLocked,
    required this.onPrevious,
    required this.onNext,
    required this.onEmergency,
  });

  final bool isLocked;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onEmergency;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          PraniSpacing.xl,
          PraniSpacing.md,
          PraniSpacing.xl,
          PraniSpacing.md,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: PraniShadows.elevatedCardShadow(
            Theme.of(context).brightness,
          ),
        ),
        child: Row(
          children: [
            PraniSecondaryButton(
              label: ExecutionEngineCopy.previousStep,
              onPressed: onPrevious,
              style: PraniSecondaryStyle.outlined,
            ),
            const SizedBox(width: PraniSpacing.sm),
            Expanded(
              child: PraniPrimaryButton(
                label: isLocked
                    ? ExecutionEngineCopy.verifyStep
                    : ExecutionEngineCopy.nextStep,
                onPressed: isLocked ? null : onNext,
              ),
            ),
            const SizedBox(width: PraniSpacing.sm),
            PraniSecondaryButton(
              label: ExecutionEngineCopy.emergency,
              onPressed: onEmergency,
              style: PraniSecondaryStyle.outlined,
            ),
          ],
        ),
      ),
    );
  }
}

class ExecutionMediaReferenceSheet extends StatelessWidget {
  const ExecutionMediaReferenceSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(PraniSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.video_library_outlined, size: 48),
          SizedBox(height: PraniSpacing.sm),
          Text(ExecutionEngineCopy.mediaComingSoon),
        ],
      ),
    );
  }
}

class ExecutionCompletionSheet extends StatelessWidget {
  const ExecutionCompletionSheet({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onConfirm,
  });

  final String title;
  final String subtitle;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(PraniSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified_rounded, size: 48, color: PraniColors.success),
          const SizedBox(height: PraniSpacing.sm),
          Text(
            title,
            style: PraniTextStyles.sectionTitleProminent(
              Theme.of(context).colorScheme,
              Theme.of(context).textTheme,
            ),
          ),
          const SizedBox(height: PraniSpacing.xs),
          Text(subtitle),
          const SizedBox(height: PraniSpacing.lg),
          PraniPrimaryButton(
            label: ExecutionEngineCopy.completionConfirm,
            onPressed: onConfirm,
          ),
        ],
      ),
    );
  }
}

class ExecutionEmergencyDialog extends StatelessWidget {
  const ExecutionEmergencyDialog({
    super.key,
    required this.title,
    required this.message,
    required this.onConfirm,
  });

  final String title;
  final String message;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: onConfirm,
          child: const Text(ExecutionEngineCopy.emergencyDismiss),
        ),
      ],
    );
  }
}

String _formatTimer(Duration value) {
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  final minutes = twoDigits(value.inMinutes.remainder(60));
  final seconds = twoDigits(value.inSeconds.remainder(60));
  return '$minutes:$seconds';
}

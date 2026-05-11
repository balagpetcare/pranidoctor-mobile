import 'package:flutter/material.dart';

import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_premium_card.dart';
import 'package:pranidoctor_mobile/src/features/professional_verification/domain/verification_workflow_phase.dart';

class VerificationRejectionBanner extends StatelessWidget {
  const VerificationRejectionBanner({
    super.key,
    required this.phase,
    required this.message,
    this.canResubmit = false,
    this.onResubmit,
  });

  final VerificationWorkflowPhase phase;
  final String? message;
  final bool canResubmit;
  final VoidCallback? onResubmit;

  @override
  Widget build(BuildContext context) {
    if (message == null || message!.trim().isEmpty) return const SizedBox.shrink();
    final scheme = Theme.of(context).colorScheme;
    final showResubmit = onResubmit != null && canResubmit;

    return PraniPremiumCard(
      padding: const EdgeInsets.all(PraniSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: scheme.error),
              const SizedBox(width: PraniSpacing.sm),
              Expanded(
                child: Text(
                  'যাচাইকরণ বার্তা',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: PraniSpacing.sm),
          Text(
            message!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.45),
          ),
          if (showResubmit) ...[
            const SizedBox(height: PraniSpacing.md),
            FilledButton.tonalIcon(
              onPressed: onResubmit,
              icon: const Icon(Icons.upload_file_outlined),
              label: const Text('পুনঃজমা / ফর্ম খুলুন'),
            ),
          ],
        ],
      ),
    );
  }
}

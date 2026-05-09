import 'package:flutter/material.dart';

import '../../../../core/constants/pd_spacing.dart';
import '../../../../core/widgets/pd_app_card.dart';
import '../../../../core/widgets/pd_buttons.dart';

/// Prominent জরুরি ডাক্তার call-to-action — pushes booking wizard.
class CustomerEmergencyCtaCard extends StatelessWidget {
  const CustomerEmergencyCtaCard({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return PdAppCard(
      useShadow: true,
      padding: const EdgeInsets.all(PdSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.emergency_share_rounded,
                color: scheme.error,
                size: 28,
              ),
              const SizedBox(width: PdSpacing.sm),
              Expanded(
                child: Text(
                  'জরুরি ডাক্তার',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: PdSpacing.xs),
          Text(
            'জরুরি অবস্থায় দ্রুত সেবার অনুরোধ জমা দিন। পরবর্তী ধাপে সেবার ধরন নির্বাচন করতে পারবেন।',
            style: textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: PdSpacing.md),
          PdPrimaryButton(
            label: 'জরুরি সেবা শুরু করুন',
            icon: Icon(Icons.arrow_forward, color: scheme.onPrimary, size: 20),
            onPressed: onPressed,
          ),
        ],
      ),
    );
  }
}

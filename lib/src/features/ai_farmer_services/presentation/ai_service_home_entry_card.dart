import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_premium_card.dart';
import 'package:pranidoctor_mobile/src/features/ai_farmer_services/presentation/ai_technician_finder_screen.dart';

/// Home promo card — opens AI technician finder (area-based listing).
class AiServiceHomeEntryCard extends StatelessWidget {
  const AiServiceHomeEntryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return PraniPremiumCard(
      child: InkWell(
        onTap: () => context.push(AiTechnicianFinderScreen.routePath),
        borderRadius: BorderRadius.circular(PraniRadius.lg),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: PraniSpacing.md,
            horizontal: PraniSpacing.sm,
          ),
          child: Row(
            children: [
              Icon(Icons.biotech_outlined, size: 40, color: scheme.primary),
              const SizedBox(width: PraniSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'কৃত্রিম প্রজনন সেবা',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: PraniSpacing.xs),
                    Text(
                      'আপনার এলাকায় যাচাইকৃত এআই টেকনিশিয়ান খুঁজুন',
                      style: textTheme.bodyMedium?.copyWith(
                        height: 1.35,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: scheme.primary),
            ],
          ),
        ),
      ),
    );
  }
}

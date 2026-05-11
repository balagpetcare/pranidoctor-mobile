import 'package:flutter/material.dart';

import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_form_card.dart';

/// Status summary for workflows (e.g. AI technician application) — one headline, optional
/// code chip, message, and optional suffix blocks (notes, actions).
class PraniStatusCard extends StatelessWidget {
  const PraniStatusCard({
    super.key,
    required this.headline,
    required this.message,
    this.badgeLabel,
    this.suffix = const [],
  });

  final String headline;
  final String message;

  /// Short status code shown as a chip (e.g. `SUBMITTED`).
  final String? badgeLabel;

  /// Extra widgets below the main message (notes, banners).
  final List<Widget> suffix;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return PraniFormCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: PraniSpacing.sm,
            runSpacing: PraniSpacing.xs,
            children: [
              Text(
                headline,
                style: PraniTextStyles.cardTitleProminent(scheme, textTheme),
              ),
              if (badgeLabel != null && badgeLabel!.trim().isNotEmpty)
                Chip(
                  label: Text(
                    badgeLabel!.trim(),
                    style: textTheme.labelMedium?.copyWith(
                      color: scheme.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  backgroundColor: scheme.primaryContainer,
                  side: BorderSide.none,
                  padding: const EdgeInsets.symmetric(
                    horizontal: PraniSpacing.sm,
                  ),
                ),
            ],
          ),
          const SizedBox(height: PraniSpacing.md),
          Text(message, style: PraniTextStyles.body(scheme, textTheme)),
          ...suffix,
        ],
      ),
    );
  }
}

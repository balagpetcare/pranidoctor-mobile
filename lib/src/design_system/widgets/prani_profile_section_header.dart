import 'package:flutter/material.dart';

import '../prani_tokens.dart';

/// Accent-led section title for grouped settings / profile blocks.
class PraniProfileSectionHeader extends StatelessWidget {
  const PraniProfileSectionHeader({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        2,
        PraniSpacing.md,
        4,
        PraniSpacing.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: scheme.primary,
              borderRadius: BorderRadius.circular(3),
            ),
            child: const SizedBox(width: 4, height: 20),
          ),
          const SizedBox(width: PraniSpacing.md),
          Expanded(
            child: Text(
              title,
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: scheme.onSurface,
                letterSpacing: -0.15,
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

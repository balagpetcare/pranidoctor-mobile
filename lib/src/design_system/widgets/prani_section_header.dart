import 'package:flutter/material.dart';

import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';

/// Title row with optional trailing action — use for home sections and lists.
class PraniSectionHeader extends StatelessWidget {
  const PraniSectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
    this.titleColor,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Color? titleColor;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final c = titleColor ?? scheme.onSurface;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            title,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: c,
              height: 1.25,
            ),
          ),
        ),
        if (actionLabel != null && onAction != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: PraniSpacing.sm,
                vertical: PraniSpacing.xs,
              ),
              minimumSize: const Size(48, 44),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(actionLabel!),
          ),
      ],
    );
  }
}

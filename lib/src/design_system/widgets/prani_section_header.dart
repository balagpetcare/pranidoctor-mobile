import 'package:flutter/material.dart';

import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';

/// Title row with optional subtitle, icon, and trailing action — home sections and lists.
class PraniSectionHeader extends StatelessWidget {
  const PraniSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.leadingIcon,
    this.actionLabel,
    this.onAction,
    this.titleColor,
  });

  final String title;
  final String? subtitle;
  final IconData? leadingIcon;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Color? titleColor;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final c = titleColor ?? scheme.onSurface;

    final titleBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: c,
            height: 1.25,
          ),
        ),
        if (subtitle != null && subtitle!.trim().isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: PraniSpacing.xxs),
            child: Text(
              subtitle!,
              style: PraniTextStyles.caption(scheme, textTheme),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (leadingIcon != null) ...[
          Icon(leadingIcon, color: scheme.primary, size: 22),
          const SizedBox(width: PraniSpacing.sm),
        ],
        Expanded(child: titleBlock),
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

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
    this.compact = false,
  });

  final String title;
  final String? subtitle;
  final IconData? leadingIcon;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Color? titleColor;

  /// Smaller title / tighter subtitle — multi-step wizards on phones.
  final bool compact;

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
          style: compact
              ? PraniTextStyles.subheading(
                  scheme,
                  textTheme,
                ).copyWith(fontSize: 16, height: 1.28, color: c)
              : PraniTextStyles.sectionTitleProminent(
                  scheme,
                  textTheme,
                ).copyWith(color: c),
        ),
        if (subtitle != null && subtitle!.trim().isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: PraniSpacing.xxs),
            child: Text(
              subtitle!,
              style: PraniTextStyles.formHelper(scheme, textTheme),
              maxLines: compact ? 2 : 3,
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

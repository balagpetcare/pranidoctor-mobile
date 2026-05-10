import 'package:flutter/material.dart';

import '../prani_tokens.dart';

/// Title stack for [AppBar.title] or standalone page headers (Bengali-friendly line heights).
class PraniAppHeader extends StatelessWidget {
  const PraniAppHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.actions,
    this.icon,
    this.crossAlign = CrossAxisAlignment.start,
  });

  final String title;
  final String? subtitle;

  /// Optional widget before title row (e.g. logo chip).
  final Widget? icon;

  /// When embedded in a standalone row (not AppBar), optional leading slot.
  final Widget? leading;

  final List<Widget>? actions;
  final CrossAxisAlignment crossAlign;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final titleStyle = PraniTextStyles.title(scheme, textTheme);
    final subStyle = PraniTextStyles.bodyMuted(scheme, textTheme);

    final titleColumn = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: crossAlign,
      children: [
        Text(
          title,
          style: titleStyle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
          const SizedBox(height: PraniSpacing.xxs),
          Text(
            subtitle!,
            style: subStyle,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );

    if (leading == null &&
        icon == null &&
        (actions == null || actions!.isEmpty)) {
      return titleColumn;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (leading != null) ...[
          leading!,
          const SizedBox(width: PraniSpacing.sm),
        ],
        if (icon != null) ...[icon!, const SizedBox(width: PraniSpacing.sm)],
        Expanded(child: titleColumn),
        if (actions != null) ...actions!,
      ],
    );
  }
}

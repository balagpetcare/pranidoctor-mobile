import 'package:flutter/material.dart';

import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';

class AccountMenuTile extends StatelessWidget {
  const AccountMenuTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.iconColor,
    this.titleColor,
    this.semanticLabel,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? titleColor;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final resolvedIconColor = iconColor ?? scheme.primary;
    final resolvedTitleColor = titleColor ?? scheme.onSurface;

    return Semantics(
      label: semanticLabel ?? title,
      button: onTap != null,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 14,
        ),
        minVerticalPadding: 12,
        leading: Icon(icon, color: resolvedIconColor),
        title: Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: PraniTextStyles.subheading(
            scheme,
            textTheme,
          ).copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            height: 1.3,
            color: resolvedTitleColor,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: PraniTextStyles.bodyMuted(
                  scheme,
                  textTheme,
                ).copyWith(fontSize: 14, height: 1.35),
              )
            : null,
        trailing: trailing ?? const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

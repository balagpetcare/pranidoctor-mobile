import 'package:flutter/material.dart';

import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_premium_card.dart';

class AccountMenuSection extends StatelessWidget {
  const AccountMenuSection({
    super.key,
    required this.title,
    required this.tiles,
    this.helperText,
  });

  final String title;
  final List<Widget> tiles;
  final String? helperText;

  List<Widget> _withDividers(List<Widget> children) {
    if (children.isEmpty) return const <Widget>[];
    final widgets = <Widget>[];
    for (var i = 0; i < children.length; i += 1) {
      widgets.add(children[i]);
      if (i != children.length - 1) {
        widgets.add(const Divider(height: 1));
      }
    }
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Semantics(
      container: true,
      label: title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: scheme.onSurface,
              letterSpacing: 0.1,
            ),
          ),
          if (helperText != null) ...[
            const SizedBox(height: 4),
            Text(
              helperText!,
              style: textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
                height: 1.35,
              ),
            ),
          ],
          const SizedBox(height: PraniSpacing.sm),
          PraniPremiumCard(
            padding: EdgeInsets.zero,
            child: Column(children: _withDividers(tiles)),
          ),
        ],
      ),
    );
  }
}

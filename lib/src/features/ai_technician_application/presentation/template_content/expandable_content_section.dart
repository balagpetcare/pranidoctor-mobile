import 'package:flutter/material.dart';

import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';

/// Collapsible block for long clinical / editorial sections.
class ExpandableContentSection extends StatelessWidget {
  const ExpandableContentSection({
    super.key,
    required this.title,
    required this.child,
    this.initiallyExpanded = false,
    this.semanticsLabel,
    this.onExpansionChanged,
  });

  final String title;
  final Widget child;
  final bool initiallyExpanded;
  final String? semanticsLabel;

  /// Fires when the user expands or collapses this tile.
  final ValueChanged<bool>? onExpansionChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Semantics(
      container: true,
      label: semanticsLabel ?? title,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: Material(
          color: scheme.surfaceContainerHighest.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(PraniRadius.lg),
          clipBehavior: Clip.antiAlias,
          child: ExpansionTile(
            key: PageStorageKey<String>(title),
            initiallyExpanded: initiallyExpanded,
            tilePadding: const EdgeInsets.symmetric(
              horizontal: PraniSpacing.xl,
              vertical: PraniSpacing.xs,
            ),
            childrenPadding: const EdgeInsets.fromLTRB(
              PraniSpacing.xl,
              0,
              PraniSpacing.xl,
              PraniSpacing.xl,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(PraniRadius.lg),
            ),
            collapsedShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(PraniRadius.lg),
            ),
            title: Text(
              title,
              style: PraniTextStyles.subheading(
                scheme,
                textTheme,
              ).copyWith(fontSize: 16),
            ),
            iconColor: scheme.primary,
            collapsedIconColor: scheme.onSurfaceVariant,
            onExpansionChanged: onExpansionChanged,
            children: [child],
          ),
        ),
      ),
    );
  }
}

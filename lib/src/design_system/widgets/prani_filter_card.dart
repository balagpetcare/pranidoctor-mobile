import 'package:flutter/material.dart';

import '../prani_tokens.dart';

/// Compact expandable filter surface — pairs with doctor finder style filters.
class PraniFilterCard extends StatelessWidget {
  const PraniFilterCard({
    super.key,
    required this.title,
    required this.summary,
    required this.children,
    this.initiallyExpanded = false,
    this.horizontalPadding = PraniSpacing.pageHorizontal,
    this.onReset,
    this.resetLabel = 'ফিল্টার মুছুন',
    this.resetEnabled = true,
    this.tilePadding,
    this.childrenPadding,
  });

  final String title;
  final String summary;
  final List<Widget> children;
  final bool initiallyExpanded;
  final double horizontalPadding;
  final VoidCallback? onReset;
  final String resetLabel;
  final bool resetEnabled;
  final EdgeInsetsGeometry? tilePadding;
  final EdgeInsetsGeometry? childrenPadding;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        PraniSpacing.sm,
        horizontalPadding,
        0,
      ),
      child: Material(
        color: scheme.surfaceContainerLow,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PraniRadius.lg),
          side: BorderSide(
            color: scheme.outlineVariant.withValues(alpha: 0.45),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            maintainState: true,
            initiallyExpanded: initiallyExpanded,
            tilePadding:
                tilePadding ??
                const EdgeInsets.symmetric(
                  horizontal: PraniSpacing.md,
                  vertical: PraniSpacing.xxs,
                ),
            childrenPadding:
                childrenPadding ??
                const EdgeInsets.fromLTRB(
                  PraniSpacing.md,
                  0,
                  PraniSpacing.md,
                  PraniSpacing.md,
                ),
            title: Text(
              title,
              style: PraniTextStyles.heading(scheme, textTheme),
            ),
            subtitle: Text(
              summary,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: PraniTextStyles.caption(scheme, textTheme),
            ),
            children: [
              ...children,
              if (onReset != null) ...[
                const SizedBox(height: PraniSpacing.sm),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: resetEnabled ? onReset : null,
                    icon: const Icon(Icons.clear_all, size: 20),
                    label: Text(resetLabel),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

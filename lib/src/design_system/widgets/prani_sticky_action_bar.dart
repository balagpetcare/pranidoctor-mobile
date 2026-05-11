import 'package:flutter/material.dart';

import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';

/// Bottom action region with elevation — use as [Scaffold.bottomNavigationBar].
///
/// Does **not** add keyboard padding; [Scaffold] places this above the IME when
/// [resizeToAvoidBottomInset] is true.
class PraniStickyActionBar extends StatelessWidget {
  const PraniStickyActionBar({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surface,
      elevation: 8,
      shadowColor: scheme.shadow.withValues(alpha: 0.12),
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: 4),
        child: Padding(
          padding:
              padding ??
              const EdgeInsets.fromLTRB(
                PraniSpacing.pageHorizontal,
                PraniSpacing.sm,
                PraniSpacing.pageHorizontal,
                PraniSpacing.md,
              ),
          child: child,
        ),
      ),
    );
  }
}

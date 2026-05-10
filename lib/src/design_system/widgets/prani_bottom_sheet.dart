import 'package:flutter/material.dart';

import '../prani_tokens.dart';
import 'prani_app_header.dart';

Future<R?> showPraniBottomSheet<R>({
  required BuildContext context,
  required Widget child,
  String? title,
  String? subtitle,
  List<Widget>? actions,
  bool showHandle = true,
  bool isDismissible = true,
  bool useSafeArea = true,
  double maxHeightFraction = 0.92,
}) {
  final scheme = Theme.of(context).colorScheme;

  return showModalBottomSheet<R>(
    context: context,
    isDismissible: isDismissible,
    showDragHandle: showHandle,
    backgroundColor: scheme.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(PraniRadius.lg)),
    ),
    isScrollControlled: true,
    builder: (ctx) {
      final maxH = MediaQuery.sizeOf(ctx).height * maxHeightFraction;

      final header = title != null
          ? Padding(
              padding: const EdgeInsets.fromLTRB(
                PraniSpacing.xl,
                PraniSpacing.sm,
                PraniSpacing.xl,
                PraniSpacing.xs,
              ),
              child: PraniAppHeader(
                title: title,
                subtitle: subtitle,
                actions: actions,
              ),
            )
          : null;

      Widget sheet = ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxH),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (header != null) ...[header, const Divider(height: 1)],
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(PraniSpacing.xl),
                child: child,
              ),
            ),
          ],
        ),
      );

      if (useSafeArea) {
        sheet = SafeArea(child: sheet);
      }

      return Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
        child: sheet,
      );
    },
  );
}

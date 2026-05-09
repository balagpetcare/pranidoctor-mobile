import 'package:flutter/material.dart';

import '../../app/screen_padding.dart';
import '../constants/pd_radii.dart';

/// Card body for shell tab placeholders (use inside [ShellTabPlaceholder] or custom scroll views).
class ShellTabPlaceholderBody extends StatelessWidget {
  const ShellTabPlaceholderBody({
    super.key,
    required this.icon,
    required this.message,
    this.cardHeading,
    this.actions,
  });

  final IconData icon;
  final String message;

  /// Optional heading inside the card (AppBar may already show tab title).
  final String? cardHeading;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final maxW = pdReadableMaxWidth(context);

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxW),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: PdRadii.lg,
              vertical: PdRadii.lg + 4,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 56, color: scheme.primary),
                const SizedBox(height: 20),
                if (cardHeading != null) ...[
                  Text(
                    cardHeading!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                ],
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                if (actions != null && actions!.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  ...actions!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Full-page placeholder for a customer shell tab (single scroll view).
class ShellTabPlaceholder extends StatelessWidget {
  const ShellTabPlaceholder({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actions,
  });

  final IconData icon;
  final String title;
  final String message;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    final pad = pdScreenPadding(context);

    return CustomScrollView(
      slivers: [
        SliverAppBar.large(title: Text(title)),
        SliverPadding(
          padding: pad.copyWith(bottom: 24),
          sliver: SliverToBoxAdapter(
            child: ShellTabPlaceholderBody(
              icon: icon,
              message: message,
              actions: actions,
            ),
          ),
        ),
      ],
    );
  }
}

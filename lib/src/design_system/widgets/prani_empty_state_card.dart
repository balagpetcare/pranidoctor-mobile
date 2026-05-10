import 'package:flutter/material.dart';

import 'prani_empty_state.dart';

/// Generic empty / zero-result state (lists, tabs, secondary surfaces).
///
/// Thin wrapper over [PraniEmptyState] with elevation strip styling.
class PraniEmptyStateCard extends StatelessWidget {
  const PraniEmptyStateCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon = Icons.inbox_outlined,
    this.action,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return PraniEmptyState(
      title: title,
      message: subtitle,
      icon: icon,
      customAction: action,
      boxed: true,
    );
  }
}

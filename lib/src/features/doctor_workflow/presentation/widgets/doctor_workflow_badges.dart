import 'package:flutter/material.dart';

import 'package:pranidoctor_mobile/src/core/constants/pd_spacing.dart';

/// Compact chip shown on doctor workflow screens.
class DoctorModeChip extends StatelessWidget {
  const DoctorModeChip({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(left: PdSpacing.sm),
      child: Material(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          child: Text(
            'ডাক্তার মোড',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: scheme.onPrimaryContainer,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

/// Emergency / priority row for case and request cards.
class DoctorUrgencyBadges extends StatelessWidget {
  const DoctorUrgencyBadges({
    super.key,
    required this.isEmergency,
    this.priorityLabel,
  });

  final bool isEmergency;
  final String? priorityLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final children = <Widget>[];
    if (isEmergency) {
      children.add(
        _Badge(
          label: 'জরুরি',
          bg: scheme.errorContainer,
          fg: scheme.onErrorContainer,
        ),
      );
    }
    final p = priorityLabel?.trim();
    if (p != null && p.isNotEmpty && p.toLowerCase() != 'normal') {
      if (children.isNotEmpty) {
        children.add(const SizedBox(width: PdSpacing.xs));
      }
      children.add(
        _Badge(
          label: 'অগ্রাধিকার: $p',
          bg: scheme.secondaryContainer,
          fg: scheme.onSecondaryContainer,
        ),
      );
    }
    if (children.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: PdSpacing.xs,
      runSpacing: PdSpacing.xs,
      children: children,
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.bg, required this.fg});

  final String label;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: fg,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

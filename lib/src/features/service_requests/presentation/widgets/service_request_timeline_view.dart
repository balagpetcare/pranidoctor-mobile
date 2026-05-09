import 'package:flutter/material.dart';

import 'package:pranidoctor_mobile/src/core/constants/pd_spacing.dart';
import 'package:pranidoctor_mobile/src/features/service_requests/domain/service_request_timeline.dart';

class ServiceRequestTimelineView extends StatelessWidget {
  const ServiceRequestTimelineView({super.key, required this.steps});

  final List<RequestTimelineStep> steps;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'অবস্থার সময়রেখা',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: PdSpacing.md),
        ...steps.asMap().entries.map((e) {
          final isLast = e.key == steps.length - 1;
          return _TimelineRow(step: e.value, isLast: isLast, scheme: scheme);
        }),
      ],
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.step,
    required this.isLast,
    required this.scheme,
  });

  final RequestTimelineStep step;
  final bool isLast;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final (IconData icon, Color iconColor, Color textColor) = _style(
      step.kind,
      scheme,
    );

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : PdSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Icon(icon, size: 22, color: iconColor),
              if (!isLast)
                Container(
                  width: 2,
                  height: 22,
                  margin: const EdgeInsets.only(top: 4),
                  color: scheme.outlineVariant.withValues(alpha: 0.6),
                ),
            ],
          ),
          const SizedBox(width: PdSpacing.sm),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                step.labelBn,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: textColor,
                  fontWeight: step.kind == RequestTimelineRowKind.current
                      ? FontWeight.w700
                      : FontWeight.w400,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

(IconData, Color, Color) _style(
  RequestTimelineRowKind kind,
  ColorScheme scheme,
) {
  return switch (kind) {
    RequestTimelineRowKind.completed => (
      Icons.check_circle_rounded,
      scheme.primary,
      scheme.onSurface,
    ),
    RequestTimelineRowKind.current => (
      Icons.radio_button_checked_rounded,
      scheme.tertiary,
      scheme.onSurface,
    ),
    RequestTimelineRowKind.pending => (
      Icons.radio_button_off_rounded,
      scheme.outline,
      scheme.onSurfaceVariant,
    ),
    RequestTimelineRowKind.cancelledTerminal => (
      Icons.cancel_rounded,
      scheme.error,
      scheme.error,
    ),
  };
}

import 'package:flutter/material.dart';

import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';
import 'package:pranidoctor_mobile/src/features/livestock_booking/domain/livestock_booking_phase.dart';
import 'package:pranidoctor_mobile/src/features/livestock_booking/domain/service_request_booking_mapper.dart';

/// Full-width step strip for the seven canonical phases.
class LivestockBookingPhaseProgressRow extends StatelessWidget {
  const LivestockBookingPhaseProgressRow({
    super.key,
    required this.current,
  });

  final LivestockBookingPhase current;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final curIdx = current.stepIndex;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < LivestockBookingPhase.values.length; i++) ...[
            if (i > 0) const SizedBox(width: PraniSpacing.xs),
            _PhaseChip(
              label: LivestockBookingPhase.values[i].labelBn,
              state: i < curIdx
                  ? _ChipState.done
                  : i == curIdx
                      ? _ChipState.current
                      : _ChipState.upcoming,
              scheme: scheme,
            ),
          ],
        ],
      ),
    );
  }
}

enum _ChipState { done, current, upcoming }

class _PhaseChip extends StatelessWidget {
  const _PhaseChip({
    required this.label,
    required this.state,
    required this.scheme,
  });

  final String label;
  final _ChipState state;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final bg = switch (state) {
      _ChipState.done => scheme.primaryContainer,
      _ChipState.current => scheme.tertiaryContainer,
      _ChipState.upcoming => scheme.surfaceContainerHighest,
    };
    final fg = switch (state) {
      _ChipState.done => scheme.onPrimaryContainer,
      _ChipState.current => scheme.onTertiaryContainer,
      _ChipState.upcoming => scheme.onSurfaceVariant,
    };
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: fg,
                fontWeight:
                    state == _ChipState.current ? FontWeight.w700 : FontWeight.w500,
              ),
        ),
      ),
    );
  }
}

/// Vertical event log built from [buildLivestockBookingTimeline].
class LivestockBookingTimelineList extends StatelessWidget {
  const LivestockBookingTimelineList({
    super.key,
    required this.rows,
  });

  final List<LivestockBookingTimelineRow> rows;

  static String _formatAt(DateTime? t) {
    if (t == null) return '—';
    final d = t.toLocal();
    return '${d.day}/${d.month}/${d.year}, '
        '${d.hour.toString().padLeft(2, '0')}:'
        '${d.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'সেবার সময়রেখা',
          style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: PraniSpacing.md),
        for (var i = 0; i < rows.length; i++) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: rows[i].highlight
                          ? scheme.primary
                          : scheme.outlineVariant,
                    ),
                  ),
                  if (i < rows.length - 1)
                    Container(
                      width: 2,
                      height: 36,
                      color: scheme.outlineVariant.withValues(alpha: 0.6),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rows[i].titleBn,
                        style: textTheme.bodyLarge?.copyWith(
                          fontWeight: rows[i].highlight
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                      Text(
                        _formatAt(rows[i].at),
                        style: textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

import 'package:flutter/material.dart';

import 'package:pranidoctor_mobile/src/features/livestock_booking/domain/livestock_booking_phase.dart';

class LivestockBookingStatusBanner extends StatelessWidget {
  const LivestockBookingStatusBanner({
    super.key,
    required this.phase,
    this.apiStatusLabelBn,
  });

  final LivestockBookingPhase phase;
  final String? apiStatusLabelBn;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = switch (phase) {
      LivestockBookingPhase.cancelled => scheme.errorContainer,
      LivestockBookingPhase.completed => scheme.primaryContainer,
      LivestockBookingPhase.requestCreated => scheme.secondaryContainer,
      _ => scheme.tertiaryContainer,
    };

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.flag_outlined, color: scheme.onSecondaryContainer),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    phase.labelBn,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            if (apiStatusLabelBn != null &&
                apiStatusLabelBn!.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'সার্ভার স্ট্যাটাস: ${apiStatusLabelBn!.trim()}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

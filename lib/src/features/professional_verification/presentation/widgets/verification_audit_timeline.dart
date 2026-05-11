import 'package:flutter/material.dart';

import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_premium_card.dart';
import 'package:pranidoctor_mobile/src/features/professional_verification/data/verification_audit_entry.dart';
import 'package:pranidoctor_mobile/src/features/professional_verification/domain/verification_workflow_phase.dart';

class VerificationAuditTimeline extends StatelessWidget {
  const VerificationAuditTimeline({super.key, required this.entries});

  final List<VerificationAuditEntry> entries;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (entries.isEmpty) {
      return Text(
        'এখনও স্থানীয় ইতিহাস নেই। সার্ভার থেকে অডিট লগ এলে এখানে মিশবে।',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.45,
            ),
      );
    }
    final sorted = [...entries]..sort((a, b) => b.atUtc.compareTo(a.atUtc));
    return PraniPremiumCard(
      padding: const EdgeInsets.all(PraniSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'স্ট্যাটাস ইতিহাস (অডিট-প্রস্তুত)',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: PraniSpacing.md),
          for (final e in sorted.take(12)) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.history_rounded, size: 18, color: scheme.primary),
                const SizedBox(width: PraniSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${e.toPhase.labelBn} · ${e.atUtc.toLocal()}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      if (e.apiStatusRaw != null && e.apiStatusRaw!.trim().isNotEmpty)
                        Text(
                          'API: ${e.apiStatusRaw}',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                        ),
                      if (e.note != null && e.note!.trim().isNotEmpty)
                        Text(
                          e.note!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                height: 1.35,
                              ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: PraniSpacing.xl),
          ],
        ],
      ),
    );
  }
}

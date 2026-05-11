import 'package:flutter/material.dart';

import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_premium_card.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/data/ai_technician_models.dart';
import 'package:pranidoctor_mobile/src/features/professional_verification/application/verification_workflow_snapshot.dart';

class VerificationDocumentReviewList extends StatelessWidget {
  const VerificationDocumentReviewList({super.key, required this.rows});

  final List<VerificationDocumentReviewRow> rows;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (rows.isEmpty) {
      return Text(
        'নথির তালিকা এখনও লোড হয়নি বা খালি। আবেদন ফরম থেকে আপলোড করুন।',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.45,
            ),
      );
    }
    return PraniPremiumCard(
      padding: const EdgeInsets.all(PraniSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'নথি যাচাই (অ্যাডমিন প্রস্তুত)',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: PraniSpacing.md),
          for (final r in rows) ...[
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.description_outlined, color: scheme.primary),
              title: Text(AiTechnicianDocumentTypes.labelBn(r.typeCode)),
              subtitle: Text(r.title),
              trailing: Chip(
                label: Text(r.reviewLabelBn),
                visualDensity: VisualDensity.compact,
              ),
            ),
            const Divider(height: 1),
          ],
        ],
      ),
    );
  }
}

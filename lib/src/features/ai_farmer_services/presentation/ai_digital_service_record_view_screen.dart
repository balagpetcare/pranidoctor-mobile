import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pranidoctor_mobile/src/design_system/prani_page_insets.dart';
import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_loading_state.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_premium_card.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_scaffold.dart';
import 'package:pranidoctor_mobile/src/features/ai_farmer_services/application/ai_farmer_services_providers.dart';
import 'package:pranidoctor_mobile/src/features/ai_farmer_services/data/ai_digital_service_record_dto.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/data/ai_technician_models.dart';

/// Shared “ডিজিটাল এআই সার্ভিস রেকর্ড” view (farmer + technician; auth enforced by API).
class AiDigitalServiceRecordViewScreen extends ConsumerWidget {
  const AiDigitalServiceRecordViewScreen({super.key, required this.requestId});

  final String requestId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(aiDigitalServiceRecordProvider(requestId));
    final hPad = PraniPageInsets.horizontalPadding(context);
    final textTheme = Theme.of(context).textTheme;

    return PraniScaffold(
      title: 'ডিজিটাল এআই সার্ভিস রেকর্ড',
      padding: EdgeInsets.fromLTRB(
        hPad,
        PraniSpacing.md,
        hPad,
        PraniSpacing.lg,
      ),
      body: async.when(
        loading: () => const Center(
          child: PraniLoadingState(message: 'লোড হচ্ছে…', compact: false),
        ),
        error: (e, _) => Center(child: Text('লোড করা যায়নি।\n$e')),
        data: (record) => _RecordBody(record: record, textTheme: textTheme),
      ),
    );
  }
}

class _RecordBody extends StatelessWidget {
  const _RecordBody({required this.record, required this.textTheme});

  final AiDigitalServiceRecord record;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        if ((record.nextFollowUpDate != null &&
                record.nextFollowUpDate!.isNotEmpty) ||
            (record.pregnancyCheckDate != null &&
                record.pregnancyCheckDate!.isNotEmpty))
          Padding(
            padding: const EdgeInsets.only(bottom: PraniSpacing.md),
            child: PraniPremiumCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'পরবর্তী পর্যবেক্ষণ',
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: PraniSpacing.sm),
                  if (record.nextFollowUpDate != null &&
                      record.nextFollowUpDate!.isNotEmpty)
                    _line('ফলোআপ তারিখ', _shortDate(record.nextFollowUpDate!)),
                  if (record.pregnancyCheckDate != null &&
                      record.pregnancyCheckDate!.isNotEmpty)
                    _line(
                      'গর্ভ পরীক্ষার তারিখ',
                      _shortDate(record.pregnancyCheckDate!),
                    ),
                ],
              ),
            ),
          ),
        PraniPremiumCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _line('সেবার তারিখ', _shortDate(record.serviceDate)),
              _line(
                'প্রাণী',
                AiTechnicianAnimalTypes.labelBn(record.animalType),
              ),
              if (record.breedOrSemenType?.trim().isNotEmpty ?? false)
                _line('জাত / সিমেন', record.breedOrSemenType!.trim()),
              if (record.semenBatch?.trim().isNotEmpty ?? false)
                _line('সিমেন ব্যাচ / উৎস', record.semenBatch!.trim()),
              if (record.heatObservation?.trim().isNotEmpty ?? false)
                _line('হিট পর্যবেক্ষণ', record.heatObservation!.trim()),
              if (record.inseminationTime != null &&
                  record.inseminationTime!.isNotEmpty)
                _line('গর্ভসঞ্চার সময়', _shortDate(record.inseminationTime!)),
              if (record.serviceNote?.trim().isNotEmpty ?? false)
                _line('নোট', record.serviceNote!.trim()),
              if (record.totalFee != null && record.totalFee!.isNotEmpty)
                _line('মোট ফি (৳)', record.totalFee!),
              _line(
                'পরিশোধ অবস্থা',
                AiPaymentStatusBn.label(record.paymentStatus),
              ),
            ],
          ),
        ),
        const SizedBox(height: PraniSpacing.md),
        TextButton(
          onPressed: () => Navigator.of(context).maybePop(),
          child: const Text('ফিরে যান'),
        ),
      ],
    );
  }

  Widget _line(String k, String v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: PraniSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 132,
            child: Text(
              k,
              style: textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(child: Text(v, style: textTheme.bodyMedium)),
        ],
      ),
    );
  }

  String _shortDate(String iso) {
    if (iso.length >= 16) return iso.substring(0, 16).replaceFirst('T', ' ');
    return iso;
  }
}

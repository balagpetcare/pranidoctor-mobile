import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pranidoctor_mobile/src/design_system/prani_page_insets.dart';
import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_buttons.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_loading_state.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_premium_card.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_scaffold.dart';
import 'package:pranidoctor_mobile/src/features/ai_farmer_services/application/ai_farmer_services_providers.dart';
import 'package:pranidoctor_mobile/src/features/ai_farmer_services/presentation/ai_service_request_status_bn.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/data/ai_technician_models.dart';

class AiFarmerMyRequestDetailScreen extends ConsumerWidget {
  const AiFarmerMyRequestDetailScreen({super.key, required this.requestId});

  final String requestId;

  static const routePath = '/ai-services/my-requests/:requestId';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(aiFarmerMyRequestDetailProvider(requestId));
    final hPad = PraniPageInsets.horizontalPadding(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return PraniScaffold(
      title: 'অনুরোধের বিস্তারিত',
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
        data: (r) {
          return ListView(
            children: [
              if (r.isEmergency)
                Padding(
                  padding: const EdgeInsets.only(bottom: PraniSpacing.sm),
                  child: PraniPremiumCard(
                    child: Row(
                      children: [
                        Icon(Icons.emergency_outlined, color: scheme.error),
                        const SizedBox(width: PraniSpacing.sm),
                        Expanded(
                          child: Text(
                            'জরুরি অনুরোধ',
                            style: textTheme.titleSmall?.copyWith(
                              color: scheme.error,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              PraniPremiumCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'অবস্থা: ${AiServiceRequestStatusBn.title(r.status)}',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (r.technicianDisplayName?.trim().isNotEmpty ??
                        false) ...[
                      const SizedBox(height: PraniSpacing.xs),
                      Text(
                        'টেকনিশিয়ান: ${r.technicianDisplayName!.trim()}',
                        style: textTheme.bodyMedium,
                      ),
                    ],
                    const SizedBox(height: PraniSpacing.sm),
                    Text(
                      AiTechnicianAnimalTypes.labelBn(r.animalType),
                      style: textTheme.titleSmall,
                    ),
                    if (r.breed?.trim().isNotEmpty ?? false)
                      Text('জাত: ${r.breed}', style: textTheme.bodyMedium),
                    if (r.animalAge?.trim().isNotEmpty ?? false)
                      Text('বয়স: ${r.animalAge}', style: textTheme.bodyMedium),
                  ],
                ),
              ),
              const SizedBox(height: PraniSpacing.sm),
              PraniPremiumCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'হিট ও স্বাস্থ্য',
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (r.lastHeatDate != null && r.lastHeatDate!.isNotEmpty)
                      Text(
                        'শেষ হিট: ${r.lastHeatDate}',
                        style: textTheme.bodyMedium,
                      ),
                    if (r.heatSymptoms?.trim().isNotEmpty ?? false)
                      Text(
                        'লক্ষণ: ${r.heatSymptoms}',
                        style: textTheme.bodyMedium,
                      ),
                    if (r.previousAiHistory?.trim().isNotEmpty ?? false)
                      Text(
                        'আগের এআই: ${r.previousAiHistory}',
                        style: textTheme.bodyMedium,
                      ),
                    if (r.healthIssueNote?.trim().isNotEmpty ?? false)
                      Text(
                        'স্বাস্থ্য নোট: ${r.healthIssueNote}',
                        style: textTheme.bodyMedium,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: PraniSpacing.sm),
              PraniPremiumCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ঠিকানা',
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${r.district ?? ''} · ${r.upazila ?? ''}'
                      '${r.unionOrArea != null && r.unionOrArea!.trim().isNotEmpty ? ' · ${r.unionOrArea}' : ''}',
                      style: textTheme.bodyMedium,
                    ),
                    if (r.addressDetail?.trim().isNotEmpty ?? false)
                      Text(r.addressDetail!, style: textTheme.bodyMedium),
                    if (r.preferredTime?.trim().isNotEmpty ?? false)
                      Text(
                        'পছন্দের সময়: ${r.preferredTime}',
                        style: textTheme.bodyMedium,
                      ),
                  ],
                ),
              ),
              if (r.declineReason?.trim().isNotEmpty ?? false) ...[
                const SizedBox(height: PraniSpacing.sm),
                PraniPremiumCard(
                  child: Text(
                    'বাতিলের কারণ: ${r.declineReason!.trim()}',
                    style: textTheme.bodyMedium,
                  ),
                ),
              ],
              if (r.technicianProfileId != null &&
                  r.technicianProfileId!.isNotEmpty) ...[
                const SizedBox(height: PraniSpacing.md),
                PraniSecondaryButton(
                  label: 'সমস্যা জানান / অভিযোগ',
                  fullWidth: true,
                  onPressed: () => context.push('complaint'),
                ),
              ],
              if (r.status == 'COMPLETED') ...[
                const SizedBox(height: PraniSpacing.md),
                if (!(r.hasAiReview == true)) ...[
                  PraniPrimaryButton(
                    label: 'সেবার রিভিউ দিন',
                    fullWidth: true,
                    onPressed: () => context.push('review'),
                  ),
                  const SizedBox(height: PraniSpacing.sm),
                ] else ...[
                  PraniPremiumCard(
                    child: Text(
                      'রিভিউ দেওয়া হয়েছে। ধন্যবাদ!',
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: PraniSpacing.sm),
                ],
                PraniPrimaryButton(
                  label: 'ডিজিটাল এআই সার্ভিস রেকর্ড দেখুন',
                  fullWidth: true,
                  onPressed: () => context.push('record'),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

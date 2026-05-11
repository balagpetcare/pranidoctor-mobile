import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pranidoctor_mobile/src/design_system/prani_page_insets.dart';
import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_buttons.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_loading_state.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_premium_card.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_scaffold.dart';
import 'package:pranidoctor_mobile/src/features/ai_farmer_services/data/ai_farmer_services_models.dart';
import 'package:pranidoctor_mobile/src/features/ai_farmer_services/presentation/ai_service_request_status_bn.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/application/ai_technician_providers.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/data/ai_technician_api_exception.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/data/ai_technician_models.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/data/ai_technician_repository.dart';

class AiTechnicianRequestDetailScreen extends ConsumerStatefulWidget {
  const AiTechnicianRequestDetailScreen({super.key, required this.requestId});

  final String requestId;

  @override
  ConsumerState<AiTechnicianRequestDetailScreen> createState() =>
      _AiTechnicianRequestDetailScreenState();
}

class _AiTechnicianRequestDetailScreenState
    extends ConsumerState<AiTechnicianRequestDetailScreen> {
  bool _busy = false;

  Future<void> _run(Future<void> Function() work) async {
    setState(() => _busy = true);
    try {
      await work();
      if (!mounted) return;
      ref.invalidate(aiTechnicianJobRequestDetailProvider(widget.requestId));
      invalidateAiTechnicianJobRequestLists(ref);
    } catch (e) {
      if (!mounted) return;
      final msg = e is AiTechnicianApiException ? e.message : '$e';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _declineDialog() async {
    final ctrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('বাতিল করবেন?'),
        content: TextField(
          controller: ctrl,
          maxLines: 3,
          decoration: const InputDecoration(hintText: 'কারণ (ঐচ্ছিক)'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('না'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('বাতিল'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    final repo = ref.read(aiTechnicianRepositoryProvider);
    await _run(
      () => repo.declineTechnicianJobRequest(
        widget.requestId,
        reason: ctrl.text.trim().isEmpty ? null : ctrl.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(
      aiTechnicianJobRequestDetailProvider(widget.requestId),
    );
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
          final repo = ref.read(aiTechnicianRepositoryProvider);
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
                            'জরুরি',
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
                      AiServiceRequestStatusBn.title(r.status),
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (r.farmerDisplayName?.trim().isNotEmpty ?? false)
                      Text(
                        'কৃষক: ${r.farmerDisplayName!.trim()}',
                        style: textTheme.bodyMedium,
                      ),
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
                      'হিট',
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
                      'ঠিকানা ও সময়',
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
              const SizedBox(height: PraniSpacing.md),
              ..._actions(r, repo, textTheme),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _actions(
    AiFarmerServiceRequestRow r,
    AiTechnicianRepository repo,
    TextTheme textTheme,
  ) {
    final disabled = _busy;
    final st = r.status;
    final children = <Widget>[];

    void gap() => children.add(const SizedBox(height: PraniSpacing.sm));

    if (st == 'PENDING') {
      children.add(
        PraniPrimaryButton(
          label: 'গ্রহণ করুন',
          onPressed: disabled
              ? null
              : () => _run(
                  () => repo.acceptTechnicianJobRequest(widget.requestId),
                ),
        ),
      );
      gap();
      children.add(
        PraniSecondaryButton(
          label: 'বাতিল করুন',
          fullWidth: true,
          style: PraniSecondaryStyle.outlined,
          onPressed: disabled ? null : _declineDialog,
        ),
      );
    }
    if (st == 'ACCEPTED') {
      children.add(
        PraniPrimaryButton(
          label: 'রওনা হয়েছি',
          onPressed: disabled
              ? null
              : () => _run(
                  () => repo.postTechnicianJobStatus(
                    widget.requestId,
                    'ON_THE_WAY',
                  ),
                ),
        ),
      );
    }
    if (st == 'ON_THE_WAY') {
      children.add(
        PraniPrimaryButton(
          label: 'পৌঁছেছি',
          onPressed: disabled
              ? null
              : () => _run(
                  () =>
                      repo.postTechnicianJobStatus(widget.requestId, 'ARRIVED'),
                ),
        ),
      );
    }
    if (st == 'ARRIVED') {
      children.add(
        PraniPrimaryButton(
          label: 'কাজ শুরু',
          onPressed: disabled
              ? null
              : () => _run(
                  () => repo.postTechnicianJobStatus(
                    widget.requestId,
                    'IN_PROGRESS',
                  ),
                ),
        ),
      );
    }
    if (st == 'IN_PROGRESS') {
      children.add(
        PraniPrimaryButton(
          label: 'সম্পন্ন করুন',
          onPressed: disabled ? null : () => context.push('complete'),
        ),
      );
    }
    if (st == 'COMPLETED') {
      children.add(
        PraniPrimaryButton(
          label: 'ডিজিটাল এআই সার্ভিস রেকর্ড',
          onPressed: disabled ? null : () => context.push('record'),
        ),
      );
    }

    if (children.isEmpty) {
      children.add(
        Text('এই অনুরোধে কোনো কাজ নেই।', style: textTheme.bodyMedium),
      );
    }
    return children;
  }
}

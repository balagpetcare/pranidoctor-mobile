import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pranidoctor_mobile/src/design_system/prani_page_insets.dart';
import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_loading_state.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_premium_card.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_scaffold.dart';
import 'package:pranidoctor_mobile/src/features/ai_farmer_services/application/ai_farmer_services_providers.dart';
import 'package:pranidoctor_mobile/src/features/ai_farmer_services/presentation/ai_service_request_status_bn.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/data/ai_technician_models.dart';

class AiMyServiceRequestsScreen extends ConsumerStatefulWidget {
  const AiMyServiceRequestsScreen({super.key});

  static const routePath = '/ai-services/my-requests';
  static const routeName = 'aiMyServiceRequests';

  @override
  ConsumerState<AiMyServiceRequestsScreen> createState() =>
      _AiMyServiceRequestsScreenState();
}

class _AiMyServiceRequestsScreenState
    extends ConsumerState<AiMyServiceRequestsScreen> {
  String _filter = 'all';

  static String _bucket(String status) {
    switch (status) {
      case 'PENDING':
        return 'pending';
      case 'ACCEPTED':
        return 'accepted';
      case 'ON_THE_WAY':
      case 'ARRIVED':
      case 'IN_PROGRESS':
        return 'ongoing';
      case 'COMPLETED':
        return 'completed';
      case 'DECLINED':
      case 'CANCELLED':
        return 'cancelled';
      default:
        return 'other';
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(aiMyServiceRequestsProvider);
    final hPad = PraniPageInsets.horizontalPadding(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return PraniScaffold(
      title: 'আমার এআই অনুরোধ',
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
        data: (data) {
          final all = data.requests;
          final filtered = _filter == 'all'
              ? all
              : all.where((r) => _bucket(r.status) == _filter).toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ChoiceChip(
                      label: const Text('সব'),
                      selected: _filter == 'all',
                      onSelected: (_) => setState(() => _filter = 'all'),
                    ),
                    const SizedBox(width: PraniSpacing.xs),
                    ChoiceChip(
                      label: const Text('অপেক্ষমাণ'),
                      selected: _filter == 'pending',
                      onSelected: (_) => setState(() => _filter = 'pending'),
                    ),
                    const SizedBox(width: PraniSpacing.xs),
                    ChoiceChip(
                      label: const Text('গ্রহীত'),
                      selected: _filter == 'accepted',
                      onSelected: (_) => setState(() => _filter = 'accepted'),
                    ),
                    const SizedBox(width: PraniSpacing.xs),
                    ChoiceChip(
                      label: const Text('চলমান'),
                      selected: _filter == 'ongoing',
                      onSelected: (_) => setState(() => _filter = 'ongoing'),
                    ),
                    const SizedBox(width: PraniSpacing.xs),
                    ChoiceChip(
                      label: const Text('সম্পন্ন'),
                      selected: _filter == 'completed',
                      onSelected: (_) => setState(() => _filter = 'completed'),
                    ),
                    const SizedBox(width: PraniSpacing.xs),
                    ChoiceChip(
                      label: const Text('বাতিল'),
                      selected: _filter == 'cancelled',
                      onSelected: (_) => setState(() => _filter = 'cancelled'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: PraniSpacing.md),
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Text(
                          'এই বিভাগে কোনো অনুরোধ নেই।',
                          style: textTheme.bodyLarge,
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () async {
                          ref.invalidate(aiMyServiceRequestsProvider);
                          await ref.read(aiMyServiceRequestsProvider.future);
                        },
                        child: ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: filtered.length,
                          separatorBuilder: (_, index) =>
                              const SizedBox(height: PraniSpacing.sm),
                          itemBuilder: (context, i) {
                            final r = filtered[i];
                            return PraniPremiumCard(
                              child: ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(
                                  AiTechnicianAnimalTypes.labelBn(r.animalType),
                                ),
                                subtitle: Text(
                                  '${AiServiceRequestStatusBn.title(r.status)} · ${r.district ?? ''} ${r.upazila ?? ''}\n'
                                  '${r.createdAt.length > 10 ? r.createdAt.substring(0, 10) : r.createdAt}',
                                ),
                                isThreeLine: true,
                                onTap: () => context.push(
                                  '/ai-services/my-requests/${r.id}',
                                ),
                                trailing: r.estimatedFee != null
                                    ? Text(
                                        '৳${r.estimatedFee}',
                                        style: textTheme.labelLarge?.copyWith(
                                          color: scheme.primary,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      )
                                    : null,
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pranidoctor_mobile/src/design_system/prani_page_insets.dart';
import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_loading_state.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_premium_card.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_scaffold.dart';
import 'package:pranidoctor_mobile/src/features/ai_farmer_services/data/ai_farmer_services_models.dart';
import 'package:pranidoctor_mobile/src/features/ai_farmer_services/presentation/ai_service_request_status_bn.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/application/ai_technician_providers.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/data/ai_technician_models.dart';

class AiTechnicianRequestsListScreen extends ConsumerStatefulWidget {
  const AiTechnicianRequestsListScreen({super.key, this.embedded = false});

  /// Inside [ProfessionalWorkspaceShellScreen] — hide duplicate app bar.
  final bool embedded;

  static const routePath = '/profile/ai-technician/requests';
  static const routeName = 'aiTechnicianRequests';

  @override
  ConsumerState<AiTechnicianRequestsListScreen> createState() =>
      _AiTechnicianRequestsListScreenState();
}

class _AiTechnicianRequestsListScreenState
    extends ConsumerState<AiTechnicianRequestsListScreen> {
  static const _tabs = <String, String>{
    'new': 'নতুন',
    'accepted': 'গ্রহণ করা',
    'ongoing': 'চলমান',
    'completed': 'সম্পন্ন',
    'cancelled': 'বাতিল',
  };

  String _tab = 'new';

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(aiTechnicianJobRequestsForTabProvider(_tab));
    final hPad = PraniPageInsets.horizontalPadding(context);
    final textTheme = Theme.of(context).textTheme;

    return PraniScaffold(
      title: widget.embedded ? null : 'কাজের অনুরোধ',
      showBackButton: !widget.embedded,
      padding: EdgeInsets.fromLTRB(
        hPad,
        PraniSpacing.md,
        hPad,
        PraniSpacing.lg,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _tabs.entries.map((e) {
                final sel = _tab == e.key;
                return Padding(
                  padding: const EdgeInsets.only(right: PraniSpacing.xs),
                  child: ChoiceChip(
                    label: Text(e.value),
                    selected: sel,
                    onSelected: (_) => setState(() => _tab = e.key),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: PraniSpacing.md),
          Expanded(
            child: async.when(
              loading: () => const Center(
                child: PraniLoadingState(message: 'লোড হচ্ছে…', compact: false),
              ),
              error: (e, _) => Center(child: Text('লোড করা যায়নি।\n$e')),
              data: (d) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (d.truncated)
                      Padding(
                        padding: const EdgeInsets.only(bottom: PraniSpacing.sm),
                        child: Text(
                          'তালিকা সীমিত দেখানো হচ্ছে। আরও ফিল্টার ব্যবহার করুন।',
                          style: textTheme.bodySmall,
                        ),
                      ),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () async {
                          invalidateAiTechnicianJobRequestLists(ref);
                          await ref.read(
                            aiTechnicianJobRequestsForTabProvider(_tab).future,
                          );
                        },
                        child: _list(context, d.items, textTheme),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _list(
    BuildContext context,
    List<AiFarmerServiceRequestRow> items,
    TextTheme textTheme,
  ) {
    if (items.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 48),
          Center(
            child: Text(
              'এই বিভাগে কোনো অনুরোধ নেই।',
              style: textTheme.bodyLarge,
            ),
          ),
        ],
      );
    }
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (context, index) =>
          const SizedBox(height: PraniSpacing.sm),
      itemBuilder: (context, i) {
        final r = items[i];
        final farmer = r.farmerDisplayName;
        return PraniPremiumCard(
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(AiTechnicianAnimalTypes.labelBn(r.animalType)),
            subtitle: Text(
              '${AiServiceRequestStatusBn.title(r.status)} · '
              '${r.district ?? ''} ${r.upazila ?? ''}\n'
              '${farmer != null && farmer.trim().isNotEmpty ? 'কৃষক: $farmer\n' : ''}'
              '${r.createdAt.length > 10 ? r.createdAt.substring(0, 10) : r.createdAt}',
            ),
            isThreeLine: true,
            onTap: () => context.push(
              '${AiTechnicianRequestsListScreen.routePath}/${r.id}',
            ),
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pranidoctor_mobile/src/app/screen_padding.dart';
import 'package:pranidoctor_mobile/src/core/constants/pd_spacing.dart';
import 'package:pranidoctor_mobile/src/core/widgets/pd_async_states.dart';
import 'package:pranidoctor_mobile/src/features/providers/application/provider_finder_providers.dart';
import 'package:pranidoctor_mobile/src/features/providers/data/provider_finder_repository.dart';
import 'package:pranidoctor_mobile/src/features/providers/data/provider_models.dart';
import 'package:pranidoctor_mobile/src/features/providers/data/provider_profile_model.dart';
import 'package:pranidoctor_mobile/src/features/providers/presentation/technician_detail_screen.dart';
import 'package:pranidoctor_mobile/src/features/providers/presentation/widgets/provider_card.dart';
import 'package:pranidoctor_mobile/src/features/providers/presentation/widgets/provider_filter_panel.dart';

class TechnicianListScreen extends ConsumerStatefulWidget {
  const TechnicianListScreen({super.key});

  static const routePath = '/providers/technicians';
  static const routeName = 'technicianList';

  @override
  ConsumerState<TechnicianListScreen> createState() =>
      _TechnicianListScreenState();
}

class _TechnicianListScreenState extends ConsumerState<TechnicianListScreen> {
  late final TextEditingController _searchCtrl;

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController(
      text: ref.read(technicianListQueryProvider).nameSearch ?? '',
    );
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<TechnicianSummary> _visibleTechnicians(
    List<TechnicianSummary> list,
    String localTrim,
    bool? aiOnly,
  ) {
    var out = list;
    if (localTrim.isNotEmpty) {
      final q = localTrim.toLowerCase();
      out = out.where((t) => t.name.toLowerCase().contains(q)).toList();
    }
    if (aiOnly == true) {
      out = out
          .where(
            (t) =>
                (t.serviceType?.trim().isNotEmpty ?? false) ||
                t.supportedAnimalTypes.isNotEmpty,
          )
          .toList();
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(techniciansListProvider);
    final notifier = ref.read(techniciansListProvider.notifier);
    final query = ref.watch(technicianListQueryProvider);
    final scheme = Theme.of(context).colorScheme;
    final hPad = pdScreenPadding(context).horizontal;
    final maxW = pdReadableMaxWidth(context);

    return Scaffold(
      appBar: AppBar(title: const Text('এআই টেকনিশিয়ান খুঁজুন')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(hPad, PdSpacing.sm, hPad, 0),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxW),
                child: TextField(
                  controller: _searchCtrl,
                  decoration: InputDecoration(
                    hintText: 'নাম দিয়ে খুঁজুন',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.send_outlined),
                      tooltip: 'খুঁজুন',
                      onPressed: () {
                        final t = _searchCtrl.text.trim();
                        ref
                            .read(technicianListQueryProvider.notifier)
                            .apply(
                              query.withFilters(
                                nameSearch: t.isEmpty ? null : t,
                                clearNameSearch: t.isEmpty,
                              ),
                            );
                      },
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  textInputAction: TextInputAction.search,
                  onSubmitted: (v) {
                    final t = v.trim();
                    ref
                        .read(technicianListQueryProvider.notifier)
                        .apply(
                          query.withFilters(
                            nameSearch: t.isEmpty ? null : t,
                            clearNameSearch: t.isEmpty,
                          ),
                        );
                  },
                ),
              ),
            ),
          ),
          ProviderFilterPanel(
            query: query,
            showOnlineConsultation: false,
            showAiTechnicianServiceFilter: true,
            showOnlineConsultationPlaceholderNote: true,
            onQueryChanged: (q) {
              ref.read(technicianListQueryProvider.notifier).apply(q);
            },
          ),
          Expanded(
            child: async.when(
              loading: () =>
                  const PdLoadingBody(message: 'টেকনিশিয়ান তালিকা লোড হচ্ছে…'),
              error: (e, _) => PdErrorBody(
                title: 'লোড করা যায়নি',
                message: e is ProviderApiException ? e.message : e.toString(),
                retryLabel: 'আবার চেষ্টা',
                onRetry: () => notifier.refresh(),
              ),
              data: (data) {
                final local = (query.nameSearch ?? '').trim();
                final visible = _visibleTechnicians(
                  data.technicians,
                  local,
                  query.aiTechnicianService,
                );
                if (visible.isEmpty) {
                  return PdEmptyState(
                    icon: Icons.search_off,
                    title: 'কোনো টেকনিশিয়ান পাওয়া যায়নি',
                    subtitle:
                        'ফিল্টার বা নাম বদলে আবার চেষ্টা করুন। অনলাইন কনসালটেশন ফিল্টার শীঘ্রই।',
                    actionLabel: 'রিফ্রেশ',
                    onAction: () => notifier.refresh(),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () => notifier.refresh(),
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 24),
                        sliver: SliverToBoxAdapter(
                          child: Center(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(maxWidth: maxW),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    'মোট ${data.pagination.total} জন (দেখানো ${visible.length})',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelLarge
                                        ?.copyWith(
                                          color: scheme.onSurfaceVariant,
                                        ),
                                  ),
                                  const SizedBox(height: 10),
                                  for (final t in visible) ...[
                                    ProviderCard(
                                      profile:
                                          ProviderProfile.fromTechnicianSummary(
                                            t,
                                          ),
                                      onOpenDetail: () => context.push(
                                        TechnicianDetailScreen.pathFor(t.id),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

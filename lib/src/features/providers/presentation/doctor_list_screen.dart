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
import 'package:pranidoctor_mobile/src/features/providers/presentation/doctor_detail_screen.dart';
import 'package:pranidoctor_mobile/src/features/providers/presentation/widgets/provider_card.dart';
import 'package:pranidoctor_mobile/src/features/providers/presentation/widgets/provider_filter_panel.dart';

class DoctorListScreen extends ConsumerStatefulWidget {
  const DoctorListScreen({super.key});

  static const routePath = '/providers/doctors';
  static const routeName = 'doctorList';

  @override
  ConsumerState<DoctorListScreen> createState() => _DoctorListScreenState();
}

class _DoctorListScreenState extends ConsumerState<DoctorListScreen> {
  late final TextEditingController _searchCtrl;

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController(
      text: ref.read(doctorListQueryProvider).nameSearch ?? '',
    );
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<DoctorSummary> _visibleDoctors(
    List<DoctorSummary> doctors,
    String localTrim,
  ) {
    if (localTrim.isEmpty) return doctors;
    final q = localTrim.toLowerCase();
    return doctors.where((d) => d.name.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(doctorsListProvider);
    final notifier = ref.read(doctorsListProvider.notifier);
    final query = ref.watch(doctorListQueryProvider);
    final scheme = Theme.of(context).colorScheme;
    final hPad = pdScreenPadding(context).horizontal;
    final maxW = pdReadableMaxWidth(context);

    return Scaffold(
      appBar: AppBar(title: const Text('ডাক্তার খুঁজুন')),
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
                            .read(doctorListQueryProvider.notifier)
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
                        .read(doctorListQueryProvider.notifier)
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
            showOnlineConsultation: true,
            showAiTechnicianServiceFilter: false,
            onQueryChanged: (q) {
              ref.read(doctorListQueryProvider.notifier).apply(q);
            },
          ),
          Expanded(
            child: async.when(
              loading: () =>
                  const PdLoadingBody(message: 'ডাক্তারের তালিকা লোড হচ্ছে…'),
              error: (e, _) => PdErrorBody(
                title: 'লোড করা যায়নি',
                message: e is ProviderApiException ? e.message : e.toString(),
                retryLabel: 'আবার চেষ্টা',
                onRetry: () => notifier.refresh(),
              ),
              data: (data) {
                final local = (query.nameSearch ?? '').trim();
                final visible = _visibleDoctors(data.doctors, local);
                if (visible.isEmpty) {
                  return PdEmptyState(
                    icon: Icons.search_off,
                    title: 'কোনো ডাক্তার পাওয়া যায়নি',
                    subtitle: 'ফিল্টার বা নাম বদলে আবার চেষ্টা করুন।',
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
                                  for (final d in visible) ...[
                                    ProviderCard(
                                      profile:
                                          ProviderProfile.fromDoctorSummary(d),
                                      onOpenDetail: () => context.push(
                                        DoctorDetailScreen.pathFor(d.id),
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

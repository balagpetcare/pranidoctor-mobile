import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pranidoctor_mobile/src/app/screen_padding.dart';
import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_async_list_status.dart';
import 'package:pranidoctor_mobile/src/app/user_visible_async_error.dart';
import 'package:pranidoctor_mobile/src/core/assets/prani_assets.dart';
import 'package:pranidoctor_mobile/src/features/providers/application/provider_finder_providers.dart';
import 'package:pranidoctor_mobile/src/features/providers/data/provider_finder_repository.dart';
import 'package:pranidoctor_mobile/src/features/providers/presentation/doctor_detail_screen.dart';
import 'package:pranidoctor_mobile/src/features/providers/presentation/widgets/doctor_summary_card.dart';
import 'package:pranidoctor_mobile/src/features/providers/presentation/widgets/provider_filter_panel.dart';

class DoctorListScreen extends ConsumerWidget {
  const DoctorListScreen({super.key});

  static const routePath = '/providers/doctors';
  static const routeName = 'doctorList';

  static const double _heroAspectRatio = 2.05;

  static String _apiErrorDetail(Object e) {
    if (e is ProviderApiException) return e.message;
    return userVisibleAsyncErrorBn(e);
  }

  static Future<void> _openDoctorDetail(BuildContext context, String id) async {
    if (id.trim().isEmpty) return;
    try {
      await context.push(DoctorDetailScreen.pathFor(id));
    } catch (e, stack) {
      assert(() {
        debugPrint('DoctorListScreen: push detail failed: $e\n$stack');
        return true;
      }());
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text('বিবরণ খুলতে সমস্যা হয়েছে।'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(doctorsListProvider);
    final notifier = ref.read(doctorsListProvider.notifier);
    final query = ref.watch(doctorListQueryProvider);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final hPad = pdScreenPadding(context).horizontal;
    final maxW = pdReadableMaxWidth(context);
    final bottomPad =
        20.0 + MediaQuery.viewPaddingOf(context).bottom.clamp(0.0, 32.0);

    Future<void> onRefresh() async {
      await notifier.refresh();
    }

    return Scaffold(
      appBar: AppBar(title: const Text('ডাক্তার খুঁজুন')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 0),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxW),
                child: PraniBrandHero(
                  assetPath: PraniAssets.doctorVisitCow,
                  aspectRatio: _heroAspectRatio,
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                  borderRadius: BorderRadius.circular(16),
                  semanticLabel: 'খামারে গরু ও ডাক্তার পরিদর্শনের চিত্রায়ণ',
                ),
              ),
            ),
          ),
          ProviderFilterPanel(
            query: query,
            horizontalPadding: hPad,
            showOnlineConsultation: true,
            onQueryChanged: (q) {
              ref.read(doctorListQueryProvider.notifier).apply(q);
            },
          ),
          const SizedBox(height: 6),
          Expanded(
            child: RefreshIndicator(
              onRefresh: onRefresh,
              child: async.when(
                loading: () => ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.only(bottom: bottomPad),
                  children: [
                    const SizedBox(height: 16),
                    Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: maxW),
                        child: Column(
                          children: [
                            PraniAsyncLoadingCard(
                              height: (MediaQuery.sizeOf(context).height * 0.2)
                                  .clamp(132.0, 196.0),
                            ),
                            const SizedBox(height: PraniSpacing.md),
                            Text(
                              'ডাক্তার তালিকা লোড হচ্ছে…',
                              style: textTheme.bodyMedium?.copyWith(
                                color: scheme.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                error: (e, stack) {
                  assert(() {
                    debugPrint('doctorsListProvider error: $e\n$stack');
                    return true;
                  }());
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(hPad, 8, hPad, bottomPad),
                    children: [
                      Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: maxW),
                          child: PraniAsyncErrorCard(
                            title: 'ডাক্তার তালিকা লোড করা যায়নি',
                            subtitle:
                                'ইন্টারনেট সংযোগ বা সার্ভার সমস্যা হতে পারে।',
                            detail: _apiErrorDetail(e),
                            actionLabel: 'আবার চেষ্টা করুন',
                            onAction: () => notifier.refresh(),
                          ),
                        ),
                      ),
                    ],
                  );
                },
                data: (data) {
                  if (data.doctors.isEmpty) {
                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(hPad, 4, hPad, bottomPad),
                      children: [
                        Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: maxW),
                            child: PraniAsyncEmptyCard(
                              title: 'কোনো ডাক্তার পাওয়া যায়নি',
                              subtitle:
                                  'ফিল্টার শিথিল করে বা মুছে আবার খুঁজুন। ডাটাবেসে ডাক্তার নাও থাকতে পারে।',
                              actionLabel: 'রিফ্রেশ করুন',
                              onAction: () => onRefresh(),
                              icon: Icons.person_search_rounded,
                              iconColor: scheme.primary.withValues(alpha: 0.75),
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                  return ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(hPad, 4, hPad, bottomPad),
                    itemCount: data.doctors.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(
                            'মোট ${data.pagination.total} জন',
                            style: textTheme.labelLarge?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        );
                      }
                      final d = data.doctors[index - 1];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: DoctorSummaryCard(
                          doctor: d,
                          onTap: () => _openDoctorDetail(context, d.id),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_safe_page.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_section_header.dart';
import 'package:pranidoctor_mobile/src/features/home/application/home_feed_providers.dart';
import 'package:pranidoctor_mobile/src/features/home/application/home_shell_tab_provider.dart';
import 'package:pranidoctor_mobile/src/features/home/data/service_category_item.dart';
import 'package:pranidoctor_mobile/src/features/home/presentation/home_layout_constants.dart';
import 'package:pranidoctor_mobile/src/features/home/presentation/widgets/emergency_cta_card.dart';
import 'package:pranidoctor_mobile/src/features/home/presentation/widgets/health_promo_banner.dart';
import 'package:pranidoctor_mobile/src/features/home/presentation/widgets/home_hero_card.dart';
import 'package:pranidoctor_mobile/src/features/home/presentation/widgets/home_search_card.dart';
import 'package:pranidoctor_mobile/src/features/home/presentation/widgets/home_services_grid.dart';
import 'package:pranidoctor_mobile/src/features/home/presentation/widgets/home_top_bar.dart';
import 'package:pranidoctor_mobile/src/features/home/presentation/widgets/nearby_doctors_section.dart';
import 'package:pranidoctor_mobile/src/features/knowledge_hub/presentation/knowledge_hub_home_screen.dart';
import 'package:pranidoctor_mobile/src/features/notifications/application/notifications_providers.dart';
import 'package:pranidoctor_mobile/src/features/profile/application/profile_providers.dart';
import 'package:pranidoctor_mobile/src/features/profile/data/mobile_user_model.dart';
import 'package:pranidoctor_mobile/src/features/providers/application/provider_finder_providers.dart';
import 'package:pranidoctor_mobile/src/features/providers/data/provider_list_query.dart';
import 'package:pranidoctor_mobile/src/features/providers/presentation/doctor_list_screen.dart';
import 'package:pranidoctor_mobile/src/features/providers/presentation/technician_list_screen.dart';
import 'package:pranidoctor_mobile/src/features/service_requests/presentation/booking_wizard_screen.dart';

/// Customer home — marketing layout wired to `/api/mobile/*` where available.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const _subtitle =
      'আজ আপনার পোষা/গৃহপালিত প্রাণীর জন্য আমরা কীভাবে সাহায্য করতে পারি?';

  static String _greetingFirstName(MobileUser user) {
    final raw = user.name.trim();
    if (raw.isEmpty) return '';
    const generic = {'ব্যবহারকারী', 'অতিথি ব্যবহারকারী'};
    if (generic.contains(raw)) return '';
    final parts = raw.split(RegExp(r'\s+'));
    return parts.first;
  }

  static Map<String, String> _slugToId(List<ServiceCategoryItem> cats) {
    return {for (final c in cats) c.slug: c.id};
  }

  static void _safePushNamed(BuildContext context, String routeName) {
    try {
      context.pushNamed(routeName);
    } catch (e, stack) {
      assert(() {
        debugPrint('HomeScreen: pushNamed($routeName) failed: $e\n$stack');
        return true;
      }());
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text('পাতাটি খুলতে সমস্যা হয়েছে। পরে আবার চেষ্টা করুন।'),
          ),
        );
      }
    }
  }

  static void _snack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(behavior: SnackBarBehavior.floating, content: Text(message)),
    );
  }

  static void _openDoctorFinder(BuildContext context) {
    try {
      context.pushNamed(DoctorListScreen.routeName);
    } catch (e, stack) {
      assert(() {
        debugPrint('HomeScreen: doctor list failed: $e\n$stack');
        return true;
      }());
      if (context.mounted) {
        _snack(context, 'ডাক্তার তালিকা খুলতে সমস্যা হয়েছে।');
      }
    }
  }

  static void _openDoctorListAll(BuildContext context, WidgetRef ref) {
    ref.read(doctorListQueryProvider.notifier).apply(ProviderListQuery.initial);
    _openDoctorFinder(context);
  }

  static void _onServiceTap(
    BuildContext context,
    WidgetRef ref,
    int index,
    Map<String, String> bySlug,
  ) {
    void openDoctorAfter(void Function() apply) {
      apply();
      _openDoctorFinder(context);
    }

    switch (index) {
      case 0:
        openDoctorAfter(() {
          ref
              .read(doctorListQueryProvider.notifier)
              .apply(ProviderListQuery.initial);
        });
        break;
      case 1:
        final id = bySlug['vaccination'];
        if (id != null && id.isNotEmpty) {
          openDoctorAfter(() {
            ref
                .read(doctorListQueryProvider.notifier)
                .apply(
                  ProviderListQuery.initial.withFilters(serviceCategoryId: id),
                );
          });
        } else {
          _snack(
            context,
            'টিকা সেবার ধরন সার্ভারে পাওয়া যায়নি। ডাক্তার তালিকা খুলে খুঁজুন।',
          );
          openDoctorAfter(() {
            ref
                .read(doctorListQueryProvider.notifier)
                .apply(ProviderListQuery.initial);
          });
        }
        break;
      case 2:
        _snack(context, 'ঔষধ ও পণ্য কেনার সুবিধা শীঘ্রই যুক্ত হবে।');
        break;
      default:
        final id = bySlug['livestock-health-check'] ?? bySlug['doctor-visit'];
        if (id != null && id.isNotEmpty) {
          openDoctorAfter(() {
            ref
                .read(doctorListQueryProvider.notifier)
                .apply(
                  ProviderListQuery.initial.withFilters(serviceCategoryId: id),
                );
          });
        } else {
          _snack(
            context,
            'চেকআপ ক্যাটাগরি পাওয়া যায়নি। সাধারণ ডাক্তার তালিকা খোলা হচ্ছে।',
          );
          openDoctorAfter(() {
            ref
                .read(doctorListQueryProvider.notifier)
                .apply(ProviderListQuery.initial);
          });
        }
    }
  }

  static OutlinedBorder _homeChipShape() {
    return RoundedRectangleBorder(borderRadius: BorderRadius.circular(20));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hPad = HomeLayout.horizontalPadding(context);
    final userAsync = ref.watch(mobileUserProvider);
    final categories = ref
        .watch(homeServiceCategoriesProvider)
        .maybeWhen(data: (d) => d, orElse: () => <ServiceCategoryItem>[]);
    final bySlug = _slugToId(categories);
    final emergencyPhone = ref.watch(effectiveEmergencyPhoneProvider);

    final greetingLine = userAsync.when(
      data: (u) {
        final first = _greetingFirstName(u);
        if (first.isEmpty) return 'হ্যালো! 👋';
        return 'হ্যালো $first! 👋';
      },
      loading: () => 'হ্যালো! 👋',
      error: (_, _) => 'হ্যালো! 👋',
    );

    Future<void> onPullRefresh() async {
      ref.invalidate(mobileUserProvider);
      ref.invalidate(homeServiceCategoriesProvider);
      ref.invalidate(mobileHomeAppConfigProvider);
      ref.invalidate(unreadNotificationsTotalProvider);
      await ref.read(doctorsListProvider.notifier).refresh();
    }

    final scrollBottom = HomeLayout.scrollBottomPadding(context);

    Widget column = Padding(
      padding: EdgeInsets.fromLTRB(hPad, PraniSpacing.xs, hPad, scrollBottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          HomeTopBar(
            onOpenNotifications: () {
              ref.read(homeShellTabIndexProvider.notifier).select(3);
            },
            onQuickBooking: () =>
                _safePushNamed(context, BookingWizardScreen.routeName),
          ),
          userAsync.when(
            loading: () => SizedBox(height: HomeLayout.gapHeroToSearch),
            data: (_) => SizedBox(height: HomeLayout.gapHeroToSearch),
            error: (e, _) => SizedBox(height: HomeLayout.gapHeroToSearch),
          ),
          HomeHeroCard(greetingLine: greetingLine, subtitle: _subtitle),
          SizedBox(height: HomeLayout.gapHeroToSearch),
          HomeSearchCard(
            onSearchTap: () {
              ref
                  .read(doctorListQueryProvider.notifier)
                  .apply(ProviderListQuery.initial);
              _openDoctorFinder(context);
            },
            onFilterTap: () {
              ref
                  .read(doctorListQueryProvider.notifier)
                  .apply(ProviderListQuery.initial);
              _openDoctorFinder(context);
              _snack(context, 'ডাক্তার তালিকার উপরে ফিল্টার ব্যবহার করুন।');
            },
          ),
          SizedBox(height: HomeLayout.gapSearchToServicesHeader),
          PraniSectionHeader(
            title: 'আমাদের সেবা',
            actionLabel: 'সব দেখুন',
            onAction: () => _openDoctorListAll(context, ref),
          ),
          const SizedBox(height: PraniSpacing.sm),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.only(right: hPad),
            child: Row(
              children: [
                ActionChip(
                  label: const Text('হোম ভিজিট'),
                  shape: _homeChipShape(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: PraniSpacing.md,
                    vertical: PraniSpacing.xs,
                  ),
                  onPressed: () {
                    ref
                        .read(doctorListQueryProvider.notifier)
                        .apply(
                          ProviderListQuery.initial.withFilters(
                            homeVisit: true,
                          ),
                        );
                    _openDoctorFinder(context);
                  },
                ),
                const SizedBox(width: PraniSpacing.sm),
                ActionChip(
                  label: const Text('জরুরি ডাক্তার'),
                  shape: _homeChipShape(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: PraniSpacing.md,
                    vertical: PraniSpacing.xs,
                  ),
                  onPressed: () {
                    ref
                        .read(doctorListQueryProvider.notifier)
                        .apply(
                          ProviderListQuery.initial.withFilters(
                            emergency: true,
                          ),
                        );
                    _openDoctorFinder(context);
                  },
                ),
                const SizedBox(width: PraniSpacing.sm),
                ActionChip(
                  label: const Text('AI টেকনিশিয়ান'),
                  shape: _homeChipShape(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: PraniSpacing.md,
                    vertical: PraniSpacing.xs,
                  ),
                  onPressed: () =>
                      _safePushNamed(context, TechnicianListScreen.routeName),
                ),
                const SizedBox(width: PraniSpacing.sm),
                ActionChip(
                  label: const Text('অনলাইন কনসালটেশন'),
                  shape: _homeChipShape(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: PraniSpacing.md,
                    vertical: PraniSpacing.xs,
                  ),
                  onPressed: () {
                    ref
                        .read(doctorListQueryProvider.notifier)
                        .apply(
                          ProviderListQuery.initial.withFilters(
                            onlineConsultation: true,
                          ),
                        );
                    _openDoctorFinder(context);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: PraniSpacing.md),
          HomeServicesGrid(
            onServiceTap: (i) => _onServiceTap(context, ref, i, bySlug),
          ),
          SizedBox(height: HomeLayout.gapSection),
          const NearbyDoctorsSection(),
          SizedBox(height: HomeLayout.gapSection),
          EmergencyCtaCard(
            emergencyPhone: emergencyPhone,
            onCallUnavailable: () => _snack(
              context,
              'জরুরি কলের নম্বর সেট করা নেই। সার্ভারে MOBILE_EMERGENCY_PHONE এনভায়রনমেন্ট ভেরিয়েবল সেট করুন, অথবা ডাক্তার তালিকা থেকে যোগাযোগ করুন।',
            ),
          ),
          SizedBox(height: HomeLayout.gapSection),
          HealthPromoBanner(
            onLearnMore: () =>
                _safePushNamed(context, KnowledgeHubHomeScreen.routeName),
          ),
        ],
      ),
    );

    final sw = MediaQuery.sizeOf(context).width;
    if (sw >= 600) {
      column = Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: column,
        ),
      );
    }

    return PraniSafePage(
      child: RefreshIndicator(
        onRefresh: onPullRefresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [SliverToBoxAdapter(child: column)],
        ),
      ),
    );
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pranidoctor_mobile/src/app/screen_padding.dart';
import 'package:pranidoctor_mobile/src/core/network/api_client.dart';
import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';
import 'package:pranidoctor_mobile/src/features/home/application/home_shell_tab_provider.dart';
import 'package:pranidoctor_mobile/src/features/home/presentation/widgets/customer_home_emergency_cta.dart';
import 'package:pranidoctor_mobile/src/features/home/presentation/widgets/customer_home_hero.dart';
import 'package:pranidoctor_mobile/src/features/home/presentation/widgets/customer_home_nearby_doctors.dart';
import 'package:pranidoctor_mobile/src/features/home/presentation/widgets/customer_home_promo_banner.dart';
import 'package:pranidoctor_mobile/src/features/home/presentation/widgets/customer_home_search_row.dart';
import 'package:pranidoctor_mobile/src/features/home/presentation/widgets/customer_home_services_grid.dart';
import 'package:pranidoctor_mobile/src/features/home/presentation/widgets/customer_home_top_bar.dart';
import 'package:pranidoctor_mobile/src/features/knowledge_hub/presentation/knowledge_hub_home_screen.dart';
import 'package:pranidoctor_mobile/src/features/profile/application/profile_providers.dart';
import 'package:pranidoctor_mobile/src/features/profile/data/mobile_user_model.dart';
import 'package:pranidoctor_mobile/src/features/providers/application/provider_finder_providers.dart';
import 'package:pranidoctor_mobile/src/features/providers/presentation/doctor_list_screen.dart';
import 'package:pranidoctor_mobile/src/features/service_requests/presentation/booking_wizard_screen.dart';

/// Customer home — marketing layout (hero, search, services, nearby doctors, CTA, promo).
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hPad = pdScreenPadding(context).horizontal;
    final maxW = pdReadableMaxWidth(context);
    final base = kDebugMode ? ref.watch(apiClientProvider).baseUrl : null;
    final userAsync = ref.watch(mobileUserProvider);

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
      await ref.read(doctorsListProvider.notifier).refresh();
    }

    return RefreshIndicator(
      onRefresh: onPullRefresh,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxW),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    hPad,
                    0,
                    hPad,
                    PraniSpacing.section,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CustomerHomeTopBar(
                        onOpenNotifications: () {
                          ref
                              .read(homeShellTabIndexProvider.notifier)
                              .select(3);
                        },
                        onQuickBooking: () => _safePushNamed(
                          context,
                          BookingWizardScreen.routeName,
                        ),
                      ),
                      CustomerHomeHero(
                        greetingLine: greetingLine,
                        subtitle: _subtitle,
                      ),
                      const SizedBox(height: PraniSpacing.xl),
                      CustomerHomeSearchRow(
                        onSearchTap: () => _openDoctorFinder(context),
                        onFilterTap: () {
                          _openDoctorFinder(context);
                          _snack(
                            context,
                            'ডাক্তার তালিকার উপরে ফিল্টার ব্যবহার করুন।',
                          );
                        },
                      ),
                      const SizedBox(height: PraniSpacing.xl),
                      Text(
                        'আমাদের সেবা',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: PraniSpacing.md),
                      CustomerHomeServicesGrid(
                        onServiceTap: (i) {
                          switch (i) {
                            case 0:
                              _openDoctorFinder(context);
                              break;
                            case 1:
                              _snack(
                                context,
                                'টিকা ও ভ্যাকসিনেশন সেবা শীঘ্রই চালু হবে।',
                              );
                              break;
                            case 2:
                              _snack(
                                context,
                                'ঔষধ ও পণ্য কেনার সুবিধা শীঘ্রই যুক্ত হবে।',
                              );
                              break;
                            default:
                              _snack(
                                context,
                                'স্বাস্থ্য চেকআপ প্যাকেজ শীঘ্রই চালু হবে।',
                              );
                          }
                        },
                      ),
                      const SizedBox(height: PraniSpacing.xl),
                      const CustomerHomeNearbyDoctors(),
                      const SizedBox(height: PraniSpacing.xl),
                      CustomerHomeEmergencyCta(
                        onCallPressed: () {
                          _snack(
                            context,
                            'সরাসরি কল সুবিধা শীঘ্রই যুক্ত হবে। জরুরি হলে ডাক্তার তালিকা থেকে যোগাযোগ করুন।',
                          );
                        },
                      ),
                      const SizedBox(height: PraniSpacing.xl),
                      CustomerHomePromoBanner(
                        onLearnMore: () => _safePushNamed(
                          context,
                          KnowledgeHubHomeScreen.routeName,
                        ),
                      ),
                      if (kDebugMode && base != null) ...[
                        const SizedBox(height: PraniSpacing.xl),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(PraniSpacing.xl),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'API ক্লায়েন্ট (ডিবাগ)',
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                                const SizedBox(height: PraniSpacing.xxs + 2),
                                SelectableText(
                                  base,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ),
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
  }
}

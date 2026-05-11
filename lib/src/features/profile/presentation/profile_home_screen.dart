import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pranidoctor_mobile/src/app/screen_padding.dart';
import 'package:pranidoctor_mobile/src/design_system/prani_page_insets.dart';
import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';
import 'package:pranidoctor_mobile/src/features/ai_farmer_services/presentation/ai_my_requests_screen.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/presentation/ai_technician_application_entry_screen.dart';
import 'package:pranidoctor_mobile/src/features/notifications/presentation/notifications_list_screen.dart';
import 'package:pranidoctor_mobile/src/features/profile/application/profile_dashboard_providers.dart';
import 'package:pranidoctor_mobile/src/features/profile/application/profile_providers.dart';
import 'package:pranidoctor_mobile/src/features/profile/data/mobile_user_model.dart';
import 'package:pranidoctor_mobile/src/features/profile/presentation/app_settings_screen.dart';
import 'package:pranidoctor_mobile/src/features/profile/presentation/area_setting_screen.dart';
import 'package:pranidoctor_mobile/src/features/profile/presentation/edit_profile_screen.dart';
import 'package:pranidoctor_mobile/src/features/profile/presentation/help_support_screen.dart';
import 'package:pranidoctor_mobile/src/features/profile/presentation/widgets/account_menu_section.dart';
import 'package:pranidoctor_mobile/src/features/profile/presentation/widgets/account_menu_tile.dart';
import 'package:pranidoctor_mobile/src/features/profile/presentation/widgets/logout_tile.dart';
import 'package:pranidoctor_mobile/src/features/profile/presentation/widgets/profile_login_required_gate.dart';
import 'package:pranidoctor_mobile/src/features/profile/presentation/widgets/profile_header_card.dart';
import 'package:pranidoctor_mobile/src/features/profile/presentation/widgets/professional_dashboard_compact.dart';
import 'package:pranidoctor_mobile/src/features/session/application/session_notifier.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_loading_state.dart';

/// Customer profile hub (bottom tab body): header, menu, support, logout.
class ProfileHomeScreen extends ConsumerWidget {
  const ProfileHomeScreen({super.key});

  static Future<void> _safePush(BuildContext context, String location) async {
    try {
      await context.push(location);
    } catch (e, stack) {
      assert(() {
        debugPrint('ProfileHomeScreen: push failed: $e\n$stack');
        return true;
      }());
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text('এই পাতাটি খুলতে পারিনি।'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authed = ref.watch(
      sessionNotifierProvider.select((s) => s.isAuthenticated),
    );
    if (!authed) {
      return const ProfileLoginRequiredGate();
    }

    final asyncUser = ref.watch(mobileUserProvider);
    final scheme = Theme.of(context).colorScheme;

    Future<void> onRefresh() async {
      ref.invalidate(mobileUserProvider);
      ref.invalidate(profileDashboardContextProvider);
      try {
        await ref.read(mobileUserProvider.future);
      } catch (_) {
        /* RefreshIndicator — errors surface as guest data. */
      }
    }

    return Scaffold(
      backgroundColor: scheme.surfaceContainerLowest,
      body: SafeArea(
        top: true,
        bottom: false,
        child: asyncUser.when(
          loading: () => CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: PraniLoadingState(
                    message: 'প্রোফাইল লোড হচ্ছে…',
                    compact: false,
                  ),
                ),
              ),
            ],
          ),
          error: (e, stack) {
            assert(() {
              debugPrint('mobileUserProvider unexpected error: $e\n$stack');
              return true;
            }());
            return _ProfileScrollBody(
              user: MobileUser.guestFallback(
                MobileProfileLoadStatus.fallbackUnavailable,
              ),
              forceInfoBanner: true,
              onRefresh: onRefresh,
            );
          },
          data: (user) {
            if (user.loadStatus == MobileProfileLoadStatus.signedOut) {
              return const ProfileLoginRequiredGate();
            }
            return _ProfileScrollBody(
              user: user,
              forceInfoBanner: false,
              onRefresh: onRefresh,
            );
          },
        ),
      ),
    );
  }
}

class _ProfileScrollBody extends ConsumerStatefulWidget {
  const _ProfileScrollBody({
    required this.user,
    required this.forceInfoBanner,
    required this.onRefresh,
  });

  final MobileUser user;
  final bool forceInfoBanner;
  final Future<void> Function() onRefresh;

  @override
  ConsumerState<_ProfileScrollBody> createState() => _ProfileScrollBodyState();
}

class _ProfileScrollBodyState extends ConsumerState<_ProfileScrollBody> {
  bool _retryBusy = false;

  bool get _showInfoBanner =>
      widget.forceInfoBanner ||
      widget.user.loadStatus != MobileProfileLoadStatus.loaded;

  Future<void> _onRetryLoad() async {
    if (_retryBusy) return;
    setState(() => _retryBusy = true);
    ref.invalidate(mobileUserProvider);
    try {
      await ref.read(mobileUserProvider.future);
    } catch (_) {
      /* Guest fallback — no throw to UI. */
    }
    if (mounted) {
      setState(() => _retryBusy = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    final hPad = PraniPageInsets.horizontalPadding(context);
    final maxW = pdReadableMaxWidth(context);
    final bottomPad = PraniPageInsets.bottomNavContentPadding(
      context,
      comfortGap: 28,
    );
    final name = widget.user.name.trim();
    final locationPreview = !widget.user.isLocationConfigured
        ? 'লোকেশন সেটআপ করুন'
        : MobileUser.areaLooksLikeRealUserLocation(widget.user.area)
            ? widget.user.area!.trim()
            : (widget.user.villageName?.trim().isNotEmpty == true
                ? widget.user.villageName!.trim()
                : 'ঠিকানা সংরক্ষিত');

    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: EdgeInsets.fromLTRB(hPad, 10, hPad, 8),
            sliver: SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxW),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_showInfoBanner) ...[
                        _ProfileSoftInfoBanner(
                          onRetry: _onRetryLoad,
                          retryBusy: _retryBusy,
                        ),
                        const SizedBox(height: PraniSpacing.md),
                      ],
                      ProfileHeaderCard(
                        user: widget.user,
                        onPrimaryAction: () async {
                          await ProfileHomeScreen._safePush(
                            context,
                            EditProfileScreen.routePath,
                          );
                          if (context.mounted) {
                            ref.invalidate(mobileUserProvider);
                          }
                        },
                      ),
                      const SizedBox(height: PraniSpacing.md),
                      const ProfessionalDashboardCompact(),
                      const SizedBox(height: PraniSpacing.lg),
                      AccountMenuSection(
                        title: 'অ্যাকাউন্ট ও সেটিংস',
                        helperText: 'প্রোফাইল, ঠিকানা ও অ্যাপ নিয়ন্ত্রণ',
                        tiles: [
                          AccountMenuTile(
                            icon: Icons.person_outline,
                            title: 'আমার প্রোফাইল',
                            subtitle: name.isEmpty
                                ? 'প্রোফাইল তথ্য যোগ করুন'
                                : 'ব্যক্তিগত তথ্য ও যোগাযোগ',
                            onTap: () => ProfileHomeScreen._safePush(
                              context,
                              EditProfileScreen.routePath,
                            ),
                          ),
                          AccountMenuTile(
                            icon: Icons.place_outlined,
                            title: 'ঠিকানা / এলাকা',
                            subtitle: locationPreview,
                            onTap: () => ProfileHomeScreen._safePush(
                              context,
                              AreaSettingScreen.routePath,
                            ),
                          ),
                          AccountMenuTile(
                            icon: Icons.support_agent_outlined,
                            title: 'এআই টেকনিশিয়ান',
                            subtitle: 'আবেদন ও স্ট্যাটাস দেখুন',
                            onTap: () => ProfileHomeScreen._safePush(
                              context,
                              AiTechnicianApplicationEntryScreen.routePath,
                            ),
                          ),
                          AccountMenuTile(
                            icon: Icons.history_rounded,
                            title: 'আমার অনুরোধসমূহ',
                            subtitle: 'সেবা অনুরোধ ও ইতিহাস',
                            onTap: () => ProfileHomeScreen._safePush(
                              context,
                              AiMyServiceRequestsScreen.routePath,
                            ),
                          ),
                          AccountMenuTile(
                            icon: Icons.notifications_outlined,
                            title: 'বিজ্ঞপ্তি',
                            subtitle: 'আপডেট ও নোটিফিকেশন',
                            onTap: () => ProfileHomeScreen._safePush(
                              context,
                              NotificationsListScreen.routePath,
                            ),
                          ),
                          AccountMenuTile(
                            icon: Icons.settings_outlined,
                            title: 'সেটিংস',
                            subtitle: 'অ্যাপ পছন্দ ও প্রাইভেসি',
                            onTap: () => ProfileHomeScreen._safePush(
                              context,
                              AppSettingsScreen.routePath,
                            ),
                          ),
                          AccountMenuTile(
                            icon: Icons.help_outline,
                            title: 'সহায়তা ও সাপোর্ট',
                            subtitle: 'যোগাযোগ ও নির্দেশনা',
                            onTap: () => ProfileHomeScreen._safePush(
                              context,
                              HelpSupportScreen.routePath,
                            ),
                          ),
                          const LogoutTile(),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(hPad, 0, hPad, bottomPad),
            sliver: const SliverToBoxAdapter(child: SizedBox.shrink()),
          ),
        ],
      ),
    );
  }
}

class _ProfileSoftInfoBanner extends StatelessWidget {
  const _ProfileSoftInfoBanner({
    required this.onRetry,
    required this.retryBusy,
  });

  final VoidCallback onRetry;
  final bool retryBusy;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.secondaryContainer.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(PraniRadii.lg),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.65),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(PraniSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: scheme.primary,
                  size: 22,
                ),
                const SizedBox(width: PraniSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'প্রোফাইল তথ্য এখনো পাওয়া যায়নি',
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: scheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'আপনি অতিথি হিসেবে অ্যাপ ব্যবহার করছেন। লগইন বা প্রোফাইল সেটআপ করলে তথ্য দেখা যাবে।',
                        style: textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: PraniSpacing.md),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.tonal(
                onPressed: retryBusy ? null : onRetry,
                child: retryBusy
                    ? SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: scheme.primary,
                        ),
                      )
                    : const Text('আবার চেষ্টা করুন'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

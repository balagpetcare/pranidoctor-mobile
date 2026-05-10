import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pranidoctor_mobile/src/app/screen_padding.dart';
import 'package:pranidoctor_mobile/src/design_system/prani_page_insets.dart';
import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_loading_state.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_premium_card.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_profile_section_header.dart';
import 'package:pranidoctor_mobile/src/features/auth/login_entry_screen.dart';
import 'package:pranidoctor_mobile/src/features/home/application/home_shell_tab_provider.dart';
import 'package:pranidoctor_mobile/src/features/knowledge_hub/presentation/knowledge_hub_home_screen.dart';
import 'package:pranidoctor_mobile/src/features/notifications/application/notifications_providers.dart';
import 'package:pranidoctor_mobile/src/features/notifications/presentation/notifications_list_screen.dart';
import 'package:pranidoctor_mobile/src/features/profile/application/profile_providers.dart';
import 'package:pranidoctor_mobile/src/features/profile/data/mobile_user_model.dart';
import 'package:pranidoctor_mobile/src/features/profile/presentation/about_screen.dart';
import 'package:pranidoctor_mobile/src/features/profile/presentation/app_settings_screen.dart';
import 'package:pranidoctor_mobile/src/features/profile/presentation/area_setting_screen.dart';
import 'package:pranidoctor_mobile/src/features/profile/presentation/edit_profile_screen.dart';
import 'package:pranidoctor_mobile/src/features/profile/presentation/help_support_screen.dart';
import 'package:pranidoctor_mobile/src/features/profile/presentation/widgets/logout_confirm_dialog.dart';
import 'package:pranidoctor_mobile/src/features/profile/presentation/widgets/profile_header_card.dart';
import 'package:pranidoctor_mobile/src/features/profile/presentation/widgets/profile_settings_list_tile.dart';
import 'package:pranidoctor_mobile/src/features/profile/presentation/widgets/support_contact_card.dart';
import 'package:pranidoctor_mobile/src/features/animals/presentation/animal_list_screen.dart';
import 'package:pranidoctor_mobile/src/features/session/application/session_notifier.dart';

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
    final asyncUser = ref.watch(mobileUserProvider);
    final scheme = Theme.of(context).colorScheme;

    Future<void> onRefresh() async {
      ref.invalidate(mobileUserProvider);
      try {
        await ref.read(mobileUserProvider.future);
      } catch (_) {
        /* RefreshIndicator — errors surface as guest data. */
      }
    }

    return Scaffold(
      backgroundColor: scheme.surfaceContainerLowest,
      appBar: AppBar(
        title: const Text('প্রোফাইল'),
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
      ),
      body: asyncUser.when(
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
        data: (user) => _ProfileScrollBody(
          user: user,
          forceInfoBanner: false,
          onRefresh: onRefresh,
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

  static List<Widget> _withDividers(BuildContext context, List<Widget> tiles) {
    final line = Theme.of(
      context,
    ).colorScheme.outlineVariant.withValues(alpha: 0.42);
    final out = <Widget>[];
    for (var i = 0; i < tiles.length; i++) {
      out.add(tiles[i]);
      if (i < tiles.length - 1) {
        out.add(Divider(height: 1, thickness: 1, color: line));
      }
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final hPad = PraniPageInsets.horizontalPadding(context);
    final maxW = pdReadableMaxWidth(context);
    final bottomPad = PraniPageInsets.bottomNavContentPadding(
      context,
      comfortGap: 28,
    );
    final auth = ref.watch(sessionNotifierProvider);

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
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: hPad),
            sliver: SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxW),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: PraniSpacing.lg),
                      PraniProfileSectionHeader(title: 'অ্যাকাউন্ট'),
                      PraniPremiumCard(
                        child: Column(
                          children: _withDividers(context, [
                            ProfileSettingsListTile(
                              icon: Icons.person_outlined,
                              title: 'আমার প্রোফাইল',
                              onTap: () async {
                                await ProfileHomeScreen._safePush(
                                  context,
                                  EditProfileScreen.routePath,
                                );
                                if (context.mounted) {
                                  ref.invalidate(mobileUserProvider);
                                }
                              },
                            ),
                            ProfileSettingsListTile(
                              icon: Icons.place_outlined,
                              title: 'ঠিকানা / এলাকা',
                              onTap: () async {
                                await ProfileHomeScreen._safePush(
                                  context,
                                  AreaSettingScreen.routePath,
                                );
                                if (context.mounted) {
                                  ref.invalidate(mobileUserProvider);
                                }
                              },
                            ),
                            ProfileSettingsListTile(
                              icon: Icons.pets_outlined,
                              title: 'আমার প্রাণী',
                              onTap: () => ProfileHomeScreen._safePush(
                                context,
                                AnimalListScreen.routePath,
                              ),
                            ),
                            ProfileSettingsListTile(
                              icon: Icons.grid_view_outlined,
                              title: 'আমার অনুরোধ',
                              onTap: () {
                                ref
                                    .read(homeShellTabIndexProvider.notifier)
                                    .select(2);
                              },
                            ),
                          ]),
                        ),
                      ),
                      const SizedBox(height: PraniSpacing.lg),
                      PraniProfileSectionHeader(title: 'সেবা'),
                      PraniPremiumCard(
                        child: Column(
                          children: _withDividers(context, [
                            ProfileSettingsListTile(
                              icon: Icons.history_rounded,
                              title: 'বুকিং ইতিহাস',
                              onTap: () {
                                ref
                                    .read(homeShellTabIndexProvider.notifier)
                                    .select(2);
                              },
                            ),
                            ProfileSettingsListTile(
                              icon: Icons.payments_outlined,
                              title: 'পেমেন্ট / বিলিং',
                              onTap: () {
                                ref
                                    .read(homeShellTabIndexProvider.notifier)
                                    .select(2);
                              },
                            ),
                            ProfileSettingsListTile(
                              icon: Icons.medical_information_outlined,
                              title: 'প্রেসক্রিপশন / চিকিৎসা সারাংশ',
                              onTap: () => ProfileHomeScreen._safePush(
                                context,
                                KnowledgeHubHomeScreen.routePath,
                              ),
                            ),
                          ]),
                        ),
                      ),
                      const SizedBox(height: PraniSpacing.lg),
                      PraniProfileSectionHeader(title: 'অ্যাপ'),
                      PraniPremiumCard(
                        child: Column(
                          children: _withDividers(context, [
                            ProfileSettingsListTile(
                              icon: Icons.notifications_outlined,
                              title: 'নোটিফিকেশন',
                              trailing: ref
                                  .watch(unreadNotificationsTotalProvider)
                                  .when(
                                    data: (c) => c > 0
                                        ? Badge(
                                            label: Text(c > 99 ? '99+' : '$c'),
                                            child: const Icon(
                                              Icons.chevron_right,
                                            ),
                                          )
                                        : const Icon(Icons.chevron_right),
                                    loading: () =>
                                        const Icon(Icons.chevron_right),
                                    error: (e, _) =>
                                        const Icon(Icons.chevron_right),
                                  ),
                              onTap: () => ProfileHomeScreen._safePush(
                                context,
                                NotificationsListScreen.routePath,
                              ),
                            ),
                            ProfileSettingsListTile(
                              icon: Icons.settings_outlined,
                              title: 'অ্যাপ সেটিংস',
                              onTap: () => ProfileHomeScreen._safePush(
                                context,
                                AppSettingsScreen.routePath,
                              ),
                            ),
                            ProfileSettingsListTile(
                              icon: Icons.support_agent_outlined,
                              title: 'হেল্প / সাপোর্ট',
                              onTap: () => ProfileHomeScreen._safePush(
                                context,
                                HelpSupportScreen.routePath,
                              ),
                            ),
                            ProfileSettingsListTile(
                              icon: Icons.info_outline,
                              title: 'প্রাণী ডাক্তার সম্পর্কে',
                              onTap: () => ProfileHomeScreen._safePush(
                                context,
                                AboutScreen.routePath,
                              ),
                            ),
                            ProfileSettingsListTile(
                              icon: auth.isAuthenticated
                                  ? Icons.logout_rounded
                                  : Icons.login_rounded,
                              title: auth.isAuthenticated
                                  ? 'লগআউট'
                                  : 'লগইন করুন',
                              onTap: () async {
                                if (auth.isAuthenticated) {
                                  await showPdLogoutConfirmAndExecute(
                                    context,
                                    ref,
                                  );
                                } else if (context.mounted) {
                                  context.go(LoginEntryScreen.routePath);
                                }
                              },
                            ),
                          ]),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(hPad, PraniSpacing.lg, hPad, 8),
            sliver: SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxW),
                  child: const SupportContactCard(),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(hPad, 8, hPad, bottomPad),
            sliver: SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxW),
                  child: Text(
                    'প্রাণী ডাক্তার অ্যাপ ব্যবহারের জন্য ধন্যবাদ।',
                    textAlign: TextAlign.center,
                    style: textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      height: 1.35,
                    ),
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

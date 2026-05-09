import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pranidoctor_mobile/src/app/screen_padding.dart';
import 'package:pranidoctor_mobile/src/features/notifications/application/notifications_providers.dart';
import 'package:pranidoctor_mobile/src/features/notifications/presentation/notifications_list_screen.dart';
import 'package:pranidoctor_mobile/src/features/profile/application/profile_providers.dart';
import 'package:pranidoctor_mobile/src/features/profile/data/profile_api_exception.dart';
import 'package:pranidoctor_mobile/src/features/profile/presentation/about_screen.dart';
import 'package:pranidoctor_mobile/src/features/profile/presentation/app_settings_screen.dart';
import 'package:pranidoctor_mobile/src/features/profile/presentation/area_setting_screen.dart';
import 'package:pranidoctor_mobile/src/features/profile/presentation/edit_profile_screen.dart';
import 'package:pranidoctor_mobile/src/features/profile/presentation/help_support_screen.dart';
import 'package:pranidoctor_mobile/src/features/profile/presentation/widgets/logout_confirm_dialog.dart';
import 'package:pranidoctor_mobile/src/features/profile/presentation/widgets/profile_header_card.dart';
import 'package:pranidoctor_mobile/src/features/profile/presentation/widgets/profile_settings_list_tile.dart';
import 'package:pranidoctor_mobile/src/features/profile/presentation/widgets/support_contact_card.dart';

/// Customer profile hub (bottom tab body): header, menu, support, logout.
class ProfileHomeScreen extends ConsumerWidget {
  const ProfileHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncUser = ref.watch(mobileUserProvider);
    final scheme = Theme.of(context).colorScheme;
    final hPad = pdScreenPadding(context).horizontal;

    return Scaffold(
      appBar: AppBar(title: const Text('প্রোফাইল')),
      body: asyncUser.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: hPad),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: scheme.error),
                const SizedBox(height: 12),
                Text(
                  e is ProfileApiException
                      ? e.message
                      : 'প্রোফাইল লোড করা যায়নি।',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => ref.invalidate(mobileUserProvider),
                  child: const Text('আবার চেষ্টা করুন'),
                ),
              ],
            ),
          ),
        ),
        data: (user) => RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(mobileUserProvider);
            await ref.read(mobileUserProvider.future);
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 8),
                sliver: SliverToBoxAdapter(
                  child: ProfileHeaderCard(user: user),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: hPad),
                sliver: SliverToBoxAdapter(
                  child: Card(
                    child: Column(
                      children: [
                        ProfileSettingsListTile(
                          icon: Icons.edit_outlined,
                          title: 'প্রোফাইল সম্পাদনা',
                          onTap: () async {
                            await context.push(EditProfileScreen.routePath);
                            if (context.mounted) {
                              ref.invalidate(mobileUserProvider);
                            }
                          },
                        ),
                        const Divider(height: 1),
                        ProfileSettingsListTile(
                          icon: Icons.place_outlined,
                          title: 'এলাকা / ঠিকানা',
                          onTap: () async {
                            await context.push(AreaSettingScreen.routePath);
                            if (context.mounted) {
                              ref.invalidate(mobileUserProvider);
                            }
                          },
                        ),
                        const Divider(height: 1),
                        ProfileSettingsListTile(
                          icon: Icons.settings_outlined,
                          title: 'সেটিংস',
                          onTap: () =>
                              context.push(AppSettingsScreen.routePath),
                        ),
                        const Divider(height: 1),
                        ProfileSettingsListTile(
                          icon: Icons.help_outline,
                          title: 'সাহায্য ও সহায়তা',
                          onTap: () =>
                              context.push(HelpSupportScreen.routePath),
                        ),
                        const Divider(height: 1),
                        ProfileSettingsListTile(
                          icon: Icons.info_outline,
                          title: 'আমাদের সম্পর্কে',
                          onTap: () => context.push(AboutScreen.routePath),
                        ),
                        const Divider(height: 1),
                        ProfileSettingsListTile(
                          icon: Icons.notifications_outlined,
                          title: 'নোটিফিকেশন',
                          trailing: ref
                              .watch(unreadNotificationsTotalProvider)
                              .when(
                                data: (c) => c > 0
                                    ? Badge(
                                        label: Text(c > 99 ? '99+' : '$c'),
                                        child: const Icon(Icons.chevron_right),
                                      )
                                    : const Icon(Icons.chevron_right),
                                loading: () => const Icon(Icons.chevron_right),
                                error: (_, _) =>
                                    const Icon(Icons.chevron_right),
                              ),
                          onTap: () =>
                              context.push(NotificationsListScreen.routePath),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 8),
                sliver: const SliverToBoxAdapter(child: SupportContactCard()),
              ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 32),
                sliver: SliverToBoxAdapter(
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        showPdLogoutConfirmAndExecute(context, ref),
                    icon: const Icon(Icons.logout),
                    label: const Text('লগআউট'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

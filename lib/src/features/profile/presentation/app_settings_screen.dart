import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pranidoctor_mobile/src/app/screen_padding.dart';
import 'package:pranidoctor_mobile/src/features/profile/presentation/about_screen.dart';
import 'package:pranidoctor_mobile/src/features/profile/presentation/edit_profile_screen.dart';
import 'package:pranidoctor_mobile/src/features/profile/presentation/help_support_screen.dart';
import 'package:pranidoctor_mobile/src/features/profile/presentation/widgets/logout_confirm_dialog.dart';
import 'package:pranidoctor_mobile/src/features/profile/presentation/widgets/profile_settings_list_tile.dart';

class AppSettingsScreen extends ConsumerWidget {
  const AppSettingsScreen({super.key});

  static const routePath = '/profile/settings';
  static const routeName = 'profileSettings';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hPad = pdScreenPadding(context).horizontal;
    return Scaffold(
      appBar: AppBar(title: const Text('সেটিংস')),
      body: ListView(
        padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 32),
        children: [
          Text('অ্যাপ পছন্দ', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ProfileSettingsListTile(
                  icon: Icons.notifications_outlined,
                  title: 'বিজ্ঞপ্তি',
                  subtitle: 'ক্যাটাগরি ও লোকাল প্রিভিউ',
                  onTap: () => context.push('/notifications/preferences'),
                ),
                const Divider(height: 1),
                ProfileSettingsListTile(
                  icon: Icons.language_outlined,
                  title: 'ভাষা',
                  subtitle: 'বাংলা (ডিফল্ট)',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'ভাষা নির্বাচন শীঘ্রই যুক্ত হবে। এখন অ্যাপ বাংলায়।',
                        ),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                ProfileSettingsListTile(
                  icon: Icons.palette_outlined,
                  title: 'থিম',
                  subtitle: 'সিস্টেম অনুযায়ী',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'থিম নির্বাচন শীঘ্রই যুক্ত হবে। এখন ডিভাইস সেটিংস অনুসরণ করে।',
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'অ্যাকাউন্ট ও তথ্য',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ProfileSettingsListTile(
                  icon: Icons.person_outline,
                  title: 'প্রোফাইল সম্পাদনা',
                  onTap: () => context.push(EditProfileScreen.routePath),
                ),
                const Divider(height: 1),
                ProfileSettingsListTile(
                  icon: Icons.help_outline,
                  title: 'সাহায্য ও সহায়তা',
                  onTap: () => context.push(HelpSupportScreen.routePath),
                ),
                const Divider(height: 1),
                ProfileSettingsListTile(
                  icon: Icons.info_outline,
                  title: 'আমাদের সম্পর্কে',
                  onTap: () => context.push(AboutScreen.routePath),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () => showPdLogoutConfirmAndExecute(context, ref),
            icon: const Icon(Icons.logout),
            label: const Text('লগআউট'),
          ),
        ],
      ),
    );
  }
}

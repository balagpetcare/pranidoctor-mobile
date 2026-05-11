import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pranidoctor_mobile/src/app/screen_padding.dart';
import 'package:pranidoctor_mobile/src/design_system/prani_design_system.dart';
import 'package:pranidoctor_mobile/src/features/profile/presentation/about_screen.dart';
import 'package:pranidoctor_mobile/src/features/profile/presentation/app_settings_screen.dart';
import 'package:pranidoctor_mobile/src/features/profile/presentation/help_support_screen.dart';
import 'package:pranidoctor_mobile/src/features/profile/presentation/widgets/logout_confirm_dialog.dart';
import 'package:pranidoctor_mobile/src/features/profile/presentation/widgets/profile_settings_list_tile.dart';

/// App settings, help, about — and logout (existing session flow).
class EditProfileAccountScreen extends ConsumerWidget {
  const EditProfileAccountScreen({super.key});

  static const routePath = '/profile/edit/account';
  static const routeName = 'profileEditAccount';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final pad = pdScreenPadding(context);

    return PraniScaffold(
      title: 'অ্যাকাউন্ট সেটিংস',
      subtitle: 'নিরাপত্তা ও পছন্দ',
      body: ListView(
        padding: pad.copyWith(top: PraniSpacing.md, bottom: 32),
        children: [
          PraniPremiumCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                ProfileSettingsListTile(
                  icon: Icons.settings_outlined,
                  title: 'অ্যাপ সেটিংস',
                  subtitle: 'ভাষা, থিম ও বিজ্ঞপ্তি',
                  onTap: () => context.push(AppSettingsScreen.routePath),
                ),
                Divider(
                  height: 1,
                  color: scheme.outlineVariant.withValues(alpha: 0.5),
                ),
                ProfileSettingsListTile(
                  icon: Icons.support_agent_outlined,
                  title: 'হেল্প / সাপোর্ট',
                  subtitle: 'সাহায্য ও যোগাযোগ',
                  onTap: () => context.push(HelpSupportScreen.routePath),
                ),
                Divider(
                  height: 1,
                  color: scheme.outlineVariant.withValues(alpha: 0.5),
                ),
                ProfileSettingsListTile(
                  icon: Icons.info_outline,
                  title: 'প্রাণী ডাক্তার সম্পর্কে',
                  onTap: () => context.push(AboutScreen.routePath),
                ),
              ],
            ),
          ),
          const SizedBox(height: PraniSpacing.section),
          FilledButton.tonalIcon(
            onPressed: () => showPdLogoutConfirmAndExecute(context, ref),
            icon: const Icon(Icons.logout_rounded),
            label: const Text('লগআউট'),
          ),
          const SizedBox(height: PraniSpacing.md),
          Text(
            'লগআউট করলে আবার OTP দিয়ে প্রবেশ করতে হবে।',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

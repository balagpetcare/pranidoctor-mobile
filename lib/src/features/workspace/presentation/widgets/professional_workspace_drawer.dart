import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pranidoctor_mobile/src/features/auth/login_entry_screen.dart';
import 'package:pranidoctor_mobile/src/features/home/home_shell_screen.dart';
import 'package:pranidoctor_mobile/src/features/notifications/presentation/notifications_list_screen.dart';
import 'package:pranidoctor_mobile/src/features/profile/presentation/app_settings_screen.dart';
import 'package:pranidoctor_mobile/src/features/profile/presentation/widgets/logout_confirm_dialog.dart';
import 'package:pranidoctor_mobile/src/features/session/application/session_notifier.dart';
import 'package:pranidoctor_mobile/src/features/workspace/application/professional_workspace_tab_provider.dart';
import 'package:pranidoctor_mobile/src/features/workspace/application/workspace_surface_provider.dart';
import 'package:pranidoctor_mobile/src/features/livestock_booking/presentation/professional_livestock_request_management_screen.dart';
import 'package:pranidoctor_mobile/src/features/professional_profile/domain/professional_persona.dart';
import 'package:pranidoctor_mobile/src/features/professional_verification/presentation/professional_verification_workflow_screen.dart';
import 'package:pranidoctor_mobile/src/features/professional_finance/presentation/professional_wallet_earnings_screen.dart';
import 'package:pranidoctor_mobile/src/features/enterprise_insights/presentation/professional_insights_hub_screen.dart';
import 'package:pranidoctor_mobile/src/features/workspace/presentation/widgets/professional_module_placeholders.dart';

/// Drawer for professional workspace — shared items + workspace switcher.
class ProfessionalWorkspaceDrawer extends ConsumerWidget {
  const ProfessionalWorkspaceDrawer({
    super.key,
    required this.workspaceRole,
  });

  final AppRole workspaceRole;

  Future<void> _onLogout(BuildContext context, WidgetRef ref) async {
    final authed = ref.read(sessionNotifierProvider).isAuthenticated;
    if (authed) {
      await showPdLogoutConfirmAndExecute(context, ref);
      return;
    }
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('প্রস্থান?'),
        content: const Text('ডেমো প্রবেশ মোড বন্ধ করা হবে।'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('থাকুন'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('বের হন'),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    await ref.read(sessionNotifierProvider.notifier).signOut();
    if (context.mounted) {
      context.go(LoginEntryScreen.routePath);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final title = switch (workspaceRole) {
      AppRole.aiTechnician => 'এআই টেকনিশিয়ান',
      AppRole.doctor => 'চিকিৎসক',
      _ => 'পেশাদার',
    };

    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: scheme.primaryContainer.withValues(alpha: 0.35),
              ),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: scheme.onPrimaryContainer,
                      ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.swap_horiz_rounded),
              title: const Text('সাধারণ অ্যাপে যান'),
              subtitle: const Text('গ্রাহক হোম, বুকিং ও সেবা'),
              onTap: () async {
                Navigator.of(context).pop();
                await ref
                    .read(workspaceSurfaceProvider.notifier)
                    .setSurface(WorkspaceSurface.general);
                if (context.mounted) {
                  context.go(HomeShellScreen.routePath);
                }
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.person_outline_rounded),
              title: const Text('পেশাদার প্রোফাইল'),
              onTap: () {
                Navigator.of(context).pop();
                ref.read(professionalWorkspaceTabIndexProvider.notifier).select(4);
              },
            ),
            ListTile(
              leading: const Icon(Icons.verified_user_outlined),
              title: const Text('যাচাইকরণের অবস্থা'),
              onTap: () {
                Navigator.of(context).pop();
                final persona = switch (workspaceRole) {
                  AppRole.doctor => ProfessionalPersona.veterinaryDoctor,
                  AppRole.aiTechnician => ProfessionalPersona.aiTechnician,
                  _ => ProfessionalPersona.aiTechnician,
                };
                context.push(
                  ProfessionalVerificationWorkflowScreen.routeLocation(persona),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.assignment_turned_in_outlined),
              title: const Text('সেবা অনুরোধ ও বুকিং'),
              onTap: () {
                Navigator.of(context).pop();
                context.push(
                  ProfessionalLivestockRequestManagementScreen.routePath,
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.folder_open_outlined),
              title: const Text('নথি'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (ctx) => Scaffold(
                      appBar: AppBar(
                        title: const Text('নথি'),
                        leading: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.of(ctx).pop(),
                        ),
                      ),
                      body: const ProfessionalDocumentsPlaceholder(),
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_balance_wallet_outlined),
              title: const Text('ওয়ালেট ও আয়'),
              onTap: () {
                Navigator.of(context).pop();
                context.push(ProfessionalWalletEarningsScreen.routePath);
              },
            ),
            ListTile(
              leading: const Icon(Icons.analytics_outlined),
              title: const Text('এন্টারপ্রাইজ বিশ্লেষণ'),
              subtitle: const Text('অফলাইন, সিঙ্ক ও অডিট'),
              onTap: () {
                Navigator.of(context).pop();
                context.push(ProfessionalInsightsHubScreen.routePath);
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications_outlined),
              title: const Text('নোটিফিকেশন'),
              onTap: () {
                Navigator.of(context).pop();
                context.push(NotificationsListScreen.routePath);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('সেটিংস'),
              onTap: () {
                Navigator.of(context).pop();
                context.push(AppSettingsScreen.routePath);
              },
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.logout_rounded, color: scheme.error),
              title: Text(
                'লগআউট',
                style: TextStyle(color: scheme.error),
              ),
              onTap: () => _onLogout(context, ref),
            ),
          ],
        ),
      ),
    );
  }
}

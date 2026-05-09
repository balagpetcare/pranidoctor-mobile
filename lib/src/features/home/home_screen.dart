import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/screen_padding.dart';
import '../../core/assets/prani_assets.dart';
import '../../core/network/api_client.dart';
import 'application/home_shell_tab_provider.dart';
import '../providers/presentation/doctor_list_screen.dart';
import '../providers/presentation/technician_list_screen.dart';
import '../knowledge_hub/presentation/knowledge_hub_home_screen.dart';
import '../notifications/presentation/notifications_list_screen.dart';
import '../notifications/presentation/widgets/notification_bell_icon_button.dart';

/// Customer home — quick links; optional debug API card only in debug builds.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const _menuItems = <({String label, IconData icon})>[
    (label: 'জরুরি ডাক্তার ডাকুন', icon: Icons.emergency_outlined),
    (label: 'ডাক্তার খুঁজুন', icon: Icons.medical_services_outlined),
    (label: 'AI টেকনিশিয়ান খুঁজুন', icon: Icons.biotech_outlined),
    (label: 'চিকিৎসার ইতিহাস', icon: Icons.history_edu_outlined),
    (label: 'জ্ঞানকেন্দ্র', icon: Icons.menu_book_outlined),
    (label: 'নোটিফিকেশন', icon: Icons.notifications_outlined),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final hPad = pdScreenPadding(context).horizontal;
    final maxW = pdReadableMaxWidth(context);
    final base = kDebugMode ? ref.watch(apiClientProvider).baseUrl : null;

    return CustomScrollView(
      slivers: [
        SliverAppBar.large(
          title: const Text('হোম'),
          actions: [
            NotificationBellIconButton(
              onPressed: () => context.push(NotificationsListScreen.routePath),
            ),
          ],
        ),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 24),
          sliver: SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxW),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    PraniBrandHero(
                      assetPath: PraniAssets.homeFarmBanner,
                      height: 176,
                      fit: BoxFit.cover,
                      semanticLabel: 'খামার ও প্রাণিসম্পদ সেবার ব্যানার',
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'আপনার খামারের বিশ্বস্ত স্বাস্থ্যসঙ্গী',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'ডাক্তার, জরুরি সেবা, AI টেকনিশিয়ান ও প্রাণী ব্যবস্থাপনা',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 18),
                    for (var i = 0; i < _menuItems.length; i++) ...[
                      if (i > 0) const SizedBox(height: 10),
                      _HomeMenuTile(
                        label: _menuItems[i].label,
                        leadingIcon: _menuItems[i].icon,
                        scheme: scheme,
                        onTap: () {
                          switch (i) {
                            case 0:
                              context.push(DoctorListScreen.routePath);
                              break;
                            case 1:
                              context.push(DoctorListScreen.routePath);
                              break;
                            case 2:
                              context.push(TechnicianListScreen.routePath);
                              break;
                            case 3:
                              ref
                                  .read(homeShellTabIndexProvider.notifier)
                                  .select(1);
                              break;
                            case 4:
                              context.push(KnowledgeHubHomeScreen.routePath);
                              break;
                            case 5:
                              context.push(NotificationsListScreen.routePath);
                              break;
                          }
                        },
                      ),
                    ],
                    if (kDebugMode && base != null) ...[
                      const SizedBox(height: 16),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'API ক্লায়েন্ট (ডিবাগ)',
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              const SizedBox(height: 6),
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
    );
  }
}

class _HomeMenuTile extends StatelessWidget {
  const _HomeMenuTile({
    required this.label,
    required this.leadingIcon,
    required this.scheme,
    required this.onTap,
  });

  final String label;
  final IconData leadingIcon;
  final ColorScheme scheme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: scheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Row(
            children: [
              Icon(leadingIcon, color: scheme.primary, size: 26),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Icon(Icons.chevron_right, color: scheme.outline),
            ],
          ),
        ),
      ),
    );
  }
}

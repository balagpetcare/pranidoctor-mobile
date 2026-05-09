import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/screen_padding.dart';
import '../../core/network/api_client.dart';
import '../providers/presentation/doctor_list_screen.dart';
import '../providers/presentation/technician_list_screen.dart';
import '../knowledge_hub/presentation/knowledge_hub_home_screen.dart';
import '../notifications/presentation/notifications_list_screen.dart';
import '../notifications/presentation/widgets/notification_bell_icon_button.dart';

/// Customer home skeleton — menu items only; no backend calls.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const _menuItems = <String>[
    'জরুরি ডাক্তার ডাকুন',
    'ডাক্তার খুঁজুন',
    'AI টেকনিশিয়ান খুঁজুন',
    'আমার পশু',
    'চিকিৎসার ইতিহাস',
    'জ্ঞানকেন্দ্র',
    'নোটিফিকেশন',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final base = ref.watch(apiClientProvider).baseUrl;
    final hPad = pdScreenPadding(context).horizontal;
    final maxW = pdReadableMaxWidth(context);

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
                    for (var i = 0; i < _menuItems.length; i++) ...[
                      if (i > 0) const SizedBox(height: 10),
                      _HomeMenuTile(
                        label: _menuItems[i],
                        scheme: scheme,
                        onTap: () {
                          switch (i) {
                            case 1:
                              context.push(DoctorListScreen.routePath);
                              break;
                            case 2:
                              context.push(TechnicianListScreen.routePath);
                              break;
                            case 5:
                              context.push(KnowledgeHubHomeScreen.routePath);
                              break;
                            case 6:
                              context.push(NotificationsListScreen.routePath);
                              break;
                            default:
                              break;
                          }
                        },
                      ),
                    ],
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'API ক্লায়েন্ট (ভিত্তি)',
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
    required this.scheme,
    required this.onTap,
  });

  final String label;
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
              Icon(Icons.chevron_right, color: scheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

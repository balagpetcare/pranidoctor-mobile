import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pranidoctor_mobile/src/app/screen_padding.dart';
import 'package:pranidoctor_mobile/src/core/assets/prani_assets.dart';
import 'package:pranidoctor_mobile/src/features/notifications/application/notification_hub_providers.dart';
import 'package:pranidoctor_mobile/src/features/notifications/application/notifications_providers.dart';
import 'package:pranidoctor_mobile/src/features/notifications/data/notification_model.dart';
import 'package:pranidoctor_mobile/src/features/notifications/data/notification_repository.dart';
import 'package:pranidoctor_mobile/src/features/notifications/domain/notification_category_mapper.dart';
import 'package:pranidoctor_mobile/src/features/notifications/presentation/notification_preferences_screen.dart';
import 'package:pranidoctor_mobile/src/features/notifications/presentation/widgets/notification_category_filter_bar.dart';
import 'package:pranidoctor_mobile/src/features/notifications/presentation/widgets/notification_detail_sheet.dart';
import 'package:pranidoctor_mobile/src/features/notifications/presentation/widgets/notification_inbox_tile.dart';

/// Customer notification inbox — `GET /api/mobile/notifications` (Bearer via Dio).
class NotificationsListScreen extends ConsumerWidget {
  const NotificationsListScreen({super.key});

  static const routePath = '/notifications';
  static const routeName = 'notificationsList';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(notificationRealtimeInboxSyncProvider);
    final listState = ref.watch(notificationsListProvider);
    final notifier = ref.read(notificationsListProvider.notifier);
    final scheme = Theme.of(context).colorScheme;
    final hPad = pdScreenPadding(context).horizontal;
    final unreadAsync = ref.watch(unreadNotificationsTotalProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('নোটিফিকেশন'),
        actions: [
          IconButton(
            tooltip: 'বিজ্ঞপ্তি সেটিংস',
            icon: const Icon(Icons.tune_outlined),
            onPressed: () => context.push(
              '${NotificationsListScreen.routePath}/${NotificationPreferencesScreen.routePath}',
            ),
          ),
          unreadAsync.when(
            data: (c) => c > 0
                ? Padding(
                    padding: const EdgeInsetsDirectional.only(end: 4),
                    child: Center(
                      child: Chip(
                        avatar: Icon(
                          Icons.mark_email_unread_outlined,
                          size: 18,
                          color: scheme.primary,
                        ),
                        label: Text('$c অপঠিত'),
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
          ),
          IconButton(
            tooltip: 'সব পড়া চিহ্নিত করুন',
            onPressed: listState.isLoading
                ? null
                : () async {
                    try {
                      await notifier.markAllRead();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('সব নোটিফিকেশন পঠিত চিহ্নিত হয়েছে'),
                          ),
                        );
                      }
                    } on NotificationApiException catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(e.message)));
                      }
                    }
                  },
            icon: const Icon(Icons.done_all_outlined),
          ),
        ],
      ),
      body: listState.when(
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
                  e is NotificationApiException ? e.message : 'লোড করা যায়নি',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => notifier.refresh(),
                  child: const Text('আবার চেষ্টা করুন'),
                ),
              ],
            ),
          ),
        ),
        data: (page) {
          final catFilter = ref.watch(notificationCenterCategoryFilterProvider);
          final filtered = catFilter == null
              ? page.items
              : page.items
                  .where((e) => e.notificationCategory == catFilter)
                  .toList();
          final displayPage = (
            items: filtered,
            total: page.total,
          );

          return RefreshIndicator(
            onRefresh: () async {
              await notifier.refresh();
              await ref.read(notificationsListProvider.future);
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 8),
                  sliver: SliverToBoxAdapter(
                    child: NotificationCategoryFilterBar(
                      selected: catFilter,
                      onChanged: ref
                          .read(notificationCenterCategoryFilterProvider.notifier)
                          .select,
                    ),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 8),
                  sliver: SliverToBoxAdapter(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        FilterChip(
                          label: const Text('শুধু অপঠিত'),
                          selected: notifier.unreadOnly,
                          onSelected: (v) => notifier.setUnreadOnly(v),
                        ),
                        Text(
                          'মোট ${page.total}${catFilter != null ? ' · ফিল্টার ${filtered.length}' : ''}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
                if (displayPage.items.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _NotificationsEmptyState(scheme: scheme),
                  )
                else
                  ..._buildGroupedNotificationSlivers(
                    context: context,
                    scheme: scheme,
                    hPad: hPad,
                    items: displayPage.items,
                    notifier: notifier,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _NotificationsEmptyState extends StatelessWidget {
  const _NotificationsEmptyState({required this.scheme});

  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PraniBrandHero(
              assetPath: PraniAssets.serviceTracking,
              height: 132,
              fit: BoxFit.cover,
              semanticLabel: 'সেবা অনুরোধ ট্র্যাকিং',
            ),
            const SizedBox(height: 20),
            Icon(
              Icons.notifications_off_outlined,
              size: 44,
              color: scheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'কোনো নোটিফিকেশন নেই',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 8),
            Text(
              'নতুন আপডেট এবং অনুরোধের খবর এখানে দেখা যাবে।',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

({List<AppNotification> recent, List<AppNotification> older})
_partitionRecentOlder(List<AppNotification> items) {
  final sorted = List<AppNotification>.from(items)
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  final cutoff = DateTime.now().subtract(const Duration(days: 7));
  final recent = <AppNotification>[];
  final older = <AppNotification>[];
  for (final n in sorted) {
    if (n.createdAt.toLocal().isAfter(cutoff)) {
      recent.add(n);
    } else {
      older.add(n);
    }
  }
  return (recent: recent, older: older);
}

List<Widget> _buildGroupedNotificationSlivers({
  required BuildContext context,
  required ColorScheme scheme,
  required double hPad,
  required List<AppNotification> items,
  required NotificationsListNotifier notifier,
}) {
  final parts = _partitionRecentOlder(items);
  final slivers = <Widget>[];

  void addSection(String title, List<AppNotification> sectionItems) {
    if (sectionItems.isEmpty) return;
    slivers.add(
      SliverPadding(
        padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 0),
        sliver: SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: scheme.primary,
              ),
            ),
          ),
        ),
      ),
    );
    slivers.add(
      SliverPadding(
        padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 8),
        sliver: SliverList.separated(
          itemCount: sectionItems.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final n = sectionItems[index];
            return NotificationInboxTile(
              notification: n,
              dateLabel: formatNotificationTimestamp(context, n.createdAt),
              onOpen: () => showNotificationDetailSheet(
                context: context,
                n: n,
                notifier: notifier,
              ),
              onMarkRead: n.isUnread
                  ? () async {
                      try {
                        await notifier.markRead(n.id);
                      } on NotificationApiException catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text(e.message)));
                        }
                      }
                    }
                  : null,
            );
          },
        ),
      ),
    );
  }

  addSection('সাম্প্রতিক', parts.recent);
  addSection('পুরোনো', parts.older);

  if (slivers.isEmpty) {
    return [
      SliverFillRemaining(
        hasScrollBody: false,
        child: _NotificationsEmptyState(scheme: scheme),
      ),
    ];
  }

  slivers.add(const SliverToBoxAdapter(child: SizedBox(height: 24)));
  return slivers;
}

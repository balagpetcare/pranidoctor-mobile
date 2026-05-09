import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:pranidoctor_mobile/src/app/screen_padding.dart';
import 'package:pranidoctor_mobile/src/features/notifications/application/notifications_providers.dart';
import 'package:pranidoctor_mobile/src/features/notifications/data/notification_model.dart';
import 'package:pranidoctor_mobile/src/features/notifications/data/notification_repository.dart';
import 'package:pranidoctor_mobile/src/features/notifications/presentation/widgets/notification_type_labels.dart';

final _notificationDateFmt = DateFormat('yyyy-MM-dd HH:mm');

/// Customer notification inbox — `GET /api/mobile/notifications` (Bearer via Dio).
class NotificationsListScreen extends ConsumerWidget {
  const NotificationsListScreen({super.key});

  static const routePath = '/notifications';
  static const routeName = 'notificationsList';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listState = ref.watch(notificationsListProvider);
    final notifier = ref.read(notificationsListProvider.notifier);
    final scheme = Theme.of(context).colorScheme;
    final hPad = pdScreenPadding(context).horizontal;
    final unreadAsync = ref.watch(unreadNotificationsTotalProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('নোটিফিকেশন'),
        actions: [
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
                          'মোট ${page.total}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
                if (page.items.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _NotificationsEmptyState(scheme: scheme),
                  )
                else
                  ..._buildGroupedNotificationSlivers(
                    context: context,
                    scheme: scheme,
                    hPad: hPad,
                    items: page.items,
                    notifier: notifier,
                    ref: ref,
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
            Icon(
              Icons.notifications_off_outlined,
              size: 56,
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
  required WidgetRef ref,
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
            return _NotificationCard(
              notification: n,
              dateLabel: _notificationDateFmt.format(n.createdAt.toLocal()),
              onOpen: () => _openNotificationDetail(context, ref, n),
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

Future<void> _openNotificationDetail(
  BuildContext context,
  WidgetRef ref,
  AppNotification n,
) async {
  final notifier = ref.read(notificationsListProvider.notifier);

  if (n.isUnread) {
    notifier.markRead(n.id).catchError((Object e) {
      if (!context.mounted) return;
      final msg = e is NotificationApiException
          ? e.message
          : 'পড়া চিহ্নিত করা যায়নি';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    });
  }

  if (!context.mounted) return;

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) {
      final bottomInset = MediaQuery.paddingOf(ctx).bottom;
      final scheme = Theme.of(ctx).colorScheme;
      final typeIcon = notificationTypeIcon(n.type);
      final typeLabel = notificationTypeLabelBn(n.type);

      return Padding(
        padding: EdgeInsets.fromLTRB(24, 8, 24, 16 + bottomInset),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: scheme.primaryContainer.withValues(
                      alpha: 0.6,
                    ),
                    child: Icon(typeIcon, color: scheme.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          typeLabel,
                          style: Theme.of(ctx).textTheme.labelLarge?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          n.title,
                          style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(n.body, style: Theme.of(ctx).textTheme.bodyLarge),
              if (n.relatedRequestId != null) ...[
                const SizedBox(height: 16),
                Text(
                  'সংক্লিষ্ট অনুরোধ: ${n.relatedRequestId}',
                  style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Text(
                _notificationDateFmt.format(n.createdAt.toLocal()),
                style: Theme.of(
                  ctx,
                ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('বন্ধ করুন'),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.notification,
    required this.dateLabel,
    required this.onOpen,
    this.onMarkRead,
  });

  final AppNotification notification;
  final String dateLabel;
  final VoidCallback onOpen;
  final VoidCallback? onMarkRead;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final n = notification;
    final typeIcon = notificationTypeIcon(n.type);
    final typeLabel = notificationTypeLabelBn(n.type);

    return Material(
      color: n.isUnread
          ? scheme.primaryContainer.withValues(alpha: 0.35)
          : scheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: scheme.surfaceContainerHighest,
                    child: Icon(typeIcon, color: scheme.primary, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                typeLabel,
                                style: Theme.of(context).textTheme.labelMedium
                                    ?.copyWith(color: scheme.onSurfaceVariant),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: n.isUnread
                                    ? scheme.primary.withValues(alpha: 0.15)
                                    : scheme.surfaceContainerHigh,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                n.isUnread ? 'অপঠিত' : 'পঠিত',
                                style: Theme.of(context).textTheme.labelSmall,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          n.title,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  if (onMarkRead != null)
                    TextButton(
                      onPressed: onMarkRead,
                      child: const Text('পড়া চিহ্নিত'),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                n.body,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                dateLabel,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

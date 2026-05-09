import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:pranidoctor_mobile/src/app/screen_padding.dart';
import 'package:pranidoctor_mobile/src/features/notifications/application/notifications_providers.dart';
import 'package:pranidoctor_mobile/src/features/notifications/data/notification_model.dart';
import 'package:pranidoctor_mobile/src/features/notifications/data/notification_repository.dart';

final _notificationDateFmt = DateFormat('yyyy-MM-dd HH:mm');

/// Customer notification inbox — GET `/api/notifications` (Bearer via Dio).
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('নোটিফিকেশন'),
        actions: [
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
                    child: Center(
                      child: Text(
                        'কোনো নোটিফিকেশন নেই',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 24),
                    sliver: SliverList.separated(
                      itemCount: page.items.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final n = page.items[index];
                        return _NotificationCard(
                          notification: n,
                          dateLabel: _notificationDateFmt.format(
                            n.createdAt.toLocal(),
                          ),
                          onOpen: () => _showNotificationDetail(context, n),
                          onMarkRead: n.isUnread
                              ? () async {
                                  try {
                                    await notifier.markRead(n.id);
                                  } on NotificationApiException catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(content: Text(e.message)),
                                      );
                                    }
                                  }
                                }
                              : null,
                        );
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

void _showNotificationDetail(BuildContext context, AppNotification n) {
  showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(n.title),
      content: SingleChildScrollView(child: Text(n.body)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('বন্ধ করুন'),
        ),
      ],
    ),
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

    return Material(
      color: n.isUnread
          ? scheme.primaryContainer.withValues(alpha: 0.35)
          : scheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
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
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      n.type.replaceAll('_', ' '),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
                n.title,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
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

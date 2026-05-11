import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:pranidoctor_mobile/src/features/notifications/application/notifications_providers.dart';
import 'package:pranidoctor_mobile/src/features/notifications/data/notification_model.dart';
import 'package:pranidoctor_mobile/src/features/notifications/data/notification_repository.dart';
import 'package:pranidoctor_mobile/src/features/notifications/domain/notification_category_mapper.dart';
import 'package:pranidoctor_mobile/src/features/notifications/presentation/widgets/notification_type_labels.dart';

String formatNotificationTimestamp(BuildContext context, DateTime utc) {
  final local = utc.toLocal();
  final locale = Localizations.localeOf(context).toString();
  return DateFormat('d MMM yyyy, HH:mm', locale).format(local);
}

Future<void> showNotificationDetailSheet({
  required BuildContext context,
  required AppNotification n,
  required NotificationsListNotifier notifier,
}) async {
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
      final cat = n.notificationCategory;

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
                    backgroundColor:
                        scheme.primaryContainer.withValues(alpha: 0.6),
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
                        const SizedBox(height: 6),
                        Text(
                          'বিভাগ: ${cat.labelBn}',
                          style: Theme.of(ctx).textTheme.labelSmall?.copyWith(
                                color: scheme.onSurfaceVariant,
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
                formatNotificationTimestamp(context, n.createdAt),
                style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
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

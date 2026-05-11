import 'package:flutter/material.dart';

import 'package:pranidoctor_mobile/src/features/notifications/data/notification_model.dart';
import 'package:pranidoctor_mobile/src/features/notifications/presentation/widgets/notification_type_labels.dart';

class NotificationInboxTile extends StatelessWidget {
  const NotificationInboxTile({
    super.key,
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
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

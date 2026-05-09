import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pranidoctor_mobile/src/features/notifications/application/notifications_providers.dart';

/// Home / shell entry: bell with unread count when available.
class NotificationBellIconButton extends ConsumerWidget {
  const NotificationBellIconButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  String _badgeLabel(int count) {
    if (count <= 0) return '';
    if (count > 99) return '99+';
    return '$count';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = ref.watch(unreadNotificationsTotalProvider);
    return IconButton(
      tooltip: 'নোটিফিকেশন',
      onPressed: onPressed,
      icon: unread.when(
        data: (c) => Badge(
          isLabelVisible: c > 0,
          label: Text(_badgeLabel(c)),
          child: const Icon(Icons.notifications_outlined),
        ),
        loading: () => const Icon(Icons.notifications_outlined),
        error: (_, _) => const Icon(Icons.notifications_outlined),
      ),
    );
  }
}

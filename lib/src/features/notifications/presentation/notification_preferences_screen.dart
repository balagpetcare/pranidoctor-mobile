import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pranidoctor_mobile/src/app/screen_padding.dart';
import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';
import 'package:pranidoctor_mobile/src/features/notifications/application/notification_hub_providers.dart';
import 'package:pranidoctor_mobile/src/features/notifications/domain/notification_category.dart';

class NotificationPreferencesScreen extends ConsumerWidget {
  const NotificationPreferencesScreen({super.key});

  static const routePath = 'preferences';
  static const routeName = 'notificationPreferences';

  static String locationUnderInbox() => '/notifications/$routePath';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(notificationPreferencesProvider);
    final hPad = pdScreenPadding(context).horizontal;

    return Scaffold(
      appBar: AppBar(
        title: const Text('বিজ্ঞপ্তি পছন্দ'),
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (prefs) => ListView(
          padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 32),
          children: [
            Text(
              'ক্যাটাগরি অনুযায়ী অ্যাপ-মধ্যস্থ বিজ্ঞপ্তি (প্রিভিউ / লোকাল)। '
              'পুশ নীতি সার্ভার ও অপারেটিং সিস্টেম দ্বারা নিয়ন্ত্রিত।',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    height: 1.45,
                  ),
            ),
            const SizedBox(height: PraniSpacing.lg),
            Card(
              child: Column(
                children: [
                  for (var i = 0; i < NotificationCategory.values.length; i++) ...[
                    if (i > 0) const Divider(height: 1),
                    SwitchListTile.adaptive(
                      title: Text(NotificationCategory.values[i].labelBn),
                      value: prefs.isEnabled(NotificationCategory.values[i]),
                      onChanged: (v) => ref
                          .read(notificationPreferencesProvider.notifier)
                          .setCategory(NotificationCategory.values[i], v),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: PraniSpacing.md),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('সম্পন্ন'),
            ),
          ],
        ),
      ),
    );
  }
}

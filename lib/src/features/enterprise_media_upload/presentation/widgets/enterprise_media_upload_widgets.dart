import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';
import 'package:pranidoctor_mobile/src/features/enterprise_media_upload/application/enterprise_media_upload_providers.dart';
import 'package:pranidoctor_mobile/src/features/enterprise_media_upload/domain/media_upload_lifecycle.dart';
import 'package:pranidoctor_mobile/src/features/enterprise_media_upload/domain/media_upload_task.dart';

/// Summary chip for drawer / app bars.
class EnterpriseMediaUploadQueueIndicator extends ConsumerWidget {
  const EnterpriseMediaUploadQueueIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(enterpriseMediaUploadTasksProvider);
    return async.when(
      data: (tasks) {
        final active = tasks
            .where(
              (t) =>
                  t.lifecycle != MediaUploadLifecycle.completed &&
                  t.lifecycle != MediaUploadLifecycle.failed,
            )
            .length;
        return Chip(
          avatar: const Icon(Icons.cloud_upload_outlined, size: 18),
          label: Text('আপলোড $active'),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}

class EnterpriseMediaUploadProgressTile extends StatelessWidget {
  const EnterpriseMediaUploadProgressTile({super.key, required this.task});

  final MediaUploadTask task;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircularProgressIndicator(value: task.progress.clamp(0.0, 1.0)),
      title: Text(task.displayName),
      subtitle: Text(
        '${task.lifecycle.name} · ${(task.progress * 100).round()}%',
        style: TextStyle(color: scheme.onSurfaceVariant),
      ),
    );
  }
}

class EnterpriseMediaUploadFailedCard extends StatelessWidget {
  const EnterpriseMediaUploadFailedCard({
    super.key,
    required this.task,
    required this.onRetry,
  });

  final MediaUploadTask task;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      color: scheme.errorContainer.withValues(alpha: 0.35),
      child: ListTile(
        title: Text(task.displayName),
        subtitle: Text(task.lastError ?? 'ব্যর্থ'),
        trailing: FilledButton.tonal(
          onPressed: onRetry,
          child: const Text('পুনঃচেষ্টা'),
        ),
      ),
    );
  }
}

class EnterpriseMediaUploadRetryTile extends StatelessWidget {
  const EnterpriseMediaUploadRetryTile({super.key, required this.task});

  final MediaUploadTask task;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.schedule_rounded),
      title: Text(task.displayName),
      subtitle: Text('পুনঃচেষ্টা · ${task.lastError ?? ''}'),
    );
  }
}

class EnterpriseMediaUploadCard extends StatelessWidget {
  const EnterpriseMediaUploadCard({
    super.key,
    required this.task,
    this.onCancel,
    this.onPause,
    this.onResume,
  });

  final MediaUploadTask task;
  final VoidCallback? onCancel;
  final VoidCallback? onPause;
  final VoidCallback? onResume;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(PraniSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              task.displayName,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: PraniSpacing.xs),
            Text(
              '${task.kind.name} · ${task.lifecycle.name}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
            ),
            if (task.lifecycle != MediaUploadLifecycle.completed &&
                task.lifecycle != MediaUploadLifecycle.failed) ...[
              const SizedBox(height: PraniSpacing.sm),
              LinearProgressIndicator(value: task.progress.clamp(0.0, 1.0)),
            ],
            const SizedBox(height: PraniSpacing.sm),
            Wrap(
              spacing: PraniSpacing.xs,
              children: [
                if (onCancel != null)
                  TextButton(
                    onPressed: onCancel,
                    child: const Text('বাতিল'),
                  ),
                if (onPause != null && !task.paused)
                  TextButton(onPressed: onPause, child: const Text('বিরতি')),
                if (onResume != null && task.paused)
                  TextButton(onPressed: onResume, child: const Text('চালু')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pranidoctor_mobile/src/app/screen_padding.dart';
import 'package:pranidoctor_mobile/src/features/technician_ai/application/technician_job_providers.dart';
import 'package:pranidoctor_mobile/src/features/technician_ai/presentation/technician_job_detail_screen.dart';
import 'package:pranidoctor_mobile/src/features/technician_ai/presentation/widgets/technician_ai_widgets.dart';

class TechnicianJobsScreen extends ConsumerWidget {
  const TechnicianJobsScreen({super.key});

  static const routePath = '/technician/jobs';
  static const routeName = 'technicianJobs';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(technicianJobsListProvider);
    final scheme = Theme.of(context).colorScheme;
    final hPad = pdScreenPadding(context).horizontal;

    return Scaffold(
      appBar: AppBar(
        title: const Text('চলমান কাজ'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Center(child: TechnicianAiBadge(compact: true)),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(technicianJobsListProvider.notifier).refresh(),
        child: async.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => _ErrorBody(
            message: '$e',
            onRetry: () =>
                ref.read(technicianJobsListProvider.notifier).refresh(),
          ),
          data: (items) {
            if (items.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(hPad),
                children: [
                  const SizedBox(height: 48),
                  Icon(
                    Icons.work_off_outlined,
                    size: 56,
                    color: scheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'কোনো চলমান কাজ নেই',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'নতুন অনুরোধ গ্রহণ করলে এখানে দেখাবে।',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              );
            }
            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 32),
              itemCount: items.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final j = items[i];
                return Card(
                  child: ListTile(
                    title: Text(j.animal?.name ?? 'কাজ'),
                    subtitle: Text(
                      '${j.phase.labelBn}${j.hasAiRecord ? ' · রেকর্ড আছে' : ''}',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () =>
                        context.push(TechnicianJobDetailScreen.pathFor(j.id)),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 80),
        Icon(Icons.error_outline, size: 56, color: scheme.error),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'লোড করা যায়নি',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ),
        const SizedBox(height: 24),
        Center(
          child: FilledButton(
            onPressed: onRetry,
            child: const Text('আবার চেষ্টা'),
          ),
        ),
      ],
    );
  }
}

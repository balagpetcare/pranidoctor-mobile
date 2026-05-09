import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pranidoctor_mobile/src/app/screen_padding.dart';
import 'package:pranidoctor_mobile/src/features/technician_ai/application/technician_job_providers.dart';
import 'package:pranidoctor_mobile/src/features/technician_ai/presentation/technician_job_detail_screen.dart';
import 'package:pranidoctor_mobile/src/features/technician_ai/presentation/widgets/technician_ai_widgets.dart';

class TechnicianRequestsScreen extends ConsumerWidget {
  const TechnicianRequestsScreen({super.key});

  static const routePath = '/technician/requests';
  static const routeName = 'technicianRequests';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(technicianRequestsListProvider);
    final scheme = Theme.of(context).colorScheme;
    final hPad = pdScreenPadding(context).horizontal;

    return Scaffold(
      appBar: AppBar(
        title: const Text('নতুন অনুরোধ'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Center(child: TechnicianAiBadge(compact: true)),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(technicianRequestsListProvider.notifier).refresh(),
        child: async.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => _ErrorBody(
            message: '$e',
            onRetry: () =>
                ref.read(technicianRequestsListProvider.notifier).refresh(),
          ),
          data: (items) {
            if (items.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(hPad),
                children: [
                  const SizedBox(height: 48),
                  Icon(Icons.inbox_outlined, size: 56, color: scheme.outline),
                  const SizedBox(height: 16),
                  Text(
                    'কোনো নতুন অনুরোধ নেই',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'নিচে টেনে রিফ্রেশ করুন।',
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
                final r = items[i];
                return Card(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () =>
                        context.push(TechnicianJobDetailScreen.pathFor(r.id)),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  r.animal?.name ?? 'অনুরোধ',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                              ),
                              Chip(
                                label: Text(
                                  r.phase.labelBn,
                                  style: Theme.of(context).textTheme.labelSmall,
                                ),
                                visualDensity: VisualDensity.compact,
                                padding: EdgeInsets.zero,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            r.customer?.displayLineBn ?? '',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: scheme.onSurfaceVariant),
                          ),
                          if (r.locationText?.trim().isNotEmpty == true) ...[
                            const SizedBox(height: 4),
                            Text(
                              r.locationText!,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ],
                      ),
                    ),
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

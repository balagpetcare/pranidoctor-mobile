import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pranidoctor_mobile/src/app/screen_padding.dart';
import 'package:pranidoctor_mobile/src/core/constants/pd_spacing.dart';
import 'package:pranidoctor_mobile/src/core/widgets/pd_async_states.dart';
import 'package:pranidoctor_mobile/src/features/doctor_workflow/application/doctor_workflow_providers.dart';
import 'package:pranidoctor_mobile/src/features/doctor_workflow/data/doctor_case_models.dart';
import 'package:pranidoctor_mobile/src/features/doctor_workflow/presentation/doctor_case_detail_screen.dart';
import 'package:pranidoctor_mobile/src/features/doctor_workflow/presentation/widgets/doctor_workflow_badges.dart';
import 'package:pranidoctor_mobile/src/features/doctor_workflow/presentation/widgets/doctor_workflow_card.dart';

/// Pending / new assignments for the signed-in doctor.
class DoctorRequestsScreen extends ConsumerWidget {
  const DoctorRequestsScreen({super.key});

  static const routePath = '/doctor/requests';
  static const routeName = 'doctorRequests';

  static String detailPathForIncoming(DoctorIncomingRequest r) {
    final id = (r.caseId != null && r.caseId!.trim().isNotEmpty)
        ? r.caseId!.trim()
        : r.requestId;
    return DoctorCaseDetailScreen.routePathFor(id);
  }

  static String _metaLine(DoctorIncomingRequest r) {
    final parts = <String>[];
    if (r.submittedAt != null) {
      final d = r.submittedAt!.toLocal();
      parts.add(
        'জমা: ${d.day}/${d.month}/${d.year}, ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}',
      );
    }
    if (r.problemSnippet != null && r.problemSnippet!.trim().isNotEmpty) {
      parts.add(r.problemSnippet!.trim());
    }
    return parts.join(' · ');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(doctorIncomingRequestsProvider);
    final hPad = pdScreenPadding(context).horizontal;

    return Scaffold(
      appBar: AppBar(
        title: const Text('নতুন অনুরোধ'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Center(child: DoctorModeChip()),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(doctorIncomingRequestsProvider.notifier).refresh(),
        child: async.when(
          loading: () => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(hPad, 48, hPad, 24),
            children: const [PdLoadingBody(message: 'নতুন অনুরোধ লোড হচ্ছে…')],
          ),
          error: (e, _) => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(hPad, 24, hPad, 24),
            children: [
              SizedBox(
                height: 420,
                child: PdErrorBody(
                  title: 'লোড করা যায়নি',
                  message: '$e',
                  retryLabel: 'আবার চেষ্টা করুন',
                  onRetry: () => ref
                      .read(doctorIncomingRequestsProvider.notifier)
                      .refresh(),
                ),
              ),
            ],
          ),
          data: (items) {
            if (items.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(hPad, 24, hPad, 24),
                children: [
                  SizedBox(
                    height: 440,
                    child: PdEmptyState(
                      icon: Icons.inbox_outlined,
                      title: 'কোনো নতুন অনুরোধ নেই',
                      subtitle: 'নতুন অনুরোধ এলে এখানে দেখা যাবে।',
                    ),
                  ),
                ],
              );
            }
            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 32),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: PdSpacing.sm),
              itemBuilder: (context, i) {
                final r = items[i];
                final title = r.serviceTypeLabel?.trim().isNotEmpty == true
                    ? r.serviceTypeLabel!.trim()
                    : 'সেবা অনুরোধ';
                return DoctorQueueCard(
                  title: title,
                  animalLine: r.animal.lineBn,
                  customerLine: r.customer.displayLineBn,
                  metaLine: _metaLine(r),
                  isEmergency: r.isEmergency,
                  priorityLabel: r.priorityLabel,
                  onTap: () => context.push(detailPathForIncoming(r)),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

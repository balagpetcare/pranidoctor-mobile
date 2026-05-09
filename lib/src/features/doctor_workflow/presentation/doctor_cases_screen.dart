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

/// Active / accepted cases for the doctor (client filters non-terminal when API returns broad list).
class DoctorCasesScreen extends ConsumerWidget {
  const DoctorCasesScreen({super.key});

  static const routePath = '/doctor/cases';
  static const routeName = 'doctorCases';

  static String _metaLine(DoctorCaseListItem r) {
    final parts = <String>['অবস্থা: ${r.status}'];
    if (r.submittedAt != null) {
      final d = r.submittedAt!.toLocal();
      parts.add('আপডেট: ${d.day}/${d.month}/${d.year}');
    }
    return parts.join(' · ');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(doctorCasesListProvider);
    final hPad = pdScreenPadding(context).horizontal;

    return Scaffold(
      appBar: AppBar(
        title: const Text('সক্রিয় কেস'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Center(child: DoctorModeChip()),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(doctorCasesListProvider.notifier).refresh(),
        child: async.when(
          loading: () => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(hPad, 48, hPad, 24),
            children: const [PdLoadingBody(message: 'কেসের তালিকা লোড হচ্ছে…')],
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
                  onRetry: () =>
                      ref.read(doctorCasesListProvider.notifier).refresh(),
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
                      icon: Icons.assignment_turned_in_outlined,
                      title: 'কোনো সক্রিয় কেস নেই',
                      subtitle: 'গ্রহণ করা কেস এখানে দেখা যাবে।',
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
                    : 'কেস';
                return DoctorQueueCard(
                  title: title,
                  animalLine: r.animal.lineBn,
                  customerLine: r.customer.displayLineBn,
                  metaLine: _metaLine(r),
                  isEmergency: r.isEmergency,
                  priorityLabel: r.priorityLabel,
                  onTap: () => context.push(
                    DoctorCaseDetailScreen.routePathFor(r.caseId),
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

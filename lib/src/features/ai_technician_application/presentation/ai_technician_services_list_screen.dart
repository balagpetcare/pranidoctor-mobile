import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pranidoctor_mobile/src/design_system/prani_page_insets.dart';
import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_buttons.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_loading_state.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_premium_card.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_scaffold.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/application/ai_technician_providers.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/data/ai_technician_models.dart';

class AiTechnicianServicesListScreen extends ConsumerWidget {
  const AiTechnicianServicesListScreen({super.key});

  static const routePath = '/profile/ai-technician/services';
  static const routeName = 'aiTechnicianServices';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(aiTechnicianServicesListProvider);
    final hPad = PraniPageInsets.horizontalPadding(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return PraniScaffold(
      title: 'কৃত্রিম প্রজনন সেবা',
      resizeToAvoidBottomInset: true,
      padding: EdgeInsets.fromLTRB(
        hPad,
        PraniSpacing.md,
        hPad,
        PraniSpacing.lg,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(aiTechnicianServicesListProvider);
          ref.invalidate(aiTechnicianDashboardProvider);
          await ref.read(aiTechnicianServicesListProvider.future);
        },
        child: async.when(
          loading: () => const Center(
            child: PraniLoadingState(message: 'লোড হচ্ছে…', compact: false),
          ),
          error: (e, _) => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              const SizedBox(height: 48),
              Center(child: Text('লোড করা যায়নি।\n$e')),
            ],
          ),
          data: (list) {
            if (list.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  Text('এখনও কোনো সার্ভিস নেই।', style: textTheme.bodyLarge),
                  const SizedBox(height: PraniSpacing.lg),
                  PraniPrimaryButton(
                    label: 'নতুন সার্ভিস তৈরি করুন',
                    onPressed: () => context.push(
                      '${AiTechnicianServicesListScreen.routePath}/new',
                    ),
                  ),
                ],
              );
            }
            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: list.length + 1,
              separatorBuilder: (_, index) =>
                  const SizedBox(height: PraniSpacing.sm),
              itemBuilder: (context, i) {
                if (i == 0) {
                  return PraniPrimaryButton(
                    label: 'নতুন সার্ভিস তৈরি করুন',
                    onPressed: () => context.push(
                      '${AiTechnicianServicesListScreen.routePath}/new',
                    ),
                  );
                }
                final s = list[i - 1];
                return PraniPremiumCard(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(s.title),
                    subtitle: Text(
                      '${AiTechnicianAnimalTypes.labelBn(s.animalType)} · ৳${s.basePrice}\n'
                      '${AiTechnicianServiceStatusCopy.titleBn(s.status)}',
                    ),
                    isThreeLine: true,
                    trailing: IconButton(
                      icon: Icon(Icons.edit_outlined, color: scheme.primary),
                      onPressed: () => context.push(
                        '${AiTechnicianServicesListScreen.routePath}/${s.id}/edit',
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

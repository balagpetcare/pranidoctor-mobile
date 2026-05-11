import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pranidoctor_mobile/src/design_system/prani_page_insets.dart';
import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_buttons.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_loading_state.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_premium_card.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_scaffold.dart';
import 'package:pranidoctor_mobile/src/features/ai_farmer_services/application/ai_farmer_services_providers.dart';
import 'package:pranidoctor_mobile/src/features/ai_farmer_services/presentation/ai_service_request_form_screen.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/data/ai_technician_models.dart';
import 'package:pranidoctor_mobile/src/features/auth/application/customer_auth_prompt.dart';
import 'package:pranidoctor_mobile/src/features/session/application/session_notifier.dart';

class AiTechnicianPublicProfileScreen extends ConsumerWidget {
  const AiTechnicianPublicProfileScreen({
    super.key,
    required this.technicianId,
  });

  final String technicianId;

  static const routePath = '/ai-services/technicians';
  static const routeName = 'aiTechnicianPublicProfile';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(aiTechnicianPublicProvider(technicianId));
    final hPad = PraniPageInsets.horizontalPadding(context);
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return PraniScaffold(
      title: 'টেকনিশিয়ান',
      padding: EdgeInsets.fromLTRB(
        hPad,
        PraniSpacing.md,
        hPad,
        PraniSpacing.lg,
      ),
      body: async.when(
        loading: () => const Center(
          child: PraniLoadingState(message: 'লোড হচ্ছে…', compact: false),
        ),
        error: (e, _) => Center(child: Text('লোড করা যায়নি।\n$e')),
        data: (p) {
          return ListView(
            children: [
              PraniPremiumCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            p.displayName,
                            style: textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        if (p.verified)
                          Icon(Icons.verified, color: scheme.primary),
                      ],
                    ),
                    if (p.district != null || p.upazila != null)
                      Text(
                        '${p.district ?? ''} · ${p.upazila ?? ''}',
                        style: textTheme.bodyMedium,
                      ),
                    if (p.ratingCount > 0)
                      Text(
                        'রেটিং ${p.ratingAverage?.toStringAsFixed(1) ?? '—'} (${p.ratingCount}) · সম্পন্ন ${p.completedServicesCount}',
                        style: textTheme.bodySmall,
                      )
                    else
                      Text(
                        'সম্পন্ন সেবা: ${p.completedServicesCount}',
                        style: textTheme.bodySmall,
                      ),
                    if (p.bio != null && p.bio!.trim().isNotEmpty) ...[
                      const SizedBox(height: PraniSpacing.sm),
                      Text(p.bio!.trim(), style: textTheme.bodyMedium),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: PraniSpacing.md),
              Text('সেবাসমূহ', style: textTheme.titleMedium),
              const SizedBox(height: PraniSpacing.sm),
              ...p.services.map(
                (s) => Padding(
                  padding: const EdgeInsets.only(bottom: PraniSpacing.sm),
                  child: PraniPremiumCard(
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(s.title),
                      subtitle: Text(
                        '${AiTechnicianAnimalTypes.labelBn(s.animalType)} · ৳${s.basePrice}',
                      ),
                      trailing: TextButton(
                        onPressed: () async {
                          if (!ref
                              .read(sessionNotifierProvider)
                              .isAuthenticated) {
                            await showCustomerAuthRequiredSheet(context);
                            return;
                          }
                          final q = Uri(
                            queryParameters: <String, String>{
                              if (p.district != null &&
                                  p.district!.trim().isNotEmpty)
                                'district': p.district!.trim(),
                              if (p.upazila != null &&
                                  p.upazila!.trim().isNotEmpty)
                                'upazila': p.upazila!.trim(),
                              if (p.unionOrArea != null &&
                                  p.unionOrArea!.trim().isNotEmpty)
                                'unionOrArea': p.unionOrArea!.trim(),
                              'technicianProfileId': p.id,
                              'serviceId': s.id,
                              'animalType': s.animalType,
                            },
                          );
                          context.push(
                            '${AiServiceRequestFormScreen.routePath}$q',
                          );
                        },
                        child: const Text('অনুরোধ'),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: PraniSpacing.md),
              Text('সেবার এলাকা', style: textTheme.titleMedium),
              const SizedBox(height: PraniSpacing.sm),
              ...p.divisionCoverageAreas.map(
                (a) => ListTile(
                  dense: true,
                  leading: const Icon(Icons.place_outlined),
                  title: Text('${a.district} · ${a.upazila}'),
                  subtitle:
                      a.unionOrArea != null && a.unionOrArea!.trim().isNotEmpty
                      ? Text(a.unionOrArea!.trim())
                      : null,
                ),
              ),
              const SizedBox(height: PraniSpacing.lg),
              PraniPrimaryButton(
                label: 'সেবার অনুরোধ করুন',
                onPressed: () async {
                  if (!ref.read(sessionNotifierProvider).isAuthenticated) {
                    await showCustomerAuthRequiredSheet(context);
                    return;
                  }
                  final q = Uri(
                    queryParameters: <String, String>{
                      if (p.district != null && p.district!.trim().isNotEmpty)
                        'district': p.district!.trim(),
                      if (p.upazila != null && p.upazila!.trim().isNotEmpty)
                        'upazila': p.upazila!.trim(),
                      if (p.unionOrArea != null &&
                          p.unionOrArea!.trim().isNotEmpty)
                        'unionOrArea': p.unionOrArea!.trim(),
                      'technicianProfileId': p.id,
                    },
                  );
                  context.push('${AiServiceRequestFormScreen.routePath}$q');
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

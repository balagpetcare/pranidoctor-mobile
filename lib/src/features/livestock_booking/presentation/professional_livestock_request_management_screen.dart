import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_buttons.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_error_state.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_loading_state.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/presentation/ai_technician_requests_list_screen.dart';
import 'package:pranidoctor_mobile/src/features/ai_farmer_services/presentation/ai_technician_finder_screen.dart';
import 'package:pranidoctor_mobile/src/features/home/application/home_shell_tab_provider.dart';
import 'package:pranidoctor_mobile/src/features/home/home_shell_screen.dart';
import 'package:pranidoctor_mobile/src/features/providers/presentation/doctor_list_screen.dart';
import 'package:pranidoctor_mobile/src/features/service_requests/application/service_requests_providers.dart';
import 'package:pranidoctor_mobile/src/features/session/application/session_notifier.dart';
import 'package:pranidoctor_mobile/src/features/workspace/application/workspace_surface_provider.dart';

/// Professional-side entry: AI job queue + nearby matching shortcuts + platform booking notes.
class ProfessionalLivestockRequestManagementScreen extends ConsumerWidget {
  const ProfessionalLivestockRequestManagementScreen({super.key});

  static const routePath = '/workspace/livestock-requests';
  static const routeName = 'workspaceLivestockRequests';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(sessionNotifierProvider).role;
    final listAsync = ref.watch(serviceRequestsListProvider);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('সেবা অনুরোধ ও বুকিং')),
      body: ListView(
        padding: const EdgeInsets.all(PraniSpacing.lg),
        children: [
          Text(
            'এন্টারপ্রাইজ ওয়ার্কফ্লো',
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: PraniSpacing.sm),
          Text(
            'এআই টেকনিশিয়ানের কিউ আলাদা API; সাধারণ লাইভস্টক বুকিং গ্রাহকের '
            '`/api/mobile/service-requests` এ চলে। রিয়েলটাইম আপডেটের জন্য '
            'সকেট বাঁধতে [LivestockBookingRealtimePort] প্রয়োগ করুন।',
            style: textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.45,
            ),
          ),
          const SizedBox(height: PraniSpacing.xl),
          if (role == AppRole.aiTechnician) ...[
            PraniPrimaryButton(
              label: 'এআই সেবা অনুরোধের তালিকা',
              icon: Icons.list_alt_rounded,
              fullWidth: true,
              minimumHeight: 48,
              onPressed: () =>
                  context.push(AiTechnicianRequestsListScreen.routePath),
            ),
            const SizedBox(height: PraniSpacing.md),
          ],
          PraniSecondaryButton(
            label: 'কাছাকাছি ডাক্তার (ম্যাচিং স্টাব)',
            icon: Icons.medical_services_outlined,
            fullWidth: true,
            minimumHeight: 48,
            onPressed: () => context.push(DoctorListScreen.routePath),
          ),
          const SizedBox(height: PraniSpacing.md),
          PraniSecondaryButton(
            label: 'কাছাকাছি এআই টেকনিশিয়ান (পাবলিক তালিকা)',
            icon: Icons.agriculture_outlined,
            fullWidth: true,
            minimumHeight: 48,
            onPressed: () => context.push(AiTechnicianFinderScreen.routePath),
          ),
          const SizedBox(height: PraniSpacing.xl),
          Text(
            'গ্রাহক বুকিং API (প্রিভিউ)',
            style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: PraniSpacing.sm),
          listAsync.when(
            loading: () => const PraniLoadingState(
              message: 'অনুরোধ লোড হচ্ছে…',
              compact: true,
            ),
            error: (e, _) => PraniErrorState(
              title: 'লোড হয়নি',
              message:
                  'পেশাদার সেশনে গ্রাহক বুকিং এন্ডপয়েন্ট প্রায়শই নিষ্ক্রিয় থাকে। '
                  'গ্রাহক হোমের «সেবা» ট্যাবে পরীক্ষা করুন।',
              retryLabel: 'আবার চেষ্টা',
              onRetry: () =>
                  ref.read(serviceRequestsListProvider.notifier).refresh(),
              detail: '$e',
              compact: true,
            ),
            data: (items) {
              if (items.isEmpty) {
                return Text(
                  'কোনো আইটেম নেই (অথবা এই রোলে তালিকা খালি)।',
                  style: textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                );
              }
              return Text(
                'সার্ভার থেকে ${items.length} টি অনুরোধ পাওয়া গেছে '
                '(গ্রাহক টোকেনে সম্পূর্ণ তালিকা দেখুন)।',
                style: textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                  height: 1.4,
                ),
              );
            },
          ),
          const SizedBox(height: PraniSpacing.lg),
          PraniSecondaryButton(
            label: 'গ্রাহক হোম → সেবা ট্যাব',
            icon: Icons.home_outlined,
            fullWidth: true,
            minimumHeight: 48,
            onPressed: () async {
              await ref
                  .read(workspaceSurfaceProvider.notifier)
                  .setSurface(WorkspaceSurface.general);
              ref.read(homeShellTabIndexProvider.notifier).select(2);
              if (context.mounted) {
                context.go(HomeShellScreen.routePath);
              }
            },
          ),
        ],
      ),
    );
  }
}

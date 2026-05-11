import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pranidoctor_mobile/src/app/screen_padding.dart';
import 'package:pranidoctor_mobile/src/design_system/prani_page_insets.dart';
import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_buttons.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_empty_state.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_error_state.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_form_card.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_form_tokens.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_loading_state.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_scaffold.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_status_card.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/application/ai_technician_providers.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/data/ai_technician_models.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/presentation/ai_technician_application_form_screen.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/presentation/ai_technician_dashboard_screen.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/presentation/ai_technician_intro_screen.dart';

/// Read-only pipeline view + correction / admin notes.
class AiTechnicianApplicationStatusScreen extends ConsumerWidget {
  const AiTechnicianApplicationStatusScreen({super.key});

  static const routePath = '/profile/ai-technician/status';
  static const routeName = 'aiTechnicianStatus';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(aiTechnicianMeProvider);
    final hPad = PraniPageInsets.horizontalPadding(context);
    final maxW = pdReadableMaxWidth(context);

    return PraniScaffold(
      title: 'আবেদনের অবস্থা',
      resizeToAvoidBottomInset: true,
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
        error: (e, _) => Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxW),
            child: PraniErrorState(
              title: 'লোড করা যায়নি',
              message: 'অনুগ্রহ করে নেটওয়ার্ক যাচাই করে আবার চেষ্টা করুন।',
              retryLabel: 'আবার চেষ্টা',
              onRetry: () => ref.invalidate(aiTechnicianMeProvider),
              boxed: true,
            ),
          ),
        ),
        data: (me) {
          final p = me.profile;
          if (p == null) {
            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxW),
                child: PraniEmptyState(
                  title: 'আবেদন এখনো শুরু হয়নি',
                  message: me.serverMessage?.trim().isNotEmpty == true
                      ? me.serverMessage!.trim()
                      : 'এআই টেকনিশিয়ান হিসেবে আবেদন করতে intro থেকে ফর্ম খুলুন।',
                  icon: Icons.engineering_outlined,
                  actionLabel: 'কীভাবে আবেদন করবেন',
                  onAction: () =>
                      context.push(AiTechnicianIntroScreen.routePath),
                  boxed: true,
                ),
              ),
            );
          }
          return _StatusBody(profile: p, maxWidth: maxW);
        },
      ),
    );
  }
}

class _StatusBody extends ConsumerWidget {
  const _StatusBody({required this.profile, required this.maxWidth});

  final AiTechnicianProfile profile;
  final double maxWidth;

  int _timelineIndex(String status) {
    switch (status) {
      case 'SUBMITTED':
        return 0;
      case 'UNDER_REVIEW':
      case 'PENDING_VERIFICATION':
        return 1;
      case 'APPROVED':
      case 'PUBLISHED':
      case 'REJECTED':
      case 'NEEDS_CORRECTION':
      case 'NEEDS_MORE_INFO':
      case 'SUSPENDED':
        return 2;
      case 'DRAFT':
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final st = profile.status;
    final timelineIndex = _timelineIndex(st);

    final suffix = <Widget>[];
    if (profile.correctionNote != null &&
        profile.correctionNote!.trim().isNotEmpty) {
      suffix.add(const SizedBox(height: PraniSpacing.lg));
      suffix.add(
        Text(
          'সংশোধন নোট',
          style: PraniTextStyles.label(
            scheme,
            textTheme,
          ).copyWith(color: scheme.primary, fontWeight: FontWeight.w700),
        ),
      );
      suffix.add(const SizedBox(height: PraniSpacing.xs));
      suffix.add(
        Text(
          profile.correctionNote!.trim(),
          style: PraniTextStyles.bodySmall(
            scheme,
            textTheme,
          ).copyWith(height: 1.45),
        ),
      );
    }
    if (profile.adminNote != null && profile.adminNote!.trim().isNotEmpty) {
      suffix.add(const SizedBox(height: PraniSpacing.lg));
      suffix.add(
        Text(
          'অ্যাডমিন নোট',
          style: PraniTextStyles.label(
            scheme,
            textTheme,
          ).copyWith(fontWeight: FontWeight.w700),
        ),
      );
      suffix.add(const SizedBox(height: PraniSpacing.xs));
      suffix.add(
        Text(
          profile.adminNote!.trim(),
          style: PraniTextStyles.bodySmall(
            scheme,
            textTheme,
          ).copyWith(height: 1.45),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 32),
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: PraniSpacing.xs),
              PraniStatusCard(
                headline: AiTechnicianStatusCopy.titleBn(st),
                badgeLabel: AiTechnicianStatusCopy.titleBn(st),
                message: AiTechnicianStatusCopy.messageBn(st),
                suffix: suffix,
              ),
              SizedBox(height: PraniFormTokens.sectionGap),
              PraniFormCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'আবেদনের অগ্রগতি',
                      style: PraniTextStyles.subheading(
                        scheme,
                        textTheme,
                      ).copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: PraniSpacing.sm),
                    _TimelineRow(
                      title: '১. আবেদন জমা হয়েছে',
                      done: timelineIndex >= 0,
                      active: timelineIndex == 0,
                    ),
                    _TimelineRow(
                      title: '২. যাচাই চলছে',
                      done: timelineIndex >= 1,
                      active: timelineIndex == 1,
                    ),
                    _TimelineRow(
                      title: '৩. অনুমোদন / ফলাফল',
                      done: timelineIndex >= 2,
                      active: timelineIndex == 2,
                    ),
                    const SizedBox(height: PraniSpacing.sm),
                    Text(
                      'আপনার আবেদন জমা হয়েছে। অ্যাডমিন যাচাই করার পর আপনাকে জানানো হবে।',
                      style: PraniTextStyles.bodySmall(
                        scheme,
                        textTheme,
                      ).copyWith(height: 1.45),
                    ),
                  ],
                ),
              ),
              SizedBox(height: PraniFormTokens.sectionGap),
              PraniFormCard(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    Icons.badge_outlined,
                    color: scheme.primary,
                    size: 28,
                  ),
                  title: Text(
                    'যাচাই অবস্থা',
                    style: PraniTextStyles.subheading(
                      scheme,
                      textTheme,
                    ).copyWith(fontWeight: FontWeight.w600, fontSize: 17),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: PraniSpacing.xs),
                    child: Text(
                      AiTechnicianStatusCopy.providerStatusBn(
                        profile.providerStatus,
                      ),
                      style: PraniTextStyles.body(scheme, textTheme),
                    ),
                  ),
                ),
              ),
              if (st == 'APPROVED' || st == 'PUBLISHED') ...[
                SizedBox(height: PraniFormTokens.sectionGap),
                PraniPrimaryButton(
                  label: 'ড্যাশবোর্ড ও সার্ভিস',
                  onPressed: () =>
                      context.push(AiTechnicianDashboardScreen.routePath),
                ),
              ],
              if (profile.isEditable) ...[
                SizedBox(height: PraniFormTokens.fieldGap),
                PraniPrimaryButton(
                  label: st == 'NEEDS_CORRECTION' || st == 'NEEDS_MORE_INFO'
                      ? 'তথ্য সংশোধন করুন'
                      : 'ফর্ম সম্পাদনা করুন',
                  onPressed: () =>
                      context.push(AiTechnicianApplicationFormScreen.routePath),
                ),
              ],
              const SizedBox(height: PraniSpacing.md),
              PraniSecondaryButton(
                label: 'রিফ্রেশ',
                fullWidth: true,
                minimumHeight: 48,
                onPressed: () => ref.invalidate(aiTechnicianMeProvider),
              ),
              const SizedBox(height: PraniSpacing.sm),
              PraniSecondaryButton(
                label: 'ফিরে যান',
                fullWidth: true,
                minimumHeight: 48,
                style: PraniSecondaryStyle.text,
                onPressed: () => context.pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.title,
    required this.done,
    required this.active,
  });

  final String title;
  final bool done;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final color = done ? scheme.primary : scheme.outline;
    return Padding(
      padding: const EdgeInsets.only(bottom: PraniSpacing.sm),
      child: Row(
        children: [
          Icon(
            done ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
            size: 20,
            color: color,
          ),
          const SizedBox(width: PraniSpacing.sm),
          Expanded(
            child: Text(
              title,
              style: PraniTextStyles.body(scheme, textTheme).copyWith(
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                color: active ? scheme.onSurface : scheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

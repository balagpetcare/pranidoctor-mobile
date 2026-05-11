import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_scaffold.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_section_header.dart';
import 'package:pranidoctor_mobile/src/features/professional_profile/application/professional_profile_draft_notifier.dart';
import 'package:pranidoctor_mobile/src/features/professional_profile/data/professional_profile_draft.dart';
import 'package:pranidoctor_mobile/src/features/professional_profile/domain/professional_persona.dart';
import 'package:pranidoctor_mobile/src/features/professional_profile/domain/professional_profile_completion.dart';
import 'package:pranidoctor_mobile/src/features/professional_profile/domain/professional_profile_section.dart';
import 'package:pranidoctor_mobile/src/features/professional_profile/presentation/widgets/professional_completion_ring.dart';
import 'package:pranidoctor_mobile/src/features/professional_profile/presentation/widgets/professional_profile_section_tile.dart';

/// Enterprise professional profile hub (AI technician + veterinary doctor).
class ProfessionalProfileHubScreen extends ConsumerWidget {
  const ProfessionalProfileHubScreen({super.key, required this.persona});

  final ProfessionalPersona persona;

  static const routePath = '/professional/profile/:persona';

  static String routeLocation(ProfessionalPersona p) =>
      '/professional/profile/${p.routeSegment}';

  static String sectionLocation(
    ProfessionalPersona p,
    ProfessionalProfileSection s,
  ) =>
      '/professional/profile/${p.routeSegment}/section/${s.name}';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = watchProfessionalDraft(ref, persona);

    return PraniScaffold(
      title: 'পেশাদার প্রোফাইল',
      subtitle: persona.labelBn,
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator.adaptive()),
        error: (e, _) => Center(child: Text('লোড ব্যর্থ: $e')),
        data: (session) {
          final pct = professionalProfileCompletionPercent(
            persona: persona,
            d: session.draft,
          );
          final saved = session.lastSavedAt;

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              PraniSpacing.pageHorizontal,
              PraniSpacing.lg,
              PraniSpacing.pageHorizontal,
              PraniSpacing.xxl,
            ),
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ProfessionalCompletionRing(percent: pct),
                  const SizedBox(width: PraniSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'প্রোফাইল সম্পূর্ণতা',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          saved == null
                              ? 'স্বয়ংক্রিয় সংরক্ষণ প্রস্তুত — সম্পাদনা শুরু করলে ড্রাফট সংরক্ষিত হবে।'
                              : 'সর্বশেষ সংরক্ষণ: ${saved.toLocal()}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                                height: 1.4,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: PraniSpacing.xl),
              const PraniSectionHeader(
                title: 'বিভাগসমূহ',
                subtitle: 'সম্পাদনা ও মিডিয়া',
                leadingIcon: Icons.tune_rounded,
              ),
              const SizedBox(height: PraniSpacing.md),
              for (final s in ProfessionalProfileSection.values) ...[
                ProfessionalProfileSectionTile(
                  icon: s.icon,
                  title: s.titleBn,
                  subtitle: s.subtitleBn,
                  completionHint: _hintFor(s, session.draft),
                  onTap: () => context.push(sectionLocation(persona, s)),
                ),
                const SizedBox(height: PraniSpacing.sm),
              ],
            ],
          );
        },
      ),
    );
  }

  String? _hintFor(ProfessionalProfileSection s, ProfessionalProfileDraft draft) {
    // Lightweight nudges — full scoring lives in [professionalProfileCompletionPercent].
    return switch (s) {
      ProfessionalProfileSection.basic =>
        draft.displayName.trim().isEmpty ? 'নাম পূরণ করুন' : null,
      ProfessionalProfileSection.documents =>
        (draft.profilePhotoUploadId == null && draft.profilePhotoLocalPath == null)
            ? 'ছবি যোগ করুন'
            : null,
      _ => null,
    };
  }
}

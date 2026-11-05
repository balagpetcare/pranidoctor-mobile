import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/data/semen_template_models.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/presentation/template_learning/preparation_guide_card.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/presentation/template_learning/template_learning_analytics.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/presentation/template_learning/template_learning_section_shell.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/presentation/template_learning/template_media_gallery.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/presentation/template_learning/template_media_partition.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/presentation/template_learning/template_protocol_viewer.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/presentation/template_learning/template_video_player.dart';

/// Media learning & preparation hub (videos, images, protocols, diagrams, static guides).
class TemplateLearningCenter extends ConsumerWidget {
  const TemplateLearningCenter({
    super.key,
    required this.template,
    required this.templateId,
    required this.onVideoEngaged,
    required this.onMediaOpened,
    required this.onSopOpened,
  });

  final SemenTemplateCatalogRow template;
  final String templateId;
  final VoidCallback onVideoEngaged;
  final void Function(String mediaId, String kind) onMediaOpened;
  final VoidCallback onSopOpened;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = TemplateMediaPartition.fromRows(template.media);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'মিডিয়া ও প্রস্তুতি কেন্দ্র',
          style: PraniTextStyles.pageTitleProminent(
            scheme,
            textTheme,
          ).copyWith(fontSize: 20),
        ),
        const SizedBox(height: PraniSpacing.sm),
        Text(
          'নির্দেশনামূলক ভিডিও, ছবি, প্রোটোকল ও কর্মপ্রবাহ — সেবা শুরুর আগে পর্যালোচনা করুন।',
          style: PraniTextStyles.bodyMuted(scheme, textTheme),
        ),
        const SizedBox(height: PraniSpacing.xl),
        SizedBox(
          height: 168,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              PreparationGuideCard(
                title: 'সংরক্ষণ',
                body:
                    'সিমেন স্ট্রাককে শীতল ও শুকনো রাখুন; প্রস্তুতি নথি অনুযায়ী তাপমাত্রা নিশ্চিত করুন।',
                icon: Icons.ac_unit_outlined,
                onFutureOffline: () {
                  TemplateLearningAnalytics.offlineDownloadQueued(
                    templateId: templateId,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('অফলাইন প্যাক শীঘ্রই উপলব্ধ হবে'),
                    ),
                  );
                },
              ),
              const SizedBox(width: PraniSpacing.md),
              const PreparationGuideCard(
                title: 'হিট সনাক্তকরণ',
                body:
                    'সঠিক গরমকাল নির্ধারণে AI সেবার সাথে পশু পর্যবেক্ষণ করুন; সন্দেহ হলে ভেটেরিনারিয়ান ডাকুন।',
                icon: Icons.thermostat_auto_outlined,
              ),
              const SizedBox(width: PraniSpacing.md),
              const PreparationGuideCard(
                title: 'প্রজনন সময়',
                body:
                    'প্রজনন সময়সূচি টেমপ্লেট নির্দেশনা ও স্থানীয় প্রোটোকল অনুসরণ করুন; জরুরি অবস্থায় জানান।',
                icon: Icons.schedule_outlined,
              ),
            ],
          ),
        ),
        const SizedBox(height: PraniSpacing.xl),
        if (p.instructionalVideos.isNotEmpty)
          TemplateLearningSectionShell(
            icon: Icons.play_lesson_outlined,
            title: 'নির্দেশনামূলক ভিডিও',
            subtitle: 'প্রশিক্ষণ ও নিরাপদ প্রয়োগ',
            child: Column(
              children: p.instructionalVideos.map((m) {
                if (m.kind == 'VIDEO_URL' &&
                    (m.externalUrl?.trim().isNotEmpty ?? false)) {
                  return TemplateExternalVideoLauncher(
                    label: 'ভিডিও লিঙ্ক',
                    url: m.externalUrl!.trim(),
                  );
                }
                final id = m.uploadedFileId?.trim();
                if (id != null && id.isNotEmpty) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      Icons.slideshow_rounded,
                      color: scheme.primary,
                    ),
                    title: const Text('আপলোড করা নির্দেশনামূলক ভিডিও'),
                    subtitle: const Text('প্লেয়ারে খুলতে ট্যাপ করুন'),
                    onTap: () {
                      onMediaOpened(m.id, m.kind);
                      TemplateLearningAnalytics.mediaCompleted(
                        m.id,
                        m.kind,
                        templateId: templateId,
                      );
                      showTemplateVideoPlayerSheet(
                        context,
                        ref: ref,
                        uploadId: id,
                        onEngaged: onVideoEngaged,
                      );
                    },
                  );
                }
                return const SizedBox.shrink();
              }).toList(),
            ),
          ),
        if (p.preparationImages.isNotEmpty)
          TemplateLearningSectionShell(
            icon: Icons.photo_library_outlined,
            title: 'প্রস্তুতির ছবি ও ডায়াগ্রাম',
            subtitle: 'পূর্ণস্ক্রিনে বড় করে দেখুন',
            child: TemplateMediaGallery(
              title: 'গ্যালারি',
              items: p.preparationImages,
              templateId: templateId,
              onItemOpened: onMediaOpened,
            ),
          ),
        if (p.aiGuidanceVisuals.isNotEmpty)
          TemplateLearningSectionShell(
            icon: Icons.auto_awesome_outlined,
            title: 'AI গাইড ভিজ্যুয়াল',
            subtitle: 'পরামর্শমূলক চিত্র',
            child: TemplateMediaGallery(
              title: 'AI ভিজ্যুয়াল',
              items: p.aiGuidanceVisuals,
              templateId: templateId,
              onItemOpened: onMediaOpened,
            ),
          ),
        if (p.workflowDiagrams.isNotEmpty)
          TemplateLearningSectionShell(
            icon: Icons.account_tree_outlined,
            title: 'প্রজনন কর্মপ্রবাহ ডায়াগ্রাম',
            subtitle: null,
            child: TemplateMediaGallery(
              title: 'ডায়াগ্রাম',
              items: p.workflowDiagrams,
              templateId: templateId,
              onItemOpened: onMediaOpened,
            ),
          ),
        if (p.sopDocuments.isNotEmpty || p.protocolPdfs.isNotEmpty)
          TemplateLearningSectionShell(
            icon: Icons.policy_outlined,
            title: 'SOP ও ভেটেরিনারি প্রোটোকল',
            subtitle: 'PDF খুলতে ট্যাপ করুন',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TemplateProtocolViewer(
                  items: [...p.sopDocuments, ...p.protocolPdfs],
                  title: 'নথি',
                  templateId: templateId,
                  onSopOpened: onSopOpened,
                ),
              ],
            ),
          ),
        if (!p.hasAnyLearningMedia)
          TemplateLearningSectionShell(
            icon: Icons.collections_bookmark_outlined,
            title: 'মিডিয়া প্লেসহোল্ডার',
            subtitle:
                'এই টেমপ্লেটে এখনও শ্রেণীবদ্ধ শিক্ষামূলক মিডিয়া নেই। অ্যাডমিন নতুন ধরন যোগ করলে এখানে দেখা যাবে।',
            child: Text(
              'ভবিষ্যতে: বহুভাষিক মিডিয়া, AI ন্যারেটেড টিউটোরিয়াল, অফলাইন ডাউনলোড।',
              style: PraniTextStyles.bodySmall(scheme, textTheme),
            ),
          ),
      ],
    );
  }
}

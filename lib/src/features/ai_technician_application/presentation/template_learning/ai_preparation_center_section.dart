import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_buttons.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/data/semen_template_models.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/presentation/template_content/template_clinical_alert.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/presentation/template_content/template_html_sanitizer.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/presentation/template_learning/template_learning_analytics.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/presentation/template_learning/template_learning_section_shell.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/presentation/template_learning/template_media_gallery.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/presentation/template_learning/template_media_partition.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/presentation/template_learning/template_video_player.dart';

enum AiPreparationCenterMode { compact, expanded }

class AiPreparationCenterCopy {
  static const String sectionTitle = 'AI প্রস্তুতি কেন্দ্র';
  static const String sectionSubtitle =
      'প্রস্তুতি নিশ্চিত করুন — মিশন শুরুর আগে দ্রুত গাইড';
  static const String quickVideoTitle = 'কুইক ভিডিও গাইড';
  static const String quickVideoSubtitle = 'মিশনের আগে ৬০ সেকেন্ডে রিভিউ';
  static const String quickVideoEmpty = 'ভিডিও আপলোড করা নেই';
  static const String swipeCardsTitle = 'প্রস্তুতি কার্ড';
  static const String swipeCardsSubtitle = 'বাম-ডানে সোয়াইপ করে প্রস্তুতি নিন';
  static const String diagramTitle = 'ইনসেমিনেশন ডায়াগ্রাম';
  static const String diagramSubtitle = 'ভিজ্যুয়াল ধাপগুলো দেখুন';
  static const String heatGuideTitle = 'হিট সনাক্তকরণ গাইড';
  static const String heatGuideSubtitle = 'দ্রুত চেকলিস্ট';
  static const String storageChecklistTitle = 'স্টোরেজ চেকলিস্ট';
  static const String equipmentChecklistTitle = 'ইকুইপমেন্ট চেকলিস্ট';
  static const String animalChecklistTitle = 'প্রাণীর অবস্থা চেকলিস্ট';
  static const String aiNarrationTitle = 'AI ন্যারেটেড টিউটোরিয়াল';
  static const String aiNarrationSubtitle = 'ভবিষ্যৎ মাল্টিলিঙ্গুয়াল ভয়েস গাইড';
  static const String aiNarrationAction = 'চালু করুন';
  static const String warningTitle = 'ভেটেরিনারি সতর্কতা';
  static const String warningFallback = 'এই টেমপ্লেটে উচ্চ ঝুঁকির তথ্য নেই।';
  static const String protocolNotesTitle = 'প্রোটোকল নোট';
  static const String protocolNotesSubtitle = 'প্রয়োজনে খুলে দেখুন';
  static const String offlineTitle = 'অফলাইন প্রস্তুতি';
  static const String offlineSubtitle = 'অফলাইনে ব্যবহারের জন্য মিডিয়া সংরক্ষণ';
  static const String offlineAction = 'ডাউনলোড শিডিউল';
  static const String assistantTitle = 'AI অ্যাসিস্ট্যান্ট';
  static const String assistantSubtitle = 'ভবিষ্যতে রিয়েল-টাইম কোচিং';
  static const String emptyStateTitle = 'প্রস্তুতি কনটেন্ট নেই';
  static const String emptyStateSubtitle =
      'নতুন নির্দেশনা যোগ হলে এখানে দেখা যাবে।';
  static const String aiNarrationToast = 'শীঘ্রই উপলব্ধ হবে';
  static const String offlineScheduleToast = 'অফলাইন প্যাক শিডিউল হয়েছে';
  static const String storageTemperature = 'সঠিক তাপমাত্রা';
  static const String storageSecurity = 'স্টোরেজ নিরাপদ';
  static const String equipmentClean = 'ইকুইপমেন্ট পরিষ্কার';
  static const String animalStable = 'প্রাণী স্থিতিশীল';

  static List<_PreparationCardData> preparationCards({required bool compact}) {
    final all = [
      const _PreparationCardData(
        title: 'সেফটি',
        subtitle: 'ঝুঁকি থাকলে আগে রিপোর্ট করুন',
        icon: Icons.health_and_safety_outlined,
      ),
      const _PreparationCardData(
        title: 'ইনসেমিনেশন প্রস্তুতি',
        subtitle: 'টুল ও জীবাণুমুক্ততা নিশ্চিত করুন',
        icon: Icons.medical_services_outlined,
      ),
      const _PreparationCardData(
        title: 'প্রাণী পর্যবেক্ষণ',
        subtitle: 'হিট সাইন সঠিকভাবে শনাক্ত করুন',
        icon: Icons.monitor_heart_outlined,
      ),
    ];
    return compact ? all.take(2).toList() : all;
  }

  static List<_HeatGuideItem> heatGuideItems() {
    return const [
      _HeatGuideItem(
        title: 'আচরণ পরিবর্তন',
        subtitle: 'অস্থিরতা ও ডাকাডাকি দেখুন',
        icon: Icons.visibility_outlined,
      ),
      _HeatGuideItem(
        title: 'শারীরিক লক্ষণ',
        subtitle: 'বহিঃপ্রবাহ ও ফুলে যাওয়া',
        icon: Icons.bloodtype_outlined,
      ),
      _HeatGuideItem(
        title: 'সময়',
        subtitle: 'AI সময় নির্দেশনা অনুসরণ করুন',
        icon: Icons.schedule_outlined,
      ),
    ];
  }
}

class AiPreparationCenterSection extends ConsumerWidget {
  const AiPreparationCenterSection({
    super.key,
    required this.template,
    required this.templateId,
    required this.partition,
    required this.apiBaseUrl,
    this.imageHeaders,
    this.mode = AiPreparationCenterMode.expanded,
    this.isLoading = false,
    required this.storageReady,
    required this.equipmentReady,
    required this.animalReady,
    required this.offlineReady,
    required this.onStorageChanged,
    required this.onEquipmentChanged,
    required this.onAnimalChanged,
    required this.onOfflineChanged,
  });

  final SemenTemplateCatalogRow template;
  final String templateId;
  final TemplateMediaPartition partition;
  final String apiBaseUrl;
  final Map<String, String>? imageHeaders;
  final AiPreparationCenterMode mode;
  final bool isLoading;
  final bool storageReady;
  final bool equipmentReady;
  final bool animalReady;
  final bool offlineReady;
  final ValueChanged<bool?> onStorageChanged;
  final ValueChanged<bool?> onEquipmentChanged;
  final ValueChanged<bool?> onAnimalChanged;
  final ValueChanged<bool?> onOfflineChanged;

  bool get _compact => mode == AiPreparationCenterMode.compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isLoading) {
      return const _PreparationShimmer();
    }

    return _PreparationShell(
      title: AiPreparationCenterCopy.sectionTitle,
      subtitle: AiPreparationCenterCopy.sectionSubtitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PreparationQuickVideo(
            templateId: templateId,
            partition: partition,
            onOpenVideo: (uploadId, externalUrl) {
              if (uploadId != null) {
                showTemplateVideoPlayerSheet(
                  context,
                  ref: ref,
                  uploadId: uploadId,
                  onEngaged: () => TemplateLearningAnalytics.mediaCompleted(
                    uploadId,
                    'VIDEO_UPLOAD',
                    templateId: templateId,
                  ),
                );
                return;
              }
              if (externalUrl != null) {
                TemplateLearningAnalytics.mediaCompleted(
                  externalUrl,
                  'VIDEO_URL',
                  templateId: templateId,
                );
              }
            },
          ),
          const SizedBox(height: PraniSpacing.lg),
          _PreparationSwipeCards(compact: _compact),
          const SizedBox(height: PraniSpacing.lg),
          _PreparationHeatGuide(compact: _compact),
          const SizedBox(height: PraniSpacing.lg),
          if (!_compact || partition.workflowDiagrams.isNotEmpty)
            _PreparationDiagramRail(
              templateId: templateId,
              items: partition.workflowDiagrams,
            ),
          if (!_compact) const SizedBox(height: PraniSpacing.lg),
          _PreparationChecklistGroup(
            title: AiPreparationCenterCopy.storageChecklistTitle,
            items: [
              _ChecklistEntry(
                label: AiPreparationCenterCopy.storageTemperature,
                value: storageReady,
                onChanged: onStorageChanged,
              ),
              _ChecklistEntry(
                label: AiPreparationCenterCopy.storageSecurity,
                value: offlineReady,
                onChanged: onOfflineChanged,
              ),
            ],
          ),
          const SizedBox(height: PraniSpacing.lg),
          _PreparationChecklistGroup(
            title: AiPreparationCenterCopy.equipmentChecklistTitle,
            items: [
              _ChecklistEntry(
                label: AiPreparationCenterCopy.equipmentClean,
                value: equipmentReady,
                onChanged: onEquipmentChanged,
              ),
            ],
          ),
          const SizedBox(height: PraniSpacing.lg),
          _PreparationChecklistGroup(
            title: AiPreparationCenterCopy.animalChecklistTitle,
            items: [
              _ChecklistEntry(
                label: AiPreparationCenterCopy.animalStable,
                value: animalReady,
                onChanged: onAnimalChanged,
              ),
            ],
          ),
          const SizedBox(height: PraniSpacing.lg),
          _AiNarrationTrigger(onPressed: () {
            TemplateLearningAnalytics.sectionViewed(
              'ai_narration_future',
              templateId: templateId,
            );
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(AiPreparationCenterCopy.aiNarrationToast),
              ),
            );
          }),
          const SizedBox(height: PraniSpacing.lg),
          _VeterinaryWarningBanner(
            baseUrl: apiBaseUrl,
            warningHtml: template.warningsContraindications,
          ),
          const SizedBox(height: PraniSpacing.lg),
          _ProtocolNotes(
            title: AiPreparationCenterCopy.protocolNotesTitle,
            subtitle: AiPreparationCenterCopy.protocolNotesSubtitle,
            content: template.detailedDescription,
            baseUrl: apiBaseUrl,
          ),
          if (!_compact) const SizedBox(height: PraniSpacing.lg),
          if (!_compact)
            _PreparationFooter(
              onOfflineSchedule: () {
                TemplateLearningAnalytics.offlineDownloadQueued(
                  templateId: templateId,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(AiPreparationCenterCopy.offlineScheduleToast),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _PreparationShell extends StatelessWidget {
  const _PreparationShell({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(PraniSpacing.xl),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(PraniRadius.lg),
        boxShadow: PraniShadows.elevatedCardShadow(
          Theme.of(context).brightness,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: PraniTextStyles.sectionTitleProminent(
              scheme,
              Theme.of(context).textTheme,
            ),
          ),
          const SizedBox(height: PraniSpacing.xs),
          Text(
            subtitle,
            style: PraniTextStyles.bodyMuted(
              scheme,
              Theme.of(context).textTheme,
            ),
          ),
          const SizedBox(height: PraniSpacing.lg),
          child,
        ],
      ),
    );
  }
}

class _PreparationQuickVideo extends StatelessWidget {
  const _PreparationQuickVideo({
    required this.templateId,
    required this.partition,
    required this.onOpenVideo,
  });

  final String templateId;
  final TemplateMediaPartition partition;
  final void Function(String? uploadId, String? externalUrl) onOpenVideo;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final video = partition.instructionalVideos.isNotEmpty
        ? partition.instructionalVideos.first
        : null;
    return TemplateLearningSectionShell(
      icon: Icons.play_circle_outline_rounded,
      title: AiPreparationCenterCopy.quickVideoTitle,
      subtitle: AiPreparationCenterCopy.quickVideoSubtitle,
      child: video == null
          ? _PreparationEmptyState(
              title: AiPreparationCenterCopy.quickVideoEmpty,
              subtitle: AiPreparationCenterCopy.emptyStateSubtitle,
            )
          : Container(
              padding: const EdgeInsets.all(PraniSpacing.lg),
              decoration: BoxDecoration(
                color: scheme.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(PraniRadius.md),
                border: Border.all(color: scheme.primary.withOpacity(0.2)),
              ),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.play_circle_fill, color: scheme.primary),
                title: Text(
                  AiPreparationCenterCopy.quickVideoTitle,
                  style: PraniTextStyles.subheading(
                    scheme,
                    Theme.of(context).textTheme,
                  ),
                ),
                subtitle: Text(
                  AiPreparationCenterCopy.quickVideoSubtitle,
                  style: PraniTextStyles.bodyMuted(
                    scheme,
                    Theme.of(context).textTheme,
                  ),
                ),
                onTap: () => onOpenVideo(
                  video.uploadedFileId,
                  video.externalUrl,
                ),
              ),
            ),
    );
  }
}

class _PreparationSwipeCards extends StatefulWidget {
  const _PreparationSwipeCards({required this.compact});

  final bool compact;

  @override
  State<_PreparationSwipeCards> createState() => _PreparationSwipeCardsState();
}

class _PreparationSwipeCardsState extends State<_PreparationSwipeCards> {
  final PageController _controller = PageController(viewportFraction: 0.9);
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cards = AiPreparationCenterCopy.preparationCards(
      compact: widget.compact,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: AiPreparationCenterCopy.swipeCardsTitle,
          subtitle: AiPreparationCenterCopy.swipeCardsSubtitle,
        ),
        const SizedBox(height: PraniSpacing.sm),
        SizedBox(
          height: widget.compact ? 150 : 170,
          child: PageView.builder(
            controller: _controller,
            itemCount: cards.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (context, i) => _PreparationSwipeCard(data: cards[i]),
          ),
        ),
        const SizedBox(height: PraniSpacing.sm),
        _DotIndicator(activeIndex: _index, count: cards.length),
      ],
    );
  }
}

class _PreparationSwipeCard extends StatelessWidget {
  const _PreparationSwipeCard({required this.data});

  final _PreparationCardData data;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(right: PraniSpacing.md),
      child: Container(
        padding: const EdgeInsets.all(PraniSpacing.lg),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(PraniRadius.lg),
          boxShadow: PraniShadows.elevatedCardShadow(
            Theme.of(context).brightness,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(data.icon, size: 28, color: scheme.primary),
            const SizedBox(height: PraniSpacing.sm),
            Text(
              data.title,
              style: PraniTextStyles.subheading(
                scheme,
                Theme.of(context).textTheme,
              ),
            ),
            const SizedBox(height: PraniSpacing.xs),
            Text(
              data.subtitle,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: PraniTextStyles.bodyMuted(
                scheme,
                Theme.of(context).textTheme,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreparationHeatGuide extends StatelessWidget {
  const _PreparationHeatGuide({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final items = AiPreparationCenterCopy.heatGuideItems();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: AiPreparationCenterCopy.heatGuideTitle,
          subtitle: AiPreparationCenterCopy.heatGuideSubtitle,
        ),
        const SizedBox(height: PraniSpacing.sm),
        Wrap(
          spacing: PraniSpacing.sm,
          runSpacing: PraniSpacing.sm,
          children: items
              .map(
                (item) => _MiniGuideCard(
                  item: item,
                  compact: compact,
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _PreparationDiagramRail extends StatelessWidget {
  const _PreparationDiagramRail({
    required this.templateId,
    required this.items,
  });

  final String templateId;
  final List<SemenCatalogMediaLine> items;

  @override
  Widget build(BuildContext context) {
    return TemplateLearningSectionShell(
      icon: Icons.account_tree_outlined,
      title: AiPreparationCenterCopy.diagramTitle,
      subtitle: AiPreparationCenterCopy.diagramSubtitle,
      child: items.isEmpty
          ? _PreparationEmptyState(
              title: AiPreparationCenterCopy.emptyStateTitle,
              subtitle: AiPreparationCenterCopy.emptyStateSubtitle,
            )
          : TemplateMediaGallery(
              title: AiPreparationCenterCopy.diagramTitle,
              items: items,
              templateId: templateId,
              onItemOpened: (id, kind) {},
            ),
    );
  }
}

class _PreparationChecklistGroup extends StatelessWidget {
  const _PreparationChecklistGroup({
    required this.title,
    required this.items,
  });

  final String title;
  final List<_ChecklistEntry> items;

  @override
  Widget build(BuildContext context) {
    return _PreparationExpandableBlock(
      title: title,
      child: Column(
        children: items
            .map(
              (item) => CheckboxListTile(
                value: item.value,
                onChanged: item.onChanged,
                title: Text(item.label),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                dense: true,
              ),
            )
            .toList(),
      ),
    );
  }
}

class _ChecklistEntry {
  const _ChecklistEntry({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool?> onChanged;
}

class _AiNarrationTrigger extends StatelessWidget {
  const _AiNarrationTrigger({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return _PreparationExpandableBlock(
      title: AiPreparationCenterCopy.aiNarrationTitle,
      subtitle: AiPreparationCenterCopy.aiNarrationSubtitle,
      child: PraniPrimaryButton(
        label: AiPreparationCenterCopy.aiNarrationAction,
        icon: Icons.auto_awesome,
        onPressed: onPressed,
      ),
    );
  }
}

class _VeterinaryWarningBanner extends StatelessWidget {
  const _VeterinaryWarningBanner({
    required this.baseUrl,
    required this.warningHtml,
  });

  final String baseUrl;
  final String? warningHtml;

  @override
  Widget build(BuildContext context) {
    final warning = warningHtml?.trim();
    final hasWarning = warning != null && warning.isNotEmpty;
    return TemplateClinicalAlert(
      title: AiPreparationCenterCopy.warningTitle,
      severity:
          hasWarning ? TemplateClinicalSeverity.warning : TemplateClinicalSeverity.info,
      child: Text(
        hasWarning
            ? TemplateHtmlSanitizer.sanitize(warning, apiBaseUrl: baseUrl)
            : AiPreparationCenterCopy.warningFallback,
        style: PraniTextStyles.body(
          Theme.of(context).colorScheme,
          Theme.of(context).textTheme,
        ),
      ),
    );
  }
}

class _ProtocolNotes extends StatelessWidget {
  const _ProtocolNotes({
    required this.title,
    required this.subtitle,
    required this.content,
    required this.baseUrl,
  });

  final String title;
  final String subtitle;
  final String? content;
  final String baseUrl;

  @override
  Widget build(BuildContext context) {
    final body = content?.trim();
    return _PreparationExpandableBlock(
      title: title,
      subtitle: subtitle,
      child: body == null || body.isEmpty
          ? _PreparationEmptyState(
              title: AiPreparationCenterCopy.emptyStateTitle,
              subtitle: AiPreparationCenterCopy.emptyStateSubtitle,
            )
          : Text(
              TemplateHtmlSanitizer.sanitize(body, apiBaseUrl: baseUrl),
              style: PraniTextStyles.body(
                Theme.of(context).colorScheme,
                Theme.of(context).textTheme,
              ),
            ),
    );
  }
}

class _PreparationFooter extends StatelessWidget {
  const _PreparationFooter({required this.onOfflineSchedule});

  final VoidCallback onOfflineSchedule;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SupportChip(
            icon: Icons.cloud_off_outlined,
            label: AiPreparationCenterCopy.offlineTitle,
            helper: AiPreparationCenterCopy.offlineSubtitle,
            actionLabel: AiPreparationCenterCopy.offlineAction,
            onAction: onOfflineSchedule,
          ),
        ),
        const SizedBox(width: PraniSpacing.sm),
        Expanded(
          child: _SupportChip(
            icon: Icons.support_agent,
            label: AiPreparationCenterCopy.assistantTitle,
            helper: AiPreparationCenterCopy.assistantSubtitle,
            actionLabel: AiPreparationCenterCopy.aiNarrationAction,
            onAction: onOfflineSchedule,
          ),
        ),
      ],
    );
  }
}

class _SupportChip extends StatelessWidget {
  const _SupportChip({
    required this.icon,
    required this.label,
    required this.helper,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String label;
  final String helper;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(PraniSpacing.md),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(PraniRadius.md),
        boxShadow: PraniShadows.elevatedCardShadow(
          Theme.of(context).brightness,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: scheme.primary),
          const SizedBox(height: PraniSpacing.xs),
          Text(
            label,
            style: PraniTextStyles.subheading(
              scheme,
              Theme.of(context).textTheme,
            ),
          ),
          const SizedBox(height: PraniSpacing.xs),
          Text(
            helper,
            style: PraniTextStyles.bodyMuted(
              scheme,
              Theme.of(context).textTheme,
            ),
          ),
          const SizedBox(height: PraniSpacing.sm),
          PraniSecondaryButton(
            label: actionLabel,
            onPressed: onAction,
            style: PraniSecondaryStyle.outlined,
          ),
        ],
      ),
    );
  }
}

class _PreparationExpandableBlock extends StatelessWidget {
  const _PreparationExpandableBlock({
    required this.title,
    this.subtitle,
    required this.child,
  });

  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(PraniRadius.md),
        boxShadow: PraniShadows.elevatedCardShadow(
          Theme.of(context).brightness,
        ),
      ),
      child: ExpansionTile(
        title: Text(
          title,
          style: PraniTextStyles.subheading(
            Theme.of(context).colorScheme,
            Theme.of(context).textTheme,
          ),
        ),
        subtitle: subtitle == null
            ? null
            : Text(
                subtitle!,
                style: PraniTextStyles.bodyMuted(
                  Theme.of(context).colorScheme,
                  Theme.of(context).textTheme,
                ),
              ),
        tilePadding: const EdgeInsets.symmetric(
          horizontal: PraniSpacing.md,
          vertical: PraniSpacing.xs,
        ),
        childrenPadding: const EdgeInsets.fromLTRB(
          PraniSpacing.md,
          0,
          PraniSpacing.md,
          PraniSpacing.md,
        ),
        children: [child],
      ),
    );
  }
}

class _PreparationEmptyState extends StatelessWidget {
  const _PreparationEmptyState({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(PraniSpacing.md),
      decoration: BoxDecoration(
        color: scheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(PraniRadius.md),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: scheme.primary),
          const SizedBox(width: PraniSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: PraniTextStyles.subheading(
                    scheme,
                    Theme.of(context).textTheme,
                  ),
                ),
                const SizedBox(height: PraniSpacing.xs),
                Text(
                  subtitle,
                  style: PraniTextStyles.bodyMuted(
                    scheme,
                    Theme.of(context).textTheme,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: PraniTextStyles.subheading(
            Theme.of(context).colorScheme,
            Theme.of(context).textTheme,
          ),
        ),
        const SizedBox(height: PraniSpacing.xs),
        Text(
          subtitle,
          style: PraniTextStyles.bodyMuted(
            Theme.of(context).colorScheme,
            Theme.of(context).textTheme,
          ),
        ),
      ],
    );
  }
}

class _MiniGuideCard extends StatelessWidget {
  const _MiniGuideCard({
    required this.item,
    required this.compact,
  });

  final _HeatGuideItem item;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: compact ? 140 : 160,
      padding: const EdgeInsets.all(PraniSpacing.md),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(PraniRadius.md),
        boxShadow: PraniShadows.elevatedCardShadow(
          Theme.of(context).brightness,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(item.icon, color: scheme.primary),
          const SizedBox(height: PraniSpacing.xs),
          Text(
            item.title,
            style: PraniTextStyles.subheading(
              scheme,
              Theme.of(context).textTheme,
            ),
          ),
          const SizedBox(height: PraniSpacing.xs),
          Text(
            item.subtitle,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: PraniTextStyles.bodyMuted(
              scheme,
              Theme.of(context).textTheme,
            ),
          ),
        ],
      ),
    );
  }
}

class _DotIndicator extends StatelessWidget {
  const _DotIndicator({required this.activeIndex, required this.count});

  final int activeIndex;
  final int count;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: List.generate(
        count,
        (i) => Container(
          width: i == activeIndex ? 18 : 8,
          height: 8,
          margin: const EdgeInsets.only(right: PraniSpacing.xs),
          decoration: BoxDecoration(
            color: i == activeIndex
                ? scheme.primary
                : scheme.onSurface.withOpacity(0.2),
            borderRadius: BorderRadius.circular(PraniRadius.pill),
          ),
        ),
      ),
    );
  }
}

class _PreparationShimmer extends StatelessWidget {
  const _PreparationShimmer();

  @override
  Widget build(BuildContext context) {
    return _PreparationShell(
      title: AiPreparationCenterCopy.sectionTitle,
      subtitle: AiPreparationCenterCopy.sectionSubtitle,
      child: Column(
        children: const [
          _ShimmerBox(height: 120),
          SizedBox(height: PraniSpacing.md),
          _ShimmerBox(height: 80),
          SizedBox(height: PraniSpacing.md),
          _ShimmerBox(height: 140),
        ],
      ),
    );
  }
}

class _ShimmerBox extends StatefulWidget {
  const _ShimmerBox({required this.height});

  final double height;

  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: PraniDurations.long,
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.25);
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Container(
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(PraniRadius.md),
            gradient: LinearGradient(
              begin: Alignment(-1 + _controller.value * 2, -1),
              end: Alignment(1 + _controller.value * 2, 1),
              colors: [
                base,
                base.withOpacity(0.6),
                base,
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PreparationCardData {
  const _PreparationCardData({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;
}

class _HeatGuideItem {
  const _HeatGuideItem({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;
}

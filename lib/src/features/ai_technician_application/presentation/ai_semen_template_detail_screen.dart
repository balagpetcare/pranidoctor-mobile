import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pranidoctor_mobile/src/core/network/api_client.dart';
import 'package:pranidoctor_mobile/src/core/storage/token_storage.dart';
import 'package:pranidoctor_mobile/src/design_system/prani_page_insets.dart';
import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_buttons.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_error_state.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_scaffold.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/application/ai_technician_providers.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/data/ai_technician_api_exception.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/data/semen_template_models.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/presentation/template_content/template_clinical_alert.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/presentation/template_content/template_detail_skeleton.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/presentation/template_content/template_html_sanitizer.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/presentation/template_content/template_info_card.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/presentation/template_learning/ai_preparation_center_section.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/presentation/template_learning/before_you_proceed_checklist.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/presentation/template_learning/template_learning_analytics.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/presentation/template_learning/template_learning_center.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/presentation/template_learning/template_media_partition.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/presentation/template_learning/template_professional_learning_sections.dart';

class AiSemenTemplateDetailScreen extends ConsumerStatefulWidget {
  const AiSemenTemplateDetailScreen({super.key, required this.templateId});

  final String templateId;

  static const routePath = '/profile/ai-technician/semen-templates';

  @override
  ConsumerState<AiSemenTemplateDetailScreen> createState() =>
      _AiSemenTemplateDetailScreenState();
}

class _AiSemenTemplateDetailScreenState
    extends ConsumerState<AiSemenTemplateDetailScreen>
    with TickerProviderStateMixin {
  final ScrollController _scroll = ScrollController();

  bool _loading = true;
  String? _error;
  SemenTemplateCatalogRow? _t;
  Map<String, String>? _imageHeaders;

  double _scrollFraction = 0;
  bool _scrollOverride = false;
  bool _warningAck = false;
  bool _sopAck = false;
  bool _optionalMediaAck = false;
  bool _scrollMilestoneLogged = false;
  bool _storageReady = false;
  bool _equipmentReady = false;
  bool _animalReady = false;
  bool _offlineMediaReady = false;
  int _confidenceIndex = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scroll.hasClients) return;
    final m = _scroll.position;
    final max = m.maxScrollExtent;
    final f = max <= 0 ? 1.0 : (m.pixels / max).clamp(0.0, 1.0);
    final crossed55 = f >= 0.55 && !_scrollMilestoneLogged;
    if ((f - _scrollFraction).abs() < 0.02 && !crossed55) return;
    setState(() => _scrollFraction = f);
    if (crossed55) {
      _scrollMilestoneLogged = true;
      TemplateLearningAnalytics.scrollMilestone(
        f,
        templateId: widget.templateId,
      );
      TemplateLearningAnalytics.sectionViewed(
        'scroll_read_threshold',
        templateId: widget.templateId,
      );
    }
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final token = await ref.read(tokenStorageProvider).readAccessToken();
      final headers = (token != null && token.isNotEmpty)
          ? <String, String>{'Authorization': 'Bearer $token'}
          : null;
      final t = await ref
          .read(aiTechnicianRepositoryProvider)
          .getSemenTemplate(widget.templateId);
      if (!mounted) return;
      setState(() {
        _t = t;
        _imageHeaders = headers;
        _loading = false;
        _scrollMilestoneLogged = false;
        _scrollFraction = 0;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e is AiTechnicianApiException ? e.message : 'লোড করা যায়নি';
        _loading = false;
      });
    }
  }

  bool _hasWarnings(SemenTemplateCatalogRow t, String base) {
    final w = t.warningsContraindications;
    if (w == null || w.trim().isEmpty) return false;
    return TemplateHtmlSanitizer.sanitize(
      w,
      apiBaseUrl: base,
    ).trim().isNotEmpty;
  }

  bool _readingGateOk() => _scrollFraction >= 0.55 || _scrollOverride;

  bool _mandatoryOk(SemenTemplateCatalogRow t, String base) {
    if (_hasWarnings(t, base) && !_warningAck) return false;
    final p = TemplateMediaPartition.fromRows(t.media);
    final hasSop = p.sopDocuments.isNotEmpty || p.protocolPdfs.isNotEmpty;
    if (hasSop && !_sopAck) return false;
    return _readingGateOk();
  }

  double _readinessScore(
    SemenTemplateCatalogRow t,
    String base,
    TemplateMediaPartition partition,
  ) {
    final items = <bool>[
      _readingGateOk(),
      !_hasWarnings(t, base) || _warningAck,
      partition.sopDocuments.isEmpty && partition.protocolPdfs.isEmpty || _sopAck,
    ];
    if (partition.hasAnyLearningMedia) {
      items.add(_optionalMediaAck);
    }
    final total = items.length;
    if (total == 0) return 1;
    final done = items.where((v) => v).length;
    return done / total;
  }

  double _preparationScore() {
    final items = <bool>[
      _storageReady,
      _equipmentReady,
      _animalReady,
      _offlineMediaReady,
    ];
    final done = items.where((v) => v).length;
    return done / items.length;
  }

  String _semenKindLabel(SemenTemplateCatalogRow t) {
    final label = t.otherSemenLabel?.trim();
    if (label != null && label.isNotEmpty) return label;
    switch (t.semenProductKind.toUpperCase()) {
      case 'SEXED':
        return 'সেক্সড';
      case 'NORMAL':
        return 'স্ট্যান্ডার্ড';
      default:
        return t.semenProductKind;
    }
  }

  String _riskLabel(bool hasWarnings) =>
      hasWarnings ? 'উচ্চ ঝুঁকি' : 'স্বাভাবিক ঝুঁকি';

  Widget _buildLoadedBody(
    BuildContext context,
    SemenTemplateCatalogRow t,
    String baseUrl,
  ) {
    final partition = TemplateMediaPartition.fromRows(t.media);
    final hasSopOrProtocol =
        partition.sopDocuments.isNotEmpty || partition.protocolPdfs.isNotEmpty;
    final readinessScore = _readinessScore(t, baseUrl, partition);
    final prepScore = _preparationScore();
    final protocolProgress = _scrollFraction;
    final missionProgress = (readinessScore + protocolProgress) / 2;
    final hasWarnings = _hasWarnings(t, baseUrl);
    final isCompact = MediaQuery.sizeOf(context).width < 360;

    return CustomScrollView(
      controller: _scroll,
      slivers: [
        SliverToBoxAdapter(
          child: _MissionHero(
            template: t,
            riskLabel: _riskLabel(hasWarnings),
            readinessScore: readinessScore,
            statusLabel: _mandatoryOk(t, baseUrl) ? 'প্রস্তুত' : 'প্রস্তুত হচ্ছে',
            semenKindLabel: _semenKindLabel(t),
            onPrimaryPressed: _mandatoryOk(t, baseUrl)
                ? () => context.push(
                    '${AiSemenTemplateDetailScreen.routePath}/${t.id}/confirm',
                  )
                : () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'চেকলিস্ট সম্পূর্ণ করুন — সতর্কতা, স্ক্রল ও প্রোটোকল নিশ্চিত করুন।',
                        ),
                      ),
                    );
                  },
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.only(top: PraniSpacing.xl),
          sliver: SliverToBoxAdapter(
            child: _SectionCard(
              title: 'মিশন প্রগ্রেস',
              subtitle: 'প্রোটোকল সম্পন্নতার হার ${(_scrollFraction * 100).round()}%',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ProgressTile(
                    label: 'মিশন অগ্রগতি',
                    value: missionProgress,
                  ),
                  const SizedBox(height: PraniSpacing.md),
                  _ProgressTile(
                    label: 'প্রস্তুতি সম্পন্ন',
                    value: prepScore,
                  ),
                  const SizedBox(height: PraniSpacing.md),
                  _ProgressTile(
                    label: 'প্রোটোকল অগ্রগতি',
                    value: protocolProgress,
                  ),
                  const SizedBox(height: PraniSpacing.lg),
                  _ConfidenceSelector(
                    value: _confidenceIndex,
                    onChanged: (v) => setState(() => _confidenceIndex = v),
                  ),
                ],
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.only(top: PraniSpacing.xl),
          sliver: SliverToBoxAdapter(
            child: _SectionCard(
              title: 'ক্রিটিকাল নির্দেশনা',
              subtitle: 'সর্বপ্রথম এই নির্দেশনা নিশ্চিত করুন',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TemplateClinicalAlert(
                    title: hasWarnings ? 'গুরুত্বপূর্ণ সতর্কতা' : 'ঝুঁকি কম',
                    severity: hasWarnings
                        ? TemplateClinicalSeverity.warning
                        : TemplateClinicalSeverity.info,
                    child: Text(
                      hasWarnings
                          ? TemplateHtmlSanitizer.sanitize(
                              t.warningsContraindications ?? '',
                              apiBaseUrl: baseUrl,
                            )
                          : 'এই টেমপ্লেটের জন্য উচ্চ ঝুঁকি উল্লেখ নেই।',
                      style: PraniTextStyles.body(
                        Theme.of(context).colorScheme,
                        Theme.of(context).textTheme,
                      ),
                    ),
                  ),
                  const SizedBox(height: PraniSpacing.lg),
                  _AiGuidanceBlock(
                    title: 'AI গাইডেন্স',
                    message:
                        'প্রাণীর অবস্থা, সময় এবং পরিবেশ চেক করুন। ঝুঁকি থাকলে ভেটেরিনারি অনুমোদন নিন।',
                  ),
                ],
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.only(top: PraniSpacing.xl),
          sliver: SliverToBoxAdapter(
            child: AiPreparationCenterSection(
              template: t,
              templateId: t.id,
              partition: partition,
              apiBaseUrl: baseUrl,
              imageHeaders: _imageHeaders,
              mode: isCompact
                  ? AiPreparationCenterMode.compact
                  : AiPreparationCenterMode.expanded,
              storageReady: _storageReady,
              equipmentReady: _equipmentReady,
              animalReady: _animalReady,
              offlineReady: _offlineMediaReady,
              onStorageChanged: (v) =>
                  setState(() => _storageReady = v ?? false),
              onEquipmentChanged: (v) =>
                  setState(() => _equipmentReady = v ?? false),
              onAnimalChanged: (v) =>
                  setState(() => _animalReady = v ?? false),
              onOfflineChanged: (v) =>
                  setState(() => _offlineMediaReady = v ?? false),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.only(top: PraniSpacing.xl),
          sliver: SliverToBoxAdapter(
            child: _ExpandableSection(
              title: 'ধাপভিত্তিক প্রোটোকল',
              subtitle: 'ধাপগুলো ট্যাপ করে অনুসরণ করুন',
              child: AnimatedSize(
                duration: PraniDurations.medium,
                curve: Curves.easeOut,
                child: TemplateProfessionalLearningSections(
                  template: t,
                  apiBaseUrl: baseUrl,
                  imageHeaders: _imageHeaders,
                  onSectionExpanded: (id, expanded) {
                    if (expanded) {
                      TemplateLearningAnalytics.sectionExpanded(
                        id,
                        templateId: t.id,
                      );
                    }
                  },
                ),
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.only(top: PraniSpacing.xl),
          sliver: SliverToBoxAdapter(
            child: _ExpandableSection(
              title: 'মিডিয়া লার্নিং সেন্টার',
              subtitle: 'অফলাইনে নিরাপদ প্রিভিউ',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _OfflineMediaPlaceholder(
                    available: partition.hasAnyLearningMedia,
                  ),
                  const SizedBox(height: PraniSpacing.md),
                  TemplateLearningCenter(
                    template: t,
                    templateId: t.id,
                    onVideoEngaged: () {},
                    onMediaOpened: (String mediaId, String kind) {},
                    onSopOpened: () {},
                  ),
                ],
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.only(top: PraniSpacing.xl),
          sliver: SliverToBoxAdapter(
            child: _ExpandableSection(
              title: 'ক্লিনিক্যাল নির্দেশনা',
              subtitle: 'প্রয়োজন অনুযায়ী খুলে দেখুন',
              child: Column(
                children: [
                  _ClinicalInstructionCard(
                    title: 'প্রত্যাশিত উপকারিতা',
                    body: t.expectedBenefits,
                    baseUrl: baseUrl,
                  ),
                  _ClinicalInstructionCard(
                    title: 'প্রস্তাবিত প্রাণীর অবস্থা',
                    body: t.recommendedAnimalCondition,
                    baseUrl: baseUrl,
                  ),
                  _ClinicalInstructionCard(
                    title: 'ডিটেইলড ব্যাখ্যা',
                    body: t.detailedDescription,
                    baseUrl: baseUrl,
                  ),
                  const SizedBox(height: PraniSpacing.md),
                  TemplateClinicalAlert(
                    title: 'ভেটেরিনারি নোট',
                    severity: TemplateClinicalSeverity.info,
                    child: Text(
                      'এই টেমপ্লেট তথ্য ও শিক্ষামূলক বিষয়বস্তু। চিকিৎসা সিদ্ধান্ত সবসময় যোগ্য '
                      'ভেটেরিনারিয়ানের পরামর্শে নিন।',
                      style: PraniTextStyles.body(
                        Theme.of(context).colorScheme,
                        Theme.of(context).textTheme,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.only(top: PraniSpacing.xl),
          sliver: SliverToBoxAdapter(
            child: _SectionCard(
              title: 'চালিয়ে যাওয়ার আগে',
              subtitle: 'চেকলিস্ট পূরণ না হলে পরের ধাপে যাবেন না',
              child: BeforeYouProceedChecklist(
                scrollFraction: _scrollFraction,
                scrollOverrideChecked: _scrollOverride,
                onScrollOverrideChanged: (v) {
                  setState(() => _scrollOverride = v ?? false);
                },
                hasWarnings: hasWarnings,
                warningAcknowledged: _warningAck,
                onWarningAckChanged: (v) {
                  final nv = v ?? false;
                  setState(() => _warningAck = nv);
                  TemplateLearningAnalytics.warningAcknowledged(
                    templateId: t.id,
                    skipped: !nv,
                  );
                },
                hasSopOrProtocol: hasSopOrProtocol,
                sopConfirmed: _sopAck,
                onSopConfirmedChanged: (v) {
                  setState(() => _sopAck = v ?? false);
                  if (v == true) {
                    TemplateLearningAnalytics.sopConfirmed(templateId: t.id);
                  }
                },
                optionalMediaAcknowledged: _optionalMediaAck,
                onOptionalMediaAckChanged: (v) {
                  final was = _optionalMediaAck;
                  final nv = v ?? false;
                  setState(() => _optionalMediaAck = nv);
                  if (was && !nv) {
                    TemplateLearningAnalytics.mediaSkipped(
                      'optional_media',
                      'ANY',
                      templateId: t.id,
                    );
                  }
                },
                showOptionalMediaRow: partition.hasAnyLearningMedia,
                onFutureAiNarration: () {
                  TemplateLearningAnalytics.sectionViewed(
                    'ai_narration_future',
                    templateId: t.id,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('শীঘ্রই উপলব্ধ হবে')),
                  );
                },
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.only(top: PraniSpacing.xl),
          sliver: SliverToBoxAdapter(
            child: _ExpandableSection(
              title: 'সার্ভিস তথ্য',
              subtitle: 'ক্যাটালগ তথ্য দেখুন',
              child: TemplateInfoCard(template: t),
            ),
          ),
        ),
        const SliverToBoxAdapter(
          child: SizedBox(height: PraniSpacing.xxl),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final hPad = PraniPageInsets.horizontalPadding(context);
    final baseUrl = ref.watch(apiClientProvider).baseUrl;
    final t = _t;

    return PraniScaffold(
      title: 'টেমপ্লেট বিস্তারিত',
      padding: EdgeInsets.zero,
      bottomNavigationBar: t == null
          ? null
          : _MissionBottomBar(
              enabled: _mandatoryOk(t, baseUrl),
              onPrimaryPressed: _mandatoryOk(t, baseUrl)
                  ? () => context.push(
                      '${AiSemenTemplateDetailScreen.routePath}/${t.id}/confirm',
                    )
                  : () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'চেকলিস্ট সম্পূর্ণ করুন — সতর্কতা, স্ক্রল ও প্রোটোকল নিশ্চিত করুন।',
                          ),
                        ),
                      );
                    },
              onSecondaryPressed: () {
                _scroll.animateTo(
                  _scroll.position.maxScrollExtent * 0.25,
                  duration: PraniDurations.medium,
                  curve: Curves.easeOut,
                );
              },
            ),
      body: _loading
          ? const Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: PraniSpacing.md),
                    child: Text('লোড হচ্ছে…'),
                  ),
                ),
                Expanded(child: TemplateDetailSkeleton()),
              ],
            )
          : _error != null || t == null
          ? Center(
              child: PraniErrorState(
                title: 'লোড করা যায়নি',
                message: _error ?? 'পাওয়া যায়নি',
                retryLabel: 'আবার চেষ্টা',
                onRetry: _load,
                boxed: true,
              ),
            )
          : Padding(
              padding: EdgeInsets.fromLTRB(
                hPad,
                PraniSpacing.md,
                hPad,
                PraniSpacing.lg,
              ),
              child: _buildLoadedBody(context, t, baseUrl),
            ),
    );
  }
}

class _MissionHero extends StatelessWidget {
  const _MissionHero({
    required this.template,
    required this.riskLabel,
    required this.readinessScore,
    required this.statusLabel,
    required this.semenKindLabel,
    required this.onPrimaryPressed,
  });

  final SemenTemplateCatalogRow template;
  final String riskLabel;
  final double readinessScore;
  final String statusLabel;
  final String semenKindLabel;
  final VoidCallback onPrimaryPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final breedSummary = template.breedSummaryBn;

    return Container(
      padding: const EdgeInsets.all(PraniSpacing.xl),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(PraniRadius.xl),
        boxShadow: PraniShadows.elevatedCardShadow(
          Theme.of(context).brightness,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: PraniSpacing.sm,
            runSpacing: PraniSpacing.sm,
            children: [
              _PillChip(label: statusLabel, tone: _ChipTone.primary),
              _PillChip(label: riskLabel, tone: _ChipTone.warning),
              _PillChip(
                label: 'রেডি ${((readinessScore) * 100).round()}%',
                tone: _ChipTone.success,
              ),
            ],
          ),
          const SizedBox(height: PraniSpacing.md),
          Text(
            template.internalName,
            style: PraniTextStyles.pageTitleProminent(scheme, textTheme),
          ),
          const SizedBox(height: PraniSpacing.xs),
          Text(
            template.semenProvider.name,
            style: PraniTextStyles.bodyMuted(scheme, textTheme),
          ),
          const SizedBox(height: PraniSpacing.lg),
          _InfoRow(
            label: 'প্রাণীর ধরন',
            value: template.animalType,
          ),
          const SizedBox(height: PraniSpacing.sm),
          _InfoRow(
            label: 'কম্প্যাটিবিলিটি',
            value: breedSummary.isEmpty ? 'উপলব্ধ নেই' : breedSummary,
          ),
          const SizedBox(height: PraniSpacing.sm),
          _InfoRow(
            label: 'সিমেন টাইপ',
            value: semenKindLabel,
          ),
          const SizedBox(height: PraniSpacing.lg),
          PraniPrimaryButton(
            label: 'মিশন শুরু করুন',
            onPressed: onPrimaryPressed,
          ),
        ],
      ),
    );
  }
}

class _MissionBottomBar extends StatelessWidget {
  const _MissionBottomBar({
    required this.enabled,
    required this.onPrimaryPressed,
    required this.onSecondaryPressed,
  });

  final bool enabled;
  final VoidCallback onPrimaryPressed;
  final VoidCallback onSecondaryPressed;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          PraniSpacing.xl,
          PraniSpacing.md,
          PraniSpacing.xl,
          PraniSpacing.md,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: PraniShadows.elevatedCardShadow(
            Theme.of(context).brightness,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: PraniPrimaryButton(
                label: enabled ? 'সার্ভিস তৈরি করুন' : 'চেকলিস্ট সম্পন্ন করুন',
                onPressed: enabled ? onPrimaryPressed : onPrimaryPressed,
              ),
            ),
            const SizedBox(width: PraniSpacing.sm),
            PraniSecondaryButton(
              label: 'ঝুঁকি দেখুন',
              onPressed: onSecondaryPressed,
              style: PraniSecondaryStyle.outlined,
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
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

class _ExpandableSection extends StatelessWidget {
  const _ExpandableSection({
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
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(PraniRadius.lg),
        boxShadow: PraniShadows.elevatedCardShadow(
          Theme.of(context).brightness,
        ),
      ),
      child: ExpansionTile(
        title: Text(
          title,
          style: PraniTextStyles.sectionTitleProminent(
            scheme,
            Theme.of(context).textTheme,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: PraniTextStyles.bodyMuted(scheme, Theme.of(context).textTheme),
        ),
        tilePadding: const EdgeInsets.all(PraniSpacing.xl),
        childrenPadding: const EdgeInsets.fromLTRB(
          PraniSpacing.xl,
          0,
          PraniSpacing.xl,
          PraniSpacing.xl,
        ),
        children: [child],
      ),
    );
  }
}

class _ProgressTile extends StatelessWidget {
  const _ProgressTile({required this.label, required this.value});

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: PraniTextStyles.label(scheme, Theme.of(context).textTheme),
        ),
        const SizedBox(height: PraniSpacing.xs),
        ClipRRect(
          borderRadius: BorderRadius.circular(PraniRadius.pill),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: value.clamp(0, 1)),
            duration: PraniDurations.medium,
            builder: (context, val, _) => LinearProgressIndicator(
              value: val,
              minHeight: 8,
              backgroundColor: PraniColors.surfaceAlt,
            ),
          ),
        ),
      ],
    );
  }
}

class _AiGuidanceBlock extends StatelessWidget {
  const _AiGuidanceBlock({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(PraniSpacing.lg),
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withOpacity(0.25),
        borderRadius: BorderRadius.circular(PraniRadius.md),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.auto_awesome, color: scheme.primary),
          const SizedBox(width: PraniSpacing.md),
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
                  message,
                  style: PraniTextStyles.body(scheme, Theme.of(context).textTheme),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OfflineMediaPlaceholder extends StatelessWidget {
  const _OfflineMediaPlaceholder({required this.available});

  final bool available;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(PraniSpacing.lg),
      decoration: BoxDecoration(
        color: PraniColors.surfaceAlt,
        borderRadius: BorderRadius.circular(PraniRadius.md),
      ),
      child: Row(
        children: [
          Icon(
            available ? Icons.offline_pin : Icons.cloud_off,
            color: available ? PraniColors.success : PraniColors.warning,
          ),
          const SizedBox(width: PraniSpacing.md),
          Expanded(
            child: Text(
              available
                  ? 'অফলাইনে ভিডিও/ডক ডাউনলোড করা আছে।'
                  : 'অফলাইনে ব্যবহারের জন্য মিডিয়া সংরক্ষণ করুন।',
              style: PraniTextStyles.bodyMuted(
                scheme,
                Theme.of(context).textTheme,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ClinicalInstructionCard extends StatelessWidget {
  const _ClinicalInstructionCard({
    required this.title,
    required this.body,
    required this.baseUrl,
  });

  final String title;
  final String? body;
  final String baseUrl;

  @override
  Widget build(BuildContext context) {
    final content = body?.trim();
    if (content == null || content.isEmpty) {
      return const SizedBox.shrink();
    }
    return Container(
      margin: const EdgeInsets.only(bottom: PraniSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(PraniRadius.md),
        boxShadow: PraniShadows.elevatedCardShadow(
          Theme.of(context).brightness,
        ),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(
          horizontal: PraniSpacing.md,
          vertical: PraniSpacing.xs,
        ),
        title: Text(
          title,
          style: PraniTextStyles.subheading(
            Theme.of(context).colorScheme,
            Theme.of(context).textTheme,
          ),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(
          PraniSpacing.md,
          0,
          PraniSpacing.md,
          PraniSpacing.md,
        ),
        children: [
          Text(
            TemplateHtmlSanitizer.sanitize(content, apiBaseUrl: baseUrl),
            style: PraniTextStyles.body(
              Theme.of(context).colorScheme,
              Theme.of(context).textTheme,
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfidenceSelector extends StatelessWidget {
  const _ConfidenceSelector({
    required this.value,
    required this.onChanged,
  });

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final options = const ['কম', 'মাঝারি', 'উচ্চ'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'টেকনিশিয়ান কনফিডেন্স',
          style: PraniTextStyles.label(
            Theme.of(context).colorScheme,
            Theme.of(context).textTheme,
          ),
        ),
        const SizedBox(height: PraniSpacing.xs),
        Wrap(
          spacing: PraniSpacing.sm,
          children: List.generate(
            options.length,
            (index) => ChoiceChip(
              label: Text(options[index]),
              selected: value == index,
              onSelected: (_) => onChanged(index),
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: PraniTextStyles.label(scheme, Theme.of(context).textTheme),
          ),
        ),
        const SizedBox(width: PraniSpacing.sm),
        Expanded(
          child: Text(
            value,
            style: PraniTextStyles.body(scheme, Theme.of(context).textTheme),
          ),
        ),
      ],
    );
  }
}

enum _ChipTone { primary, success, warning }

class _PillChip extends StatelessWidget {
  const _PillChip({required this.label, required this.tone});

  final String label;
  final _ChipTone tone;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    Color background;
    Color foreground;
    switch (tone) {
      case _ChipTone.success:
        background = PraniColors.successBright.withOpacity(0.2);
        foreground = PraniColors.success;
        break;
      case _ChipTone.warning:
        background = PraniColors.warningBright.withOpacity(0.2);
        foreground = PraniColors.warning;
        break;
      case _ChipTone.primary:
        background = scheme.primary.withOpacity(0.12);
        foreground = scheme.primary;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: PraniSpacing.md,
        vertical: PraniSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(PraniRadius.pill),
      ),
      child: Text(
        label,
        style: PraniTextStyles.label(scheme, Theme.of(context).textTheme)
            .copyWith(color: foreground),
      ),
    );
  }
}

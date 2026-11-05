import 'package:flutter/material.dart';

import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/data/semen_template_models.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/presentation/template_content/expandable_content_section.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/presentation/template_content/template_html_sanitizer.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/presentation/template_content/template_rich_content.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/presentation/template_content/template_warning_block.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/presentation/template_learning/template_learning_section_shell.dart';

/// Groups clinical / preparation / guidance HTML into enterprise shells.
class TemplateProfessionalLearningSections extends StatelessWidget {
  const TemplateProfessionalLearningSections({
    super.key,
    required this.template,
    required this.apiBaseUrl,
    required this.imageHeaders,
    required this.onSectionExpanded,
  });

  final SemenTemplateCatalogRow template;
  final String apiBaseUrl;
  final Map<String, String>? imageHeaders;
  final void Function(String sectionId, bool expanded) onSectionExpanded;

  bool _has(String? html) {
    if (html == null || html.trim().isEmpty) return false;
    return TemplateHtmlSanitizer.sanitize(
      html,
      apiBaseUrl: apiBaseUrl,
    ).trim().isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'পেশাদার বিভাগ',
          style: PraniTextStyles.pageTitleProminent(
            scheme,
            textTheme,
          ).copyWith(fontSize: 20),
        ),
        const SizedBox(height: PraniSpacing.xl),
        TemplateLearningSectionShell(
          icon: Icons.shield_outlined,
          title: 'ক্লিনিক্যাল সেফটি',
          subtitle: 'সতর্কতা ও প্রতিবন্ধক',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_has(template.warningsContraindications))
                TemplateWarningBlock(
                  rawHtml: template.warningsContraindications,
                  apiBaseUrl: apiBaseUrl,
                  imageRequestHeaders: imageHeaders,
                )
              else
                Text(
                  'কোনো সতর্কতা টেক্সট যুক্ত করা হয়নি।',
                  style: PraniTextStyles.bodyMuted(scheme, textTheme),
                ),
            ],
          ),
        ),
        if (_has(template.shortDescription)) ...[
          const SizedBox(height: PraniSpacing.md),
          TemplateLearningSectionShell(
            icon: Icons.build_circle_outlined,
            title: 'প্রস্তুতি',
            subtitle: 'সংক্ষিপ্ত নির্দেশনা',
            child: ExpandableContentSection(
              title: 'সংক্ষিপ্ত বিবরণ',
              initiallyExpanded: true,
              onExpansionChanged: (x) => onSectionExpanded('prep_short', x),
              child: TemplateRichContent(
                rawHtml: template.shortDescription,
                apiBaseUrl: apiBaseUrl,
                imageRequestHeaders: imageHeaders,
              ),
            ),
          ),
        ],
        if (_has(template.expectedBenefits)) ...[
          const SizedBox(height: PraniSpacing.md),
          TemplateLearningSectionShell(
            icon: Icons.smart_toy_outlined,
            title: 'AI সুপারিশ',
            subtitle: 'প্রত্যাশিত উপকারিতা',
            child: ExpandableContentSection(
              title: 'উপকারিতা',
              onExpansionChanged: (x) => onSectionExpanded('ai_benefits', x),
              child: TemplateRichContent(
                rawHtml: template.expectedBenefits,
                apiBaseUrl: apiBaseUrl,
                imageRequestHeaders: imageHeaders,
              ),
            ),
          ),
        ],
        if (_has(template.detailedDescription)) ...[
          const SizedBox(height: PraniSpacing.md),
          TemplateLearningSectionShell(
            icon: Icons.medical_services_outlined,
            title: 'ভেটেরিনারি গাইড',
            subtitle: 'বিস্তারিত প্রোটোকল টেক্সট',
            child: ExpandableContentSection(
              title: 'বিস্তারিত / প্রোটোকল',
              onExpansionChanged: (x) => onSectionExpanded('vet_detail', x),
              child: TemplateRichContent(
                rawHtml: template.detailedDescription,
                apiBaseUrl: apiBaseUrl,
                imageRequestHeaders: imageHeaders,
              ),
            ),
          ),
        ],
        if (_has(template.recommendedAnimalCondition)) ...[
          const SizedBox(height: PraniSpacing.md),
          TemplateLearningSectionShell(
            icon: Icons.pets_outlined,
            title: 'প্রাণীর অবস্থা ও হিট গাইড',
            subtitle: 'সুপারিশকৃত অবস্থা',
            child: ExpandableContentSection(
              title: 'সুপারিশকৃত প্রাণীর অবস্থা',
              onExpansionChanged: (x) =>
                  onSectionExpanded('animal_condition', x),
              child: TemplateRichContent(
                rawHtml: template.recommendedAnimalCondition,
                apiBaseUrl: apiBaseUrl,
                imageRequestHeaders: imageHeaders,
              ),
            ),
          ),
        ],
        const SizedBox(height: PraniSpacing.md),
        TemplateLearningSectionShell(
          icon: Icons.warning_amber_outlined,
          title: 'ঝুঁকির কারণ',
          subtitle: 'সংক্ষিপ্ত স্মারক',
          child: Text(
            _has(template.warningsContraindications)
                ? 'বিস্তারিত ঝুঁকি ও প্রতিবন্ধক উপরের ক্লিনিক্যাল সেফটি ব্লকে দেওয়া আছে।'
                : 'এই টেমপ্লেটে পৃথক ঝুঁকি তালিকা নেই।',
            style: PraniTextStyles.bodySmall(scheme, textTheme),
          ),
        ),
        const SizedBox(height: PraniSpacing.md),
        TemplateLearningSectionShell(
          icon: Icons.inventory_2_outlined,
          title: 'সংরক্ষণ নির্দেশনা',
          subtitle: 'স্টোরেজ',
          child: Text(
            'লিকুইড নাইট্রোজেন / ডিপ ফ্রিজ সংরক্ষণ টেমপ্লেট নথি ও স্থানীয় প্রোটোকল অনুসরণ করুন।',
            style: PraniTextStyles.bodySmall(scheme, textTheme),
          ),
        ),
        const SizedBox(height: PraniSpacing.md),
        TemplateLearningSectionShell(
          icon: Icons.timeline_outlined,
          title: 'হিট সনাক্তকরণ ও প্রজনন সময়',
          subtitle: 'ইনসেমিনেশন টাইমিং',
          child: Text(
            'হিট সাইকেল পর্যবেক্ষণ ও ইনসেমিনেশন উইন্ডো টেমপ্লেটের বিস্তারিত ও ভেটেরিনারি গাইডের সাথে মিলিয়ে নিন।',
            style: PraniTextStyles.bodySmall(scheme, textTheme),
          ),
        ),
      ],
    );
  }
}

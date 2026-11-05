import 'package:flutter/material.dart';

import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/data/ai_technician_models.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/data/semen_template_models.dart';

/// Summary header for semen template detail — metadata chips + pricing.
class TemplateInfoCard extends StatelessWidget {
  const TemplateInfoCard({super.key, required this.template});

  final SemenTemplateCatalogRow template;

  static String _semenKindLabel(String kind) {
    switch (kind) {
      case 'NORMAL':
        return 'সাধারণ';
      case 'SEXED':
        return 'লিঙ্গ নির্ধারিত';
      case 'PREMIUM':
        return 'প্রিমিয়াম';
      case 'IMPORTED':
        return 'আমদানি';
      case 'LOCAL':
        return 'দেশীয়';
      case 'OTHER':
        return 'অন্যান্য';
      default:
        return kind;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(PraniRadius.xl),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(PraniSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              template.internalName,
              style: PraniTextStyles.sectionTitleProminent(scheme, textTheme),
            ),
            const SizedBox(height: PraniSpacing.md),
            Wrap(
              spacing: PraniSpacing.sm,
              runSpacing: PraniSpacing.sm,
              children: [
                _Chip(label: 'প্রদানকারী', value: template.semenProvider.name),
                _Chip(
                  label: 'প্রাণী',
                  value: AiTechnicianAnimalTypes.labelBn(template.animalType),
                ),
                _Chip(
                  label: 'সিমেন ধরন',
                  value: _semenKindLabel(template.semenProductKind),
                ),
                if (template.otherSemenLabel != null &&
                    template.otherSemenLabel!.trim().isNotEmpty)
                  _Chip(
                    label: 'লেবেল',
                    value: template.otherSemenLabel!.trim(),
                  ),
              ],
            ),
            const SizedBox(height: PraniSpacing.md),
            Text(
              'জাত: ${template.breedSummaryBn}',
              style: PraniTextStyles.bodyMuted(scheme, textTheme),
            ),
            const SizedBox(height: PraniSpacing.sm),
            Text(
              'প্রস্তাবিত মূল্য: ৳${template.defaultBasePrice}',
              style: PraniTextStyles.body(
                scheme,
                textTheme,
              ).copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: PraniSpacing.md,
        vertical: PraniSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: scheme.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(PraniRadius.pill),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: Text(
        '$label: $value',
        style: PraniTextStyles.bodySmall(scheme, textTheme),
      ),
    );
  }
}

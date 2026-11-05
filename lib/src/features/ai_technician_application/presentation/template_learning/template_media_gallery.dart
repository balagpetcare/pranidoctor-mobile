import 'package:flutter/material.dart';

import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/data/semen_template_models.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/presentation/template_learning/template_authenticated_image.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/presentation/template_learning/template_fullscreen_media.dart';

/// Responsive grid of authenticated template images with fullscreen preview.
class TemplateMediaGallery extends StatelessWidget {
  const TemplateMediaGallery({
    super.key,
    required this.title,
    required this.items,
    required this.templateId,
    required this.onItemOpened,
  });

  final String title;
  final List<SemenCatalogMediaLine> items;
  final String templateId;
  final void Function(String mediaId, String kind) onItemOpened;

  @override
  Widget build(BuildContext context) {
    final withId = items
        .where((m) => m.uploadedFileId?.trim().isNotEmpty ?? false)
        .toList();
    if (withId.isEmpty) return const SizedBox.shrink();

    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final w = MediaQuery.sizeOf(context).width;
    final cols = w >= 400 ? 3 : 2;
    const gap = PraniSpacing.sm;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: PraniTextStyles.subheading(
            scheme,
            textTheme,
          ).copyWith(fontSize: 16),
        ),
        const SizedBox(height: PraniSpacing.sm),
        AnimatedSwitcher(
          duration: PraniDurations.medium,
          child: GridView.builder(
            key: ValueKey<String>(title),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: withId.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: cols,
              crossAxisSpacing: gap,
              mainAxisSpacing: gap,
              childAspectRatio: 1,
            ),
            itemBuilder: (context, i) {
              final m = withId[i];
              final id = m.uploadedFileId!;
              return Material(
                color: scheme.surfaceContainerHighest.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(PraniRadius.md),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () {
                    onItemOpened(m.id, m.kind);
                    TemplateFullscreenMedia.showImage(context, uploadId: id);
                  },
                  child: TemplateAuthenticatedImage(uploadId: id),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_buttons.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_form_card.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_form_tokens.dart';

/// Upload slot with title, status line, optional preview, and actions.
class PraniUploadCard extends StatelessWidget {
  const PraniUploadCard({
    super.key,
    required this.title,
    required this.statusLabel,
    this.footnote,
    this.onUpload,
    this.onRemove,
    this.enabled = true,
    this.isBusy = false,
    this.uploadProgress,
    this.preview,
    this.requiredSlot = false,
    this.uploadLabelEmpty,
    this.uploadLabelReplace,
  });

  final String title;
  final String statusLabel;

  /// Accepted types / max size (Bengali helper).
  final String? footnote;
  final VoidCallback? onUpload;
  final VoidCallback? onRemove;
  final bool enabled;
  final bool isBusy;

  /// 0–1 when known; null = indeterminate.
  final double? uploadProgress;

  /// Optional preview (e.g. aspect-ratio image or icon row).
  final Widget? preview;

  final bool requiredSlot;

  /// Overrides default Bengali upload labels (optional).
  final String? uploadLabelEmpty;
  final String? uploadLabelReplace;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return PraniFormCard(
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      requiredSlot ? '$title *' : title,
                      style: PraniTextStyles.subheading(
                        scheme,
                        textTheme,
                      ).copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: PraniSpacing.xs),
                    Text(
                      statusLabel,
                      style: PraniTextStyles.bodySmall(
                        scheme,
                        textTheme,
                      ).copyWith(color: scheme.onSurfaceVariant),
                    ),
                    if (footnote != null && footnote!.trim().isNotEmpty) ...[
                      const SizedBox(height: PraniSpacing.xs),
                      Text(
                        footnote!.trim(),
                        style: PraniTextStyles.caption(
                          scheme,
                          textTheme,
                        ).copyWith(color: scheme.onSurfaceVariant),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (preview != null) ...[
            const SizedBox(height: PraniSpacing.sm),
            ClipRRect(
              borderRadius: BorderRadius.circular(PraniRadius.md),
              child: preview!,
            ),
          ],
          if (isBusy) ...[
            const SizedBox(height: PraniSpacing.sm),
            LinearProgressIndicator(
              value: uploadProgress,
              backgroundColor: scheme.surfaceContainerHighest,
              color: scheme.primary,
            ),
          ],
          if (enabled) ...[
            const SizedBox(height: PraniSpacing.md),
            Row(
              children: [
                Expanded(
                  child: PraniSecondaryButton(
                    label: onRemove == null
                        ? (uploadLabelEmpty ?? 'ফাইল আপলোড করুন')
                        : (uploadLabelReplace ?? 'পরিবর্তন বা পুনরায় আপলোড'),
                    icon: Icons.cloud_upload_outlined,
                    isLoading: isBusy,
                    minimumHeight: PraniFormTokens.inputMinTouchHeight,
                    onPressed: isBusy ? null : onUpload,
                  ),
                ),
                if (onRemove != null) ...[
                  const SizedBox(width: PraniSpacing.sm),
                  IconButton(
                    tooltip: 'মুছুন',
                    onPressed: isBusy ? null : onRemove,
                    icon: const Icon(Icons.delete_outline),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_premium_card.dart';

/// Compact rejected application tile with update and feedback CTAs.
class RejectedApplicationView extends StatelessWidget {
  const RejectedApplicationView({
    super.key,
    required this.onUpdateApplication,
    required this.onViewFeedback,
    this.actionsDisabled = false,
  });

  final VoidCallback onUpdateApplication;
  final VoidCallback onViewFeedback;
  final bool actionsDisabled;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Semantics(
      container: true,
      label: 'Professional dashboard',
      child: PraniPremiumCard(
        padding: const EdgeInsets.symmetric(
          horizontal: PraniSpacing.md,
          vertical: PraniSpacing.sm,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: scheme.errorContainer.withValues(alpha: 0.5),
              ),
              child: Icon(
                Icons.feedback_outlined,
                color: scheme.error,
                size: 20,
              ),
            ),
            const SizedBox(width: PraniSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Update Required',
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'কিছু তথ্য সংশোধন প্রয়োজন',
                    style: textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontSize: 12,
                      height: 1.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: PraniSpacing.xs),
            _CompactIconButton(
              icon: Icons.visibility_outlined,
              tooltip: 'View feedback',
              onPressed: actionsDisabled ? null : onViewFeedback,
            ),
            const SizedBox(width: 4),
            _CompactUpdateButton(
              label: 'Update',
              onPressed: onUpdateApplication,
              disabled: actionsDisabled,
            ),
          ],
        ),
      ),
    );
  }
}

class _CompactIconButton extends StatelessWidget {
  const _CompactIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              border: Border.all(
                color: onPressed == null
                    ? scheme.outline.withValues(alpha: 0.3)
                    : scheme.outline,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 18,
              color: onPressed == null
                  ? scheme.onSurface.withValues(alpha: 0.4)
                  : scheme.primary,
            ),
          ),
        ),
      ),
    );
  }
}

class _CompactUpdateButton extends StatelessWidget {
  const _CompactUpdateButton({
    required this.label,
    required this.onPressed,
    this.disabled = false,
  });

  final String label;
  final VoidCallback onPressed;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: disabled
          ? scheme.primary.withValues(alpha: 0.4)
          : scheme.primary,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: disabled ? null : onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            label,
            style: textTheme.labelSmall?.copyWith(
              color: scheme.onPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}

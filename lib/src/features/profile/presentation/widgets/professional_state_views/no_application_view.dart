import 'package:flutter/material.dart';

import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_premium_card.dart';

/// Compact "become a professional" tile with dual apply options.
class NoApplicationView extends StatelessWidget {
  const NoApplicationView({
    super.key,
    required this.onApplyDoctor,
    required this.onApplyAiTechnician,
    this.actionsDisabled = false,
  });

  final VoidCallback onApplyDoctor;
  final VoidCallback onApplyAiTechnician;
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
                color: scheme.primaryContainer.withValues(alpha: 0.7),
              ),
              child: Icon(
                Icons.work_outline_rounded,
                color: scheme.primary,
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
                    'Become a Professional',
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Doctor বা AI Technician হিসেবে আবেদন করুন',
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
            _CompactApplyMenu(
              onApplyDoctor: onApplyDoctor,
              onApplyAiTechnician: onApplyAiTechnician,
              disabled: actionsDisabled,
            ),
          ],
        ),
      ),
    );
  }
}

class _CompactApplyMenu extends StatelessWidget {
  const _CompactApplyMenu({
    required this.onApplyDoctor,
    required this.onApplyAiTechnician,
    this.disabled = false,
  });

  final VoidCallback onApplyDoctor;
  final VoidCallback onApplyAiTechnician;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return PopupMenuButton<_ApplyOption>(
      enabled: !disabled,
      tooltip: 'Apply options',
      offset: const Offset(0, 36),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      onSelected: (option) {
        switch (option) {
          case _ApplyOption.doctor:
            onApplyDoctor();
          case _ApplyOption.aiTechnician:
            onApplyAiTechnician();
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: _ApplyOption.doctor,
          height: 44,
          child: Row(
            children: [
              Icon(Icons.medical_services_outlined, size: 20, color: scheme.primary),
              const SizedBox(width: 10),
              Text(
                'Apply as Doctor',
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: _ApplyOption.aiTechnician,
          height: 44,
          child: Row(
            children: [
              Icon(Icons.biotech_outlined, size: 20, color: scheme.primary),
              const SizedBox(width: 10),
              Text(
                'Apply as AI Technician',
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
      child: Material(
        color: scheme.primary,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Apply',
                style: textTheme.labelSmall?.copyWith(
                  color: scheme.onPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.arrow_drop_down_rounded,
                size: 18,
                color: scheme.onPrimary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _ApplyOption { doctor, aiTechnician }

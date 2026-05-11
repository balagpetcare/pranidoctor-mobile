import 'package:flutter/material.dart';

import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';
import 'package:pranidoctor_mobile/src/features/workspace/domain/professional_role.dart';
import 'package:pranidoctor_mobile/src/features/workspace/domain/workspace_entry.dart';
import 'package:pranidoctor_mobile/src/features/workspace/domain/workspace_status.dart';
import 'package:pranidoctor_mobile/src/features/workspace/presentation/widgets/workspace_badge.dart'
    as badge_widget;
import 'package:pranidoctor_mobile/src/features/workspace/presentation/widgets/workspace_status_indicator.dart';

class WorkspaceCard extends StatefulWidget {
  const WorkspaceCard({
    super.key,
    required this.entry,
    required this.onTap,
  });

  final WorkspaceEntry entry;
  final VoidCallback onTap;

  @override
  State<WorkspaceCard> createState() => _WorkspaceCardState();
}

class _WorkspaceCardState extends State<WorkspaceCard> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final entry = widget.entry;
    final gradientColors = entry.role.gradientColors(scheme);
    final accent = entry.role.accentColor(scheme);
    final elevation = _pressed ? 2.0 : 6.0;
    final scale = _pressed ? 0.995 : 1.0;

    return AnimatedScale(
      scale: scale,
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOut,
      child: Semantics(
        button: true,
        label: '${entry.title}, ${entry.status.labelBn}',
        child: Material(
          color: Colors.transparent,
          elevation: elevation,
          shadowColor: scheme.shadow.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(PraniRadii.lg),
          child: InkWell(
            onTap: widget.onTap,
            onTapDown: (_) => _setPressed(true),
            onTapCancel: () => _setPressed(false),
            onTapUp: (_) => _setPressed(false),
            borderRadius: BorderRadius.circular(PraniRadii.lg),
            child: Ink(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(PraniRadii.lg),
                border: Border.all(
                  color: scheme.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(PraniSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: scheme.surface.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(PraniRadii.md),
                          ),
                          child: Icon(entry.role.icon, color: accent),
                        ),
                        const SizedBox(width: PraniSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                entry.title,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w800),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                entry.subtitle,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: scheme.onSurfaceVariant,
                                      height: 1.35,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        if (entry.badge != null)
                          badge_widget.WorkspaceBadge(badge: entry.badge!),
                      ],
                    ),
                    const SizedBox(height: PraniSpacing.md),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        WorkspaceStatusIndicator(status: entry.status),
                        entry.status.isAccessible
                            ? FilledButton(
                                onPressed: widget.onTap,
                                style: FilledButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .labelLarge
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                                child: Text(entry.ctaLabel),
                              )
                            : FilledButton.tonal(
                                onPressed: widget.onTap,
                                style: FilledButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .labelLarge
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                                child: Text(entry.ctaLabel),
                              ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}


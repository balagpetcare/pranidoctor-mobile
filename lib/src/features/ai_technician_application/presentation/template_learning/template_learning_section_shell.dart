import 'package:flutter/material.dart';

import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';

/// Visual grouping shell for enterprise learning sections.
class TemplateLearningSectionShell extends StatelessWidget {
  const TemplateLearningSectionShell({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.child,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AnimatedSwitcher(
      duration: PraniDurations.short,
      child: Padding(
        key: ValueKey<String>(title),
        padding: const EdgeInsets.only(bottom: PraniSpacing.md),
        child: Material(
          color: scheme.surface.withValues(alpha: 0.92),
          elevation: 0,
          shadowColor: Colors.transparent,
          borderRadius: BorderRadius.circular(PraniRadius.xl),
          child: Padding(
            padding: const EdgeInsets.all(PraniSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: scheme.primaryContainer.withValues(alpha: 0.45),
                        borderRadius: BorderRadius.circular(PraniRadius.md),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(PraniSpacing.sm),
                        child: Icon(icon, color: scheme.primary, size: 22),
                      ),
                    ),
                    const SizedBox(width: PraniSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: PraniTextStyles.sectionTitleProminent(
                              scheme,
                              textTheme,
                            ),
                          ),
                          if (subtitle != null &&
                              subtitle!.trim().isNotEmpty) ...[
                            const SizedBox(height: PraniSpacing.xxs),
                            Text(
                              subtitle!,
                              style: PraniTextStyles.bodyMuted(
                                scheme,
                                textTheme,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: PraniSpacing.lg),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';

/// High-visibility clinical / operational callout (Flutter-native, not HTML).
enum TemplateClinicalSeverity { info, warning, danger, success }

class TemplateClinicalAlert extends StatelessWidget {
  const TemplateClinicalAlert({
    super.key,
    required this.title,
    required this.child,
    this.severity = TemplateClinicalSeverity.info,
    this.leadingIcon,
  });

  final String title;
  final Widget child;
  final TemplateClinicalSeverity severity;
  final IconData? leadingIcon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final (
      Color bg,
      Color border,
      Color fg,
      IconData icon,
    ) = switch (severity) {
      TemplateClinicalSeverity.info => (
        scheme.primaryContainer.withValues(alpha: 0.55),
        scheme.primary.withValues(alpha: 0.35),
        scheme.onPrimaryContainer,
        leadingIcon ?? Icons.info_outline_rounded,
      ),
      TemplateClinicalSeverity.warning => (
        scheme.tertiaryContainer.withValues(alpha: 0.55),
        scheme.tertiary.withValues(alpha: 0.45),
        scheme.onTertiaryContainer,
        leadingIcon ?? Icons.warning_amber_rounded,
      ),
      TemplateClinicalSeverity.danger => (
        scheme.errorContainer.withValues(alpha: 0.6),
        scheme.error.withValues(alpha: 0.45),
        scheme.onErrorContainer,
        leadingIcon ?? Icons.health_and_safety_outlined,
      ),
      TemplateClinicalSeverity.success => (
        scheme.secondaryContainer.withValues(alpha: 0.5),
        scheme.secondary.withValues(alpha: 0.4),
        scheme.onSecondaryContainer,
        leadingIcon ?? Icons.check_circle_outline_rounded,
      ),
    };

    return Semantics(
      container: true,
      label: title,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(PraniRadius.lg),
          border: Border.all(color: border, width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(PraniSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, color: fg, size: 22),
                  const SizedBox(width: PraniSpacing.md),
                  Expanded(
                    child: Text(
                      title,
                      style: PraniTextStyles.subheading(
                        scheme,
                        textTheme,
                      ).copyWith(color: fg, fontSize: 16),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: PraniSpacing.md),
              DefaultTextStyle.merge(
                style: PraniTextStyles.body(
                  scheme,
                  textTheme,
                ).copyWith(color: scheme.onSurface),
                child: child,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

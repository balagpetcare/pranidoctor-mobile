import 'package:flutter/material.dart';

import '../prani_tokens.dart';
import 'prani_buttons.dart';

/// Provider list row — doctors, technicians, or similar directory entries.
class PraniProviderCard extends StatelessWidget {
  const PraniProviderCard({
    super.key,
    required this.name,
    required this.onTap,
    this.roleLine,
    this.areaLine,
    this.ratingLine,
    this.availabilityLine,
    this.feeLine,
    this.avatar,
    this.tags = const <Widget>[],
    this.primaryActionLabel,
    this.onPrimaryAction,
    this.secondaryActionLabel,
    this.onSecondaryAction,
  });

  final String name;
  final VoidCallback onTap;
  final String? roleLine;
  final String? areaLine;
  final String? ratingLine;
  final String? availabilityLine;
  final String? feeLine;
  final Widget? avatar;
  final List<Widget> tags;
  final String? primaryActionLabel;
  final VoidCallback? onPrimaryAction;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryAction;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final displayName = name.trim().isEmpty ? 'নাম পাওয়া যায়নি' : name.trim();

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: BorderRadius.circular(PraniRadius.lg),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: PraniSpacing.xl,
            vertical: PraniSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (avatar != null) ...[
                    avatar!,
                    const SizedBox(width: PraniSpacing.md),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: PraniTextStyles.heading(scheme, textTheme),
                        ),
                        if (roleLine != null &&
                            roleLine!.trim().isNotEmpty) ...[
                          const SizedBox(height: PraniSpacing.xxs),
                          Text(
                            roleLine!.trim(),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: PraniTextStyles.bodyMuted(scheme, textTheme),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              if (tags.isNotEmpty) ...[
                const SizedBox(height: PraniSpacing.sm),
                Wrap(
                  spacing: PraniSpacing.xs,
                  runSpacing: PraniSpacing.xs,
                  children: tags,
                ),
              ],
              if (areaLine != null && areaLine!.trim().isNotEmpty) ...[
                const SizedBox(height: PraniSpacing.sm),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.place_outlined, size: 20, color: scheme.primary),
                    const SizedBox(width: PraniSpacing.xs),
                    Expanded(
                      child: Text(
                        areaLine!.trim(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: PraniTextStyles.body(scheme, textTheme),
                      ),
                    ),
                  ],
                ),
              ],
              if (feeLine != null && feeLine!.trim().isNotEmpty) ...[
                const SizedBox(height: PraniSpacing.xs),
                Text(
                  feeLine!.trim(),
                  style: PraniTextStyles.bodyMuted(scheme, textTheme),
                ),
              ],
              if (availabilityLine != null &&
                  availabilityLine!.trim().isNotEmpty) ...[
                const SizedBox(height: PraniSpacing.xxs),
                Text(
                  availabilityLine!.trim(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: PraniTextStyles.caption(scheme, textTheme),
                ),
              ],
              if (ratingLine != null && ratingLine!.trim().isNotEmpty) ...[
                const SizedBox(height: PraniSpacing.xxs),
                Text(
                  ratingLine!.trim(),
                  style: PraniTextStyles.label(
                    scheme,
                    textTheme,
                  ).copyWith(color: scheme.onSurfaceVariant),
                ),
              ],
              if (primaryActionLabel != null ||
                  secondaryActionLabel != null) ...[
                const SizedBox(height: PraniSpacing.md),
                Wrap(
                  spacing: PraniSpacing.sm,
                  runSpacing: PraniSpacing.sm,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (secondaryActionLabel != null &&
                        onSecondaryAction != null)
                      PraniSecondaryButton(
                        label: secondaryActionLabel!,
                        onPressed: onSecondaryAction,
                        icon: Icons.call_outlined,
                      ),
                    if (primaryActionLabel != null && onPrimaryAction != null)
                      PraniPrimaryButton(
                        label: primaryActionLabel!,
                        onPressed: onPrimaryAction,
                        fullWidth: false,
                        icon: Icons.event_note_outlined,
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

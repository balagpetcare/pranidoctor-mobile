import 'package:flutter/material.dart';

import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';

typedef HomeServiceTap = void Function(int index);

/// Four primary service tiles in a 2×2 grid.
class CustomerHomeServicesGrid extends StatelessWidget {
  const CustomerHomeServicesGrid({super.key, required this.onServiceTap});

  final HomeServiceTap onServiceTap;

  static const _items = <({String label, IconData icon, Color tint})>[
    (
      label: 'ভেটেরিনারি কনসালটেশন',
      icon: Icons.medical_services_outlined,
      tint: Color(0xFFE0F7F3),
    ),
    (
      label: 'টিকা ও ভ্যাকসিনেশন',
      icon: Icons.vaccines_outlined,
      tint: Color(0xFFE0F2FE),
    ),
    (
      label: 'ঔষধ ও পণ্য কিনুন',
      icon: Icons.medication_liquid_outlined,
      tint: Color(0xFFFFF4E6),
    ),
    (
      label: 'স্বাস্থ্য চেকআপ প্যাকেজ',
      icon: Icons.health_and_safety_outlined,
      tint: Color(0xFFF3E8FF),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxW = constraints.maxWidth;
        final spacing = PraniSpacing.md;
        final tileW = (maxW - spacing) / 2;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: List.generate(_items.length, (i) {
            final item = _items[i];
            return SizedBox(
              width: tileW,
              child: _ServiceTile(
                label: item.label,
                icon: item.icon,
                pastel: item.tint,
                border: scheme.outlineVariant.withValues(alpha: 0.35),
                textStyle: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  height: 1.25,
                  color: scheme.onSurface,
                ),
                onTap: () => onServiceTap(i),
              ),
            );
          }),
        );
      },
    );
  }
}

class _ServiceTile extends StatelessWidget {
  const _ServiceTile({
    required this.label,
    required this.icon,
    required this.pastel,
    required this.border,
    required this.textStyle,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color pastel;
  final Color border;
  final TextStyle? textStyle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: scheme.surface,
      elevation: 2,
      shadowColor: const Color(0x121F2937),
      surfaceTintColor: Colors.transparent,
      borderRadius: BorderRadius.circular(PraniRadii.lg),
      child: InkWell(
        borderRadius: BorderRadius.circular(PraniRadii.lg),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(PraniRadii.lg),
            border: Border.all(color: border),
            color: scheme.surface,
          ),
          child: Padding(
            padding: const EdgeInsets.all(PraniSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: pastel,
                    borderRadius: BorderRadius.circular(PraniRadii.md),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(PraniSpacing.sm),
                    child: Icon(icon, color: scheme.primary, size: 26),
                  ),
                ),
                const SizedBox(height: PraniSpacing.md),
                Text(
                  label,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: textStyle,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

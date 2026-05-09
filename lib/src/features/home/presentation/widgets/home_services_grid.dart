import 'package:flutter/material.dart';

import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';
import 'package:pranidoctor_mobile/src/features/home/presentation/widgets/service_card.dart';

typedef HomeServiceTap = void Function(int index);

/// Four primary service tiles in a 2×2 grid with equal row heights.
class HomeServicesGrid extends StatelessWidget {
  const HomeServicesGrid({super.key, required this.onServiceTap});

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
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxW = constraints.maxWidth;
        final spacing = PraniSpacing.sm;
        final tileW = (maxW - spacing) / 2;
        final tileH = (tileW / 0.92).clamp(ServiceCard.minTileHeight, 168.0);

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: spacing,
          crossAxisSpacing: spacing,
          childAspectRatio: tileW / tileH,
          children: List.generate(_items.length, (i) {
            final item = _items[i];
            return ServiceCard(
              label: item.label,
              icon: item.icon,
              pastel: item.tint,
              onTap: () => onServiceTap(i),
            );
          }),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';

import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';
import 'package:pranidoctor_mobile/src/features/notifications/domain/notification_category.dart';

class NotificationCategoryFilterBar extends StatelessWidget {
  const NotificationCategoryFilterBar({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final NotificationCategory? selected;
  final ValueChanged<NotificationCategory?> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: PraniSpacing.sm),
            child: ChoiceChip(
              label: const Text('সব'),
              selected: selected == null,
              onSelected: (_) => onChanged(null),
            ),
          ),
          for (final c in NotificationCategory.values)
            Padding(
              padding: const EdgeInsets.only(right: PraniSpacing.sm),
              child: ChoiceChip(
                label: Text(c.labelBn),
                selected: selected == c,
                onSelected: (v) => onChanged(v ? c : null),
              ),
            ),
        ],
      ),
    );
  }
}

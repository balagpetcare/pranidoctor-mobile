import 'package:flutter/material.dart';

import 'package:pranidoctor_mobile/src/core/constants/pd_spacing.dart';
import 'package:pranidoctor_mobile/src/core/widgets/pd_app_card.dart';

class RequestPlaceholderSections extends StatelessWidget {
  const RequestPlaceholderSections({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    Widget card(String title, String body) {
      return PdAppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline_rounded, color: scheme.primary),
                const SizedBox(width: PdSpacing.sm),
                Expanded(
                  child: Text(
                    title,
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: PdSpacing.sm),
            Text(
              body,
              style: textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        card(
          'সমাপ্তির সারসংক্ষেপ',
          'চিকিৎসা শেষ হলে এখানে সংক্ষিপ্ত সারসংক্ষেপ দেখানো হবে।',
        ),
        const SizedBox(height: PdSpacing.sm),
        card(
          'প্রেসক্রিপশন / চিকিৎসা নোট',
          'প্রেসক্রিপশন ও চিকিৎসা সংক্রান্ত নোট শীঘ্রই যুক্ত করা হবে।',
        ),
        const SizedBox(height: PdSpacing.sm),
        card(
          'বিল ও পেমেন্ট',
          'বিলের বিবরণ ও পেমেন্টের অবস্থা পরবর্তী আপডেটে যুক্ত হবে।',
        ),
      ],
    );
  }
}

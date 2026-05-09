import 'package:flutter/material.dart';

import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';

/// Search + filter affordances (non-editable bar; parent handles taps).
class CustomerHomeSearchRow extends StatelessWidget {
  const CustomerHomeSearchRow({
    super.key,
    required this.onSearchTap,
    required this.onFilterTap,
  });

  final VoidCallback onSearchTap;
  final VoidCallback onFilterTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: scheme.surface,
      elevation: 1,
      shadowColor: const Color(0x121F2937),
      surfaceTintColor: Colors.transparent,
      borderRadius: BorderRadius.circular(PraniRadii.md),
      child: InkWell(
        borderRadius: BorderRadius.circular(PraniRadii.md),
        onTap: onSearchTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: PraniSpacing.md,
            vertical: PraniSpacing.md,
          ),
          child: Row(
            children: [
              IconButton(
                tooltip: 'খুঁজুন',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                onPressed: onSearchTap,
                icon: Icon(Icons.search_rounded, color: scheme.primary),
              ),
              Expanded(
                child: Text(
                  'ডাক্তার, সেবা, রোগ খুঁজুন...',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyLarge?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'ফিল্টার',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                onPressed: onFilterTap,
                icon: Icon(Icons.tune_rounded, color: scheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

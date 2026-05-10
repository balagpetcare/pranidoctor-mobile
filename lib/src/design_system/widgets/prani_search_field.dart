import 'package:flutter/material.dart';

import '../prani_color_scheme_ext.dart';

/// Themed search field — uses [InputDecorationTheme]; supports clear affordance.
class PraniSearchField extends StatelessWidget {
  const PraniSearchField({
    super.key,
    required this.controller,
    this.hintText = 'খুঁজুন…',
    this.onChanged,
    this.onSubmitted,
    this.prefixIcon = Icons.search_rounded,
    this.showClearButton = true,
    this.autofocus = false,
    this.textInputAction = TextInputAction.search,
  });

  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final IconData prefixIcon;
  final bool showClearButton;
  final bool autofocus;
  final TextInputAction textInputAction;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final hasText = value.text.trim().isNotEmpty;
        return TextField(
          controller: controller,
          autofocus: autofocus,
          textInputAction: textInputAction,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: Icon(prefixIcon, color: scheme.primary),
            suffixIcon: showClearButton && hasText
                ? IconButton(
                    tooltip: 'মুছুন',
                    onPressed: () {
                      controller.clear();
                      onChanged?.call('');
                    },
                    icon: Icon(
                      Icons.clear_rounded,
                      color: scheme.onSurfaceVariant,
                    ),
                  )
                : null,
            filled: true,
            fillColor: scheme.praniElevatedCard,
          ),
        );
      },
    );
  }
}

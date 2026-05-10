import 'package:flutter/material.dart';

import 'prani_buttons.dart';

/// Primary call-to-action — delegates to [PraniPrimaryButton].
class PraniPrimaryCtaButton extends StatelessWidget {
  const PraniPrimaryCtaButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return PraniPrimaryButton(
      label: label,
      onPressed: onPressed,
      icon: icon,
      fullWidth: true,
    );
  }
}

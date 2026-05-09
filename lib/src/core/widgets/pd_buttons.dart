import 'package:flutter/material.dart';

import '../constants/pd_spacing.dart';

/// Primary action — wraps [FilledButton] with loading state.
class PdPrimaryButton extends StatelessWidget {
  const PdPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    final busy = isLoading || onPressed == null;
    return FilledButton(
      onPressed: busy ? null : onPressed,
      child: isLoading
          ? SizedBox(
              height: 22,
              width: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            )
          : icon != null
          ? Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                icon!,
                const SizedBox(width: PdSpacing.xs),
                Text(label),
              ],
            )
          : Text(label),
    );
  }
}

/// Secondary / outline action.
class PdSecondaryButton extends StatelessWidget {
  const PdSecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    final busy = isLoading || onPressed == null;
    return OutlinedButton(
      onPressed: busy ? null : onPressed,
      child: isLoading
          ? SizedBox(
              height: 22,
              width: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Theme.of(context).colorScheme.primary,
              ),
            )
          : icon != null
          ? Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                icon!,
                const SizedBox(width: PdSpacing.xs),
                Text(label),
              ],
            )
          : Text(label),
    );
  }
}

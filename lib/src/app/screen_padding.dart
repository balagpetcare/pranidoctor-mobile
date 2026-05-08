import 'package:flutter/material.dart';

/// Horizontal padding tuned for common phone widths (no tablet-specific layout).
EdgeInsets pdScreenPadding(BuildContext context) {
  final w = MediaQuery.sizeOf(context).width;
  final h = (w * 0.055).clamp(16.0, 28.0);
  return EdgeInsets.symmetric(horizontal: h);
}

double pdReadableMaxWidth(BuildContext context) {
  final w = MediaQuery.sizeOf(context).width;
  return w.clamp(0.0, 520.0);
}

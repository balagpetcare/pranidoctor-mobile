import 'package:flutter/material.dart';

/// Circular completion indicator (0–100).
class ProfessionalCompletionRing extends StatelessWidget {
  const ProfessionalCompletionRing({
    super.key,
    required this.percent,
    this.size = 96,
    this.stroke = 8,
  });

  final double percent;
  final double size;
  final double stroke;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final v = (percent / 100).clamp(0.0, 1.0);
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: v,
              strokeWidth: stroke,
              backgroundColor: scheme.surfaceContainerHighest,
              color: scheme.primary,
            ),
          ),
          Text(
            '${percent.round()}%',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}

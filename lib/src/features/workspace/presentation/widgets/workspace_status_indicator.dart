import 'package:flutter/material.dart';

import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';
import 'package:pranidoctor_mobile/src/features/workspace/domain/workspace_status.dart';

class WorkspaceStatusIndicator extends StatelessWidget {
  const WorkspaceStatusIndicator({super.key, required this.status});

  final WorkspaceStatus status;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = _colorForStatus(scheme);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: PraniSpacing.xs),
        Text(
          status.labelBn,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: scheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }

  Color _colorForStatus(ColorScheme scheme) {
    switch (status) {
      case WorkspaceStatus.active:
        return scheme.primary;
      case WorkspaceStatus.pending:
        return scheme.tertiary;
      case WorkspaceStatus.suspended:
      case WorkspaceStatus.rejected:
        return scheme.error;
      case WorkspaceStatus.inactive:
        return scheme.outline;
    }
  }
}


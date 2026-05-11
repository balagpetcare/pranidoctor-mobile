import 'package:flutter/material.dart';

import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';
import 'package:pranidoctor_mobile/src/features/workspace/domain/workspace_entry.dart';

class WorkspaceSwitcher extends StatelessWidget {
  const WorkspaceSwitcher({
    super.key,
    required this.entries,
    required this.current,
    required this.onSelect,
  });

  final List<WorkspaceEntry> entries;
  final WorkspaceEntry? current;
  final ValueChanged<WorkspaceEntry> onSelect;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: PraniSpacing.sm,
      runSpacing: PraniSpacing.sm,
      children: entries.map((entry) {
        final selected = current?.role == entry.role;
        return ChoiceChip(
          label: Text(entry.title),
          selected: selected,
          onSelected: (_) => onSelect(entry),
        );
      }).toList(),
    );
  }
}


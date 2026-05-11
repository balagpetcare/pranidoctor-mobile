import 'package:flutter/material.dart';

import 'package:pranidoctor_mobile/src/features/workspace/config/professional_workspace_tab_config.dart';

/// Matches [HomeShellScreen] navigation styling (Material 3 [NavigationBar]).
class ProfessionalBottomNavigation extends StatelessWidget {
  const ProfessionalBottomNavigation({
    super.key,
    required this.definitions,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<ProfessionalNavTabDefinition> definitions;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      elevation: 6,
      shadowColor: Colors.black.withValues(alpha: 0.12),
      surfaceTintColor: Colors.transparent,
      color: scheme.surface,
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: 4),
        child: NavigationBar(
          height: 72,
          elevation: 0,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          backgroundColor: scheme.surface,
          indicatorColor: scheme.primaryContainer,
          selectedIndex: selectedIndex.clamp(0, definitions.length - 1),
          onDestinationSelected: onSelected,
          destinations: [
            for (final d in definitions)
              NavigationDestination(
                icon: Icon(d.icon),
                selectedIcon: Icon(d.selectedIcon),
                label: d.bottomLabel,
              ),
          ],
        ),
      ),
    );
  }
}

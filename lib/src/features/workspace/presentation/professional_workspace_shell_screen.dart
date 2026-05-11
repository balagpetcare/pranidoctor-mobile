import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pranidoctor_mobile/src/features/enterprise_insights/presentation/widgets/enterprise_sync_monitor.dart';
import 'package:pranidoctor_mobile/src/features/enterprise_media_upload/presentation/enterprise_media_upload_resume_watcher.dart';
import 'package:pranidoctor_mobile/src/features/session/application/session_notifier.dart';
import 'package:pranidoctor_mobile/src/features/workspace/application/current_workspace_provider.dart';
import 'package:pranidoctor_mobile/src/features/workspace/application/workspace_surface_provider.dart';
import 'package:pranidoctor_mobile/src/features/workspace/domain/professional_role.dart';
import 'package:pranidoctor_mobile/src/features/workspace/application/professional_workspace_tab_provider.dart';
import 'package:pranidoctor_mobile/src/features/workspace/config/professional_workspace_tab_config.dart';
import 'package:pranidoctor_mobile/src/features/workspace/presentation/professional_workspace_tab_page.dart';
import 'package:pranidoctor_mobile/src/features/workspace/presentation/widgets/professional_bottom_navigation.dart';
import 'package:pranidoctor_mobile/src/features/workspace/presentation/widgets/professional_workspace_drawer.dart';

/// Enterprise-style shell: drawer + dynamic bottom navigation per role.
class ProfessionalWorkspaceShellScreen extends ConsumerWidget {
  const ProfessionalWorkspaceShellScreen({
    super.key,
    required this.workspaceRole,
  });

  final AppRole workspaceRole;

  static const technicianPath = '/workspace/technician';
  static const aiTechnicianLegacyPath = '/workspace/ai-technician';
  static const doctorPath = '/workspace/doctor';

  static const aiTechnicianRouteName = 'workspaceAiTechnician';
  static const aiTechnicianLegacyRouteName = 'workspaceAiTechnicianLegacy';
  static const doctorRouteName = 'workspaceDoctor';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ProfessionalRoleX.fromAppRole(workspaceRole);
    final current = ref.watch(currentWorkspaceProvider);
    if (role != null && current != role) {
      Future.microtask(
        () => ref.read(currentWorkspaceProvider.notifier).setWorkspace(role),
      );
    }
    final surface = ref.watch(workspaceSurfaceProvider);
    if (surface != WorkspaceSurface.professional) {
      Future.microtask(
        () => ref
            .read(workspaceSurfaceProvider.notifier)
            .setSurface(WorkspaceSurface.professional),
      );
    }

    final defs = professionalNavTabsForRole(workspaceRole);
    if (defs.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('Unsupported workspace')),
      );
    }

    final index = ref.watch(professionalWorkspaceTabIndexProvider).clamp(
          0,
          defs.length - 1,
        );
    final title = defs[index].appBarTitle;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surfaceContainerLowest,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
      ),
      drawer: ProfessionalWorkspaceDrawer(workspaceRole: workspaceRole),
      body: EnterpriseSyncLifecycleWatcher(
        child: EnterpriseMediaUploadResumeWatcher(
          child: ColoredBox(
            color: scheme.surfaceContainerLowest,
            child: ProfessionalWorkspaceTabPage(
              workspaceRole: workspaceRole,
              tabIndex: index,
            ),
          ),
        ),
      ),
      bottomNavigationBar: ProfessionalBottomNavigation(
        definitions: defs,
        selectedIndex: index,
        onSelected: (i) {
          ref.read(professionalWorkspaceTabIndexProvider.notifier).select(i);
        },
      ),
    );
  }
}

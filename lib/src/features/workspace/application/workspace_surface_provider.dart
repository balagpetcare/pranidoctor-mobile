import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Whether the user is browsing the **general** consumer shell or the **professional** workspace.
///
/// Persisted as `pd_workspace_surface` so approved AI technicians / doctors can open `/home`
/// when they choose "Switch to General App", without fighting role-based redirects.
enum WorkspaceSurface {
  general,
  professional,
}

class WorkspaceSurfaceNotifier extends Notifier<WorkspaceSurface> {
  static const _prefsKey = 'pd_workspace_surface';

  @override
  WorkspaceSurface build() => WorkspaceSurface.general;

  Future<void> hydrateFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (!ref.mounted) return;
    final raw = prefs.getString(_prefsKey);
    if (raw == WorkspaceSurface.general.name) {
      state = WorkspaceSurface.general;
    } else if (raw == WorkspaceSurface.professional.name) {
      state = WorkspaceSurface.professional;
    }
  }

  Future<void> setSurface(WorkspaceSurface value) async {
    final prefs = await SharedPreferences.getInstance();
    if (!ref.mounted) return;
    await prefs.setString(_prefsKey, value.name);
    if (!ref.mounted) return;
    state = value;
  }
}

final workspaceSurfaceProvider =
    NotifierProvider<WorkspaceSurfaceNotifier, WorkspaceSurface>(
  WorkspaceSurfaceNotifier.new,
);

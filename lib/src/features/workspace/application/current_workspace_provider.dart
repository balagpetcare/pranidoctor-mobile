import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pranidoctor_mobile/src/features/workspace/domain/professional_role.dart';

class CurrentWorkspaceNotifier extends Notifier<ProfessionalRole?> {
  static const _prefsKey = 'pd_current_workspace_role';

  @override
  ProfessionalRole? build() => null;

  Future<void> hydrateFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (!ref.mounted) return;
    final raw = prefs.getString(_prefsKey);
    state = _fromStorage(raw);
  }

  Future<void> setWorkspace(ProfessionalRole? role) async {
    final prefs = await SharedPreferences.getInstance();
    if (!ref.mounted) return;
    if (role == null) {
      await prefs.remove(_prefsKey);
    } else {
      await prefs.setString(_prefsKey, role.name);
    }
    if (!ref.mounted) return;
    state = role;
  }

  ProfessionalRole? _fromStorage(String? raw) {
    switch (raw) {
      case 'aiTechnician':
        return ProfessionalRole.aiTechnician;
      case 'doctor':
        return ProfessionalRole.doctor;
      case 'seller':
        return ProfessionalRole.seller;
      case 'pharmacy':
        return ProfessionalRole.pharmacy;
      case 'ambulance':
        return ProfessionalRole.ambulance;
      case 'breeder':
        return ProfessionalRole.breeder;
      case 'ngoWorker':
        return ProfessionalRole.ngoWorker;
      default:
        return null;
    }
  }
}

final currentWorkspaceProvider =
    NotifierProvider<CurrentWorkspaceNotifier, ProfessionalRole?>(
  CurrentWorkspaceNotifier.new,
);


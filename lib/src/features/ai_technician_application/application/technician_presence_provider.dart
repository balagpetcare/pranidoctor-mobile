import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Client-side availability until backend ships `PATCH …/presence`.
enum TechnicianPresenceMode {
  online,
  offline,
  busy,
}

class TechnicianPresenceNotifier extends Notifier<TechnicianPresenceMode> {
  static const _prefsKey = 'pd_ai_technician_presence_mode_v1';

  @override
  TechnicianPresenceMode build() => TechnicianPresenceMode.online;

  Future<void> hydrateFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (!ref.mounted) return;
    final raw = prefs.getString(_prefsKey);
    state = _parse(raw) ?? TechnicianPresenceMode.online;
  }

  TechnicianPresenceMode? _parse(String? raw) {
    switch (raw) {
      case 'offline':
        return TechnicianPresenceMode.offline;
      case 'busy':
        return TechnicianPresenceMode.busy;
      case 'online':
        return TechnicianPresenceMode.online;
      default:
        return null;
    }
  }

  Future<void> setMode(TechnicianPresenceMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    if (!ref.mounted) return;
    await prefs.setString(_prefsKey, mode.name);
    if (!ref.mounted) return;
    state = mode;
  }
}

final technicianPresenceProvider =
    NotifierProvider<TechnicianPresenceNotifier, TechnicianPresenceMode>(
  TechnicianPresenceNotifier.new,
);

extension TechnicianPresenceModeBn on TechnicianPresenceMode {
  String get labelBn => switch (this) {
        TechnicianPresenceMode.online => 'অনলাইন',
        TechnicianPresenceMode.offline => 'অফলাইন',
        TechnicianPresenceMode.busy => 'ব্যস্ত',
      };
}

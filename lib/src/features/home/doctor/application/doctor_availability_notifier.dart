import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Client-side doctor desk presence until a dedicated `PATCH …/presence` exists.
enum DoctorPresenceMode {
  online,
  offline,
  busy,
}

class DoctorAvailabilityState {
  const DoctorAvailabilityState({
    this.mode = DoctorPresenceMode.online,
    this.emergencyAvailable = false,
  });

  final DoctorPresenceMode mode;
  final bool emergencyAvailable;

  DoctorAvailabilityState copyWith({
    DoctorPresenceMode? mode,
    bool? emergencyAvailable,
  }) {
    return DoctorAvailabilityState(
      mode: mode ?? this.mode,
      emergencyAvailable: emergencyAvailable ?? this.emergencyAvailable,
    );
  }
}

class DoctorAvailabilityNotifier extends Notifier<DoctorAvailabilityState> {
  static const _prefsModeKey = 'pd_doctor_presence_mode_v1';
  static const _prefsEmergencyKey = 'pd_doctor_emergency_available_v1';

  @override
  DoctorAvailabilityState build() => const DoctorAvailabilityState();

  Future<void> hydrateFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (!ref.mounted) return;
    final mode = _parseMode(prefs.getString(_prefsModeKey)) ??
        DoctorPresenceMode.online;
    final emerg = prefs.getBool(_prefsEmergencyKey) ?? false;
    state = DoctorAvailabilityState(mode: mode, emergencyAvailable: emerg);
  }

  DoctorPresenceMode? _parseMode(String? raw) {
    switch (raw) {
      case 'offline':
        return DoctorPresenceMode.offline;
      case 'busy':
        return DoctorPresenceMode.busy;
      case 'online':
        return DoctorPresenceMode.online;
      default:
        return null;
    }
  }

  Future<void> setMode(DoctorPresenceMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    if (!ref.mounted) return;
    await prefs.setString(_prefsModeKey, mode.name);
    if (!ref.mounted) return;
    state = state.copyWith(mode: mode);
  }

  Future<void> setEmergencyAvailable(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    if (!ref.mounted) return;
    await prefs.setBool(_prefsEmergencyKey, value);
    if (!ref.mounted) return;
    state = state.copyWith(emergencyAvailable: value);
  }
}

final doctorAvailabilityProvider =
    NotifierProvider<DoctorAvailabilityNotifier, DoctorAvailabilityState>(
  DoctorAvailabilityNotifier.new,
);

extension DoctorPresenceModeBn on DoctorPresenceMode {
  String get labelBn => switch (this) {
        DoctorPresenceMode.online => 'অনলাইন',
        DoctorPresenceMode.offline => 'অফলাইন',
        DoctorPresenceMode.busy => 'ব্যস্ত',
      };
}

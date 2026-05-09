import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/storage/token_storage.dart';

enum AppRole { customer, doctor }

class SessionState {
  const SessionState({this.role, this.isAuthenticated = false});

  final AppRole? role;
  final bool isAuthenticated;

  SessionState copyWith({AppRole? role, bool? isAuthenticated}) {
    return SessionState(
      role: role ?? this.role,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

class SessionNotifier extends Notifier<SessionState> {
  static const _lastRoleKey = 'pd_last_role';

  @override
  SessionState build() => const SessionState();

  /// Restores session flag from stored JWT (splash / cold start).
  Future<void> hydrateFromStorage() async {
    final token = await ref.read(tokenStorageProvider).readAccessToken();
    if (token == null || token.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final roleName = prefs.getString(_lastRoleKey);
    final role =
        roleName == AppRole.doctor.name ? AppRole.doctor : AppRole.customer;
    state = SessionState(role: role, isAuthenticated: true);
  }

  Future<void> signInCustomer(String accessToken) async {
    await ref.read(tokenStorageProvider).writeAccessToken(accessToken);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastRoleKey, AppRole.customer.name);
    state = const SessionState(
      role: AppRole.customer,
      isAuthenticated: true,
    );
  }

  Future<void> setRole(AppRole role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastRoleKey, role.name);
    state = state.copyWith(role: role, isAuthenticated: false);
  }

  Future<void> signOut() async {
    await ref.read(tokenStorageProvider).clear();
    state = const SessionState();
  }
}

final sessionNotifierProvider = NotifierProvider<SessionNotifier, SessionState>(
  SessionNotifier.new,
);

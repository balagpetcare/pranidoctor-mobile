import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/storage/token_storage.dart';

enum AppRole { customer, doctor, technician }

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
    final AppRole role;
    if (roleName == 'doctor') {
      role = AppRole.doctor;
    } else if (roleName == 'technician') {
      role = AppRole.technician;
    } else {
      role = AppRole.customer;
    }
    state = SessionState(role: role, isAuthenticated: true);
    assert(() {
      debugPrint(
        '[PraniDoctor][auth] hydrateFromStorage: session restored '
        '(role=${role.name}, token present)',
      );
      return true;
    }());
  }

  Future<void> signInCustomer(String accessToken) async {
    await ref.read(tokenStorageProvider).writeAccessToken(accessToken);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastRoleKey, AppRole.customer.name);
    state = const SessionState(role: AppRole.customer, isAuthenticated: true);
    assert(() {
      debugPrint(
        '[PraniDoctor][auth] customer sign-in: token persisted, '
        'session authenticated (customer)',
      );
      return true;
    }());
  }

  Future<void> setRole(AppRole role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastRoleKey, role.name);
    state = state.copyWith(role: role, isAuthenticated: false);
  }

  Future<void> signOut() async {
    await ref.read(tokenStorageProvider).clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastRoleKey);
    state = const SessionState();
    assert(() {
      debugPrint('[PraniDoctor][auth] sign-out: token cleared, session reset');
      return true;
    }());
  }
}

final sessionNotifierProvider = NotifierProvider<SessionNotifier, SessionState>(
  SessionNotifier.new,
);

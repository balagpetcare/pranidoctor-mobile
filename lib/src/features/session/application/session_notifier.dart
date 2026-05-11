import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/storage/token_storage.dart';
import '../../profile/data/dashboard_context_models.dart';
import '../../../app/workspace/workspace_gate_status.dart';

/// Logical persona for routing (mobile JWT + persisted prefs).
///
/// [technician] — legacy `/technician/*` shell (mock login).
/// [aiTechnician] — approved AI technician workspace (`/profile/ai-technician/*`).
enum AppRole {
  customer,
  doctor,
  technician,
  aiTechnician,
  admin,
}

class SessionState {
  const SessionState({
    this.role,
    this.isAuthenticated = false,
    this.professionalShellActive = false,
    this.workspaceGateStatus = WorkspaceGateStatus.idle,
  });

  final AppRole? role;
  final bool isAuthenticated;

  /// Doctor / legacy technician demo login without customer JWT — isolates `/home`.
  final bool professionalShellActive;

  /// Dashboard-context resolution after OTP/password sign-in.
  final WorkspaceGateStatus workspaceGateStatus;

  SessionState copyWith({
    AppRole? role,
    bool? isAuthenticated,
    bool? professionalShellActive,
    WorkspaceGateStatus? workspaceGateStatus,
  }) {
    return SessionState(
      role: role ?? this.role,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      professionalShellActive:
          professionalShellActive ?? this.professionalShellActive,
      workspaceGateStatus: workspaceGateStatus ?? this.workspaceGateStatus,
    );
  }
}

class SessionNotifier extends Notifier<SessionState> {
  static const _lastRoleKey = 'pd_last_role';

  @override
  SessionState build() => const SessionState();

  AppRole? _parsePersistedRole(String? roleName) {
    if (roleName == null || roleName.isEmpty) return null;
    switch (roleName) {
      case 'doctor':
        return AppRole.doctor;
      case 'technician':
        return AppRole.technician;
      case 'aiTechnician':
        return AppRole.aiTechnician;
      case 'admin':
        return AppRole.admin;
      case 'customer':
        return AppRole.customer;
      default:
        return AppRole.customer;
    }
  }

  AppRole _mapDashboardToRole(DashboardType type) {
    switch (type) {
      case DashboardType.general:
        return AppRole.customer;
      case DashboardType.aiTechnician:
        return AppRole.aiTechnician;
      case DashboardType.doctor:
        return AppRole.doctor;
    }
  }

  /// Restores session flag from stored JWT (splash / cold start).
  Future<void> hydrateFromStorage() async {
    final token = await ref.read(tokenStorageProvider).readAccessToken();
    if (!ref.mounted) return;

    final prefs = await SharedPreferences.getInstance();
    if (!ref.mounted) return;

    final roleName = prefs.getString(_lastRoleKey);
    final parsedRole = _parsePersistedRole(roleName);

    if (token == null || token.isEmpty) {
      final shellRole = parsedRole;
      if (shellRole != null && shellRole != AppRole.customer) {
        state = SessionState(
          role: shellRole,
          isAuthenticated: false,
          professionalShellActive: true,
          workspaceGateStatus: WorkspaceGateStatus.ready,
        );
        assert(() {
          debugPrint(
            '[PraniDoctor][auth] hydrateFromStorage: professional shell '
            '(role=${shellRole.name}, no customer token)',
          );
          return true;
        }());
      }
      return;
    }

    final role = parsedRole ?? AppRole.customer;
    state = SessionState(
      role: role,
      isAuthenticated: true,
      professionalShellActive: false,
      workspaceGateStatus: WorkspaceGateStatus.ready,
    );
    assert(() {
      debugPrint(
        '[PraniDoctor][auth] hydrateFromStorage: session restored '
        '(role=${role.name}, token present)',
      );
      return true;
    }());
  }

  Future<void> signInCustomer(String accessToken) async {
    state = SessionState(
      role: AppRole.customer,
      isAuthenticated: true,
      professionalShellActive: false,
      workspaceGateStatus: WorkspaceGateStatus.pending,
    );

    await ref.read(tokenStorageProvider).writeAccessToken(accessToken);
    if (!ref.mounted) return;

    final prefs = await SharedPreferences.getInstance();
    if (!ref.mounted) return;

    await prefs.setString(_lastRoleKey, AppRole.customer.name);
    if (!ref.mounted) return;

    assert(() {
      debugPrint(
        '[PraniDoctor][auth] customer sign-in: token persisted, '
        'workspace gate pending',
      );
      return true;
    }());
  }

  Future<void> applyResolvedWorkspace(DashboardContext ctx) async {
    final role = _mapDashboardToRole(ctx.dashboardType);
    final prefs = await SharedPreferences.getInstance();
    if (!ref.mounted) return;
    await prefs.setString(_lastRoleKey, role.name);
    if (!ref.mounted) return;
    state = state.copyWith(
      role: role,
      workspaceGateStatus: WorkspaceGateStatus.ready,
    );
    assert(() {
      debugPrint(
        '[PraniDoctor][auth] workspace resolved → role=${role.name}',
      );
      return true;
    }());
  }

  Future<void> abortWorkspaceGateToCustomerFallback() async {
    final prefs = await SharedPreferences.getInstance();
    if (!ref.mounted) return;
    await prefs.setString(_lastRoleKey, AppRole.customer.name);
    if (!ref.mounted) return;
    state = state.copyWith(
      role: AppRole.customer,
      workspaceGateStatus: WorkspaceGateStatus.ready,
    );
  }

  /// Silent refresh after cold start — aligns prefs/server without blocking splash.
  Future<void> refreshWorkspaceRoleFromApi(
    Future<DashboardContext> fetchContext,
  ) async {
    if (!state.isAuthenticated) return;
    try {
      final ctx = await fetchContext;
      if (!ref.mounted) return;
      await applyResolvedWorkspace(ctx);
    } catch (e, st) {
      assert(() {
        debugPrint('[PraniDoctor][auth] refreshWorkspaceRoleFromApi: $e\n$st');
        return true;
      }());
    }
  }

  Future<void> setRole(AppRole role) async {
    final prefs = await SharedPreferences.getInstance();
    if (!ref.mounted) return;
    await prefs.setString(_lastRoleKey, role.name);
    if (!ref.mounted) return;
    state = SessionState(
      role: role,
      isAuthenticated: false,
      professionalShellActive: role != AppRole.customer,
      workspaceGateStatus: WorkspaceGateStatus.idle,
    );
  }

  Future<void> signOut() async {
    await ref.read(tokenStorageProvider).clear();
    if (!ref.mounted) return;
    final prefs = await SharedPreferences.getInstance();
    if (!ref.mounted) return;
    await prefs.remove(_lastRoleKey);
    if (!ref.mounted) return;
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

/// Tracks whether dashboard-context role resolution has finished after JWT sign-in.
///
/// Cold restores ([SessionNotifier.hydrateFromStorage]) use [WorkspaceGateStatus.ready]
/// with the last persisted role — only interactive OTP/password flows start at [pending].
enum WorkspaceGateStatus {
  /// Logged out or no resolution needed (professional shell demo).
  idle,

  /// Authenticated with JWT; waiting for [WorkspaceGateScreen] + dashboard-context.
  pending,

  /// Role is synced from prefs or API.
  ready,

  /// Resolution failed after retries — fallback UX handled by [WorkspaceGateScreen].
  failed,
}

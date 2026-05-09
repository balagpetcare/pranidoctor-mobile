/// API and build-time configuration for Prani Doctor mobile.
///
/// Override base URL when running (e.g. Android emulator → host machine):
/// `flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000`
abstract final class AppConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000',
  );

  /// When `true`, AI technician workflow uses in-memory mock data (no HTTP).
  /// `flutter run --dart-define=USE_MOCK_TECHNICIAN_API=true`
  static const bool useMockTechnicianApi = bool.fromEnvironment(
    'USE_MOCK_TECHNICIAN_API',
    defaultValue: false,
  );

  /// Customer billing demo overlay when API omits `billing` (no-op unless enabled).
  /// `flutter run --dart-define=USE_MOCK_BILLING_UI=true`
  static const bool useMockBillingUi = bool.fromEnvironment(
    'USE_MOCK_BILLING_UI',
    defaultValue: false,
  );

  /// Knowledge hub sample posts when CMS/API unavailable or for offline demo.
  /// `flutter run --dart-define=USE_MOCK_KNOWLEDGE_API=true`
  static const bool useMockKnowledgeApi = bool.fromEnvironment(
    'USE_MOCK_KNOWLEDGE_API',
    defaultValue: false,
  );
}

/// API and build-time configuration for Prani Doctor mobile.
///
/// Android emulator → host machine on Windows/macOS/Linux:
/// `flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000`
///
/// Web / iOS simulator / desktop on same machine as API:
/// `flutter run --dart-define=API_BASE_URL=http://localhost:3000`
///
/// Local OTP bypass (see repository root `.env.example` for full example):
/// `flutter run --dart-define=APP_ENV=development --dart-define=ENABLE_DEV_OTP=true`
abstract final class AppConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000',
  );

  /// `production` | `development` (case-insensitive). OTP bypass requires `development`.
  static const String appEnv = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'production',
  );

  /// With [appEnv] `development`, enables offline test OTP when the API is unreachable.
  static const bool enableDevOtp = bool.fromEnvironment(
    'ENABLE_DEV_OTP',
    defaultValue: false,
  );

  /// Fixed code printed to debug console when [useDevOtpFallback] handles send/verify.
  static const String devOtpCode = '123456';

  /// Opaque dev-only bearer value (not a real JWT). Use only with unreachable APIs.
  static const String devCustomerAccessToken =
      'pranidoctor_dev_customer_access_v1';

  static bool get _isDevelopmentEnv =>
      appEnv.toLowerCase().trim() == 'development';

  /// `true` only when explicitly enabled **and** not production env (never ship OTP bypass).
  static bool get useDevOtpFallback => enableDevOtp && _isDevelopmentEnv;

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

  /// Profile `GET/PATCH /api/mobile/me` demo user when API is unavailable.
  /// `flutter run --dart-define=USE_MOCK_PROFILE_API=true`
  static const bool useMockProfileApi = bool.fromEnvironment(
    'USE_MOCK_PROFILE_API',
    defaultValue: false,
  );

  /// Optional E.164 / local digits for emergency tel: when API config is empty.
  /// `flutter run --dart-define=EMERGENCY_CONTACT_PHONE=+8801XXXXXXXXX`
  static const String emergencyContactPhone = String.fromEnvironment(
    'EMERGENCY_CONTACT_PHONE',
    defaultValue: '',
  );
}

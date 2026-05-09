/// API and build-time configuration for Prani Doctor mobile.
///
/// **Production defaults** (e.g. release APK with no `--dart-define` overrides):
/// `API_BASE_URL=https://pranidoctor.com`, `APP_ENV=production`, `ENABLE_DEV_OTP=false`.
///
/// **Android emulator** → API on the host machine:
/// `flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000 --dart-define=APP_ENV=development --dart-define=ENABLE_DEV_OTP=true`
///
/// **iOS simulator / desktop** on the same machine as the API:
/// `flutter run --dart-define=API_BASE_URL=http://localhost:3000 --dart-define=APP_ENV=development`
abstract final class AppConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://pranidoctor.com',
  );

  /// [apiBaseUrl] without trailing `/`, for Dio [BaseOptions.baseUrl].
  static String get resolvedApiBaseUrl {
    var u = apiBaseUrl.trim();
    while (u.endsWith('/')) {
      u = u.substring(0, u.length - 1);
    }
    return u;
  }

  /// `production` | `development` (case-insensitive). OTP bypass requires [isDevelopmentEnv].
  static const String appEnv = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'production',
  );

  /// With [isDevelopmentEnv], enables offline test OTP when the API is unreachable.
  static const bool enableDevOtp = bool.fromEnvironment(
    'ENABLE_DEV_OTP',
    defaultValue: false,
  );

  /// Fixed code used only when [useDevOtpFallback] handles send/verify (never log it).
  static const String devOtpCode = '123456';

  /// Opaque dev-only bearer value (not a real JWT). Use only with unreachable APIs.
  static const String devCustomerAccessToken =
      'pranidoctor_dev_customer_access_v1';

  static bool get isDevelopmentEnv =>
      appEnv.toLowerCase().trim() == 'development';

  /// `true` only when explicitly enabled **and** [isDevelopmentEnv] (never ship OTP bypass).
  static bool get useDevOtpFallback => enableDevOtp && isDevelopmentEnv;

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

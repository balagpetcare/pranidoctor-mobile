/// API and build-time configuration for Prani Doctor mobile.
///
/// Override base URL when running (e.g. Android emulator → host machine):
/// `flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000`
abstract final class AppConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000',
  );
}

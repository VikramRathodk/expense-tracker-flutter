/// Compile-time environment configuration.
///
/// Pass values via --dart-define when building:
///   flutter run  --dart-define=APP_ENV=dev  --dart-define=API_BASE_URL=http://10.0.2.2:8081
///   flutter build apk --dart-define=APP_ENV=prod --dart-define=API_BASE_URL=https://api.yourapp.com
class EnvConfig {
  const EnvConfig._();

  static const _env = String.fromEnvironment('APP_ENV', defaultValue: 'dev');
  static const _baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    // 10.0.2.2 = host machine from Android emulator; change for physical device
    defaultValue: 'http://10.0.2.2:8081',
  );

  static const String apiBaseUrl = '$_baseUrl/api/v1';

  static bool get isDev => _env == 'dev';
  static bool get isStaging => _env == 'staging';
  static bool get isProd => _env == 'prod';
}

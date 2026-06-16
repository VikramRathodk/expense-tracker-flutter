class EnvConfig {
  const EnvConfig._();

  // 10.0.2.2 maps to host machine localhost inside Android emulator
  static const String _baseUrl = 'http://10.0.2.2:8081';
  static const String _apiPath = '/api/v1';

  static const String apiBaseUrl = '$_baseUrl$_apiPath';
}

import 'package:dio/dio.dart';
import '../config/env_config.dart';
import 'auth_interceptor.dart';
import 'logging_interceptor.dart';

class DioClient {
  DioClient._();

  static Dio create({
    required TokenGetter getAccessToken,
    required TokenRefresher refreshAccessToken,
    required LogoutCallback onLogout,
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: EnvConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 60),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    dio.interceptors.addAll([
      AuthInterceptor(
        getAccessToken: getAccessToken,
        refreshAccessToken: refreshAccessToken,
        onLogout: onLogout,
      ),
      LoggingInterceptor(),
    ]);

    return dio;
  }

  /// Plain Dio with no auth interceptor — used for refresh calls
  static Dio plain() {
    return Dio(
      BaseOptions(
        baseUrl: EnvConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json'},
      ),
    )..interceptors.add(LoggingInterceptor());
  }
}

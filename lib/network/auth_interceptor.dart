import 'dart:async';
import 'package:dio/dio.dart';

typedef TokenGetter = Future<String?> Function();
typedef TokenRefresher = Future<String?> Function();
typedef LogoutCallback = Future<void> Function();

/// Attaches Bearer tokens to requests and handles automatic token refresh
/// on 401 responses. Uses a Completer lock so only one refresh runs even
/// when multiple requests fail concurrently.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required this.getAccessToken,
    required this.refreshAccessToken,
    required this.onLogout,
  });

  final TokenGetter getAccessToken;
  final TokenRefresher refreshAccessToken;
  final LogoutCallback onLogout;

  bool _isRefreshing = false;
  final List<Completer<String?>> _pendingRequests = [];

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 401) {
      handler.next(err);
      return;
    }

    // Auth endpoints don't need token refresh — pass the error straight through
    if (err.requestOptions.path.contains('/auth/login') ||
        err.requestOptions.path.contains('/auth/register')) {
      handler.reject(err);
      return;
    }

    // Avoid refresh loop on the refresh endpoint itself
    if (err.requestOptions.path.contains('/auth/refresh')) {
      await onLogout();
      handler.reject(err);
      return;
    }

    if (_isRefreshing) {
      final completer = Completer<String?>();
      _pendingRequests.add(completer);
      final newToken = await completer.future;
      if (newToken == null) {
        handler.reject(err);
        return;
      }
      handler.resolve(await _retry(err.requestOptions, newToken));
      return;
    }

    _isRefreshing = true;
    try {
      final newToken = await refreshAccessToken();
      if (newToken == null) {
        _completePending(null);
        await onLogout();
        handler.reject(err);
        return;
      }
      _completePending(newToken);
      handler.resolve(await _retry(err.requestOptions, newToken));
    } catch (_) {
      _completePending(null);
      await onLogout();
      handler.reject(err);
    } finally {
      _isRefreshing = false;
    }
  }

  void _completePending(String? token) {
    for (final c in _pendingRequests) {
      c.complete(token);
    }
    _pendingRequests.clear();
  }

  Future<Response<dynamic>> _retry(RequestOptions options, String token) {
    // Use a fresh Dio without this interceptor to avoid recursion
    final dio = Dio(BaseOptions(baseUrl: options.baseUrl));
    return dio.request<dynamic>(
      options.uri.toString(),
      data: options.data,
      queryParameters: options.queryParameters,
      options: Options(
        method: options.method,
        headers: {
          ...options.headers,
          'Authorization': 'Bearer $token',
        },
        responseType: options.responseType,
      ),
    );
  }
}

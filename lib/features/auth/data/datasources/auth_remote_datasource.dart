import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/auth_exception.dart';
import '../../domain/models/auth_response_model.dart';
import '../../domain/models/user_model.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource(this._dio);

  final Dio _dio;

  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiConstants.login,
        data: {'email': email, 'password': password},
      );
      return AuthResponseModel.fromJson(response.data!);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<AuthResponseModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiConstants.register,
        data: {'name': name, 'email': email, 'password': password},
      );
      return AuthResponseModel.fromJson(response.data!);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<String> refreshToken(String refreshToken) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiConstants.refresh,
        data: {'refreshToken': refreshToken},
      );
      return response.data!['accessToken'] as String;
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post<void>(ApiConstants.logout);
    } on DioException catch (e) {
      // Swallow 401 on logout — session may already be expired
      if (e.response?.statusCode != 401) throw _mapError(e);
    }
  }

  Future<UserModel> getMe() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(ApiConstants.me);
      final payload = _unwrap(response.data!);
      return UserModel.fromJson(payload);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<UserModel> updateProfile({required String name}) async {
    try {
      final response = await _dio.patch<Map<String, dynamic>>(
        ApiConstants.me,
        data: {'name': name},
      );
      final payload = _unwrap(response.data!);
      return UserModel.fromJson(payload);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _dio.patch<void>(
        ApiConstants.mePassword,
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
      );
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  AppException _mapError(DioException e) {
    final statusCode = e.response?.statusCode;
    final data = e.response?.data;
    final message = _extractMessage(data) ??
        e.message ??
        'An unexpected error occurred.';

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return ServerException(
        message: 'Request timed out. Please try again.',
        statusCode: statusCode,
      );
    }

    if (e.type == DioExceptionType.connectionError) {
      return ServerException(
        message: 'Unable to connect. Check your internet connection.',
        statusCode: statusCode,
      );
    }

    return switch (statusCode) {
      400 => ValidationException(
          message: message,
          fieldErrors: _extractFieldErrors(data),
        ),
      401 => UnauthorizedException(message: message),
      403 => ForbiddenException(message: message),
      404 => NotFoundException(message: message),
      409 => ConflictException(message: message),
      _ => ServerException(message: message, statusCode: statusCode),
    };
  }

  /// Unwraps `{ status, message, data: {...} }` envelope if present.
  Map<String, dynamic> _unwrap(Map<String, dynamic> json) =>
      json['data'] as Map<String, dynamic>? ?? json;

  String? _extractMessage(dynamic data) {
    if (data is Map) return data['message'] as String?;
    return null;
  }

  Map<String, String>? _extractFieldErrors(dynamic data) {
    if (data is! Map) return null;
    final errors = data['fieldErrors'] ?? data['errors'];
    if (errors is! Map) return null;
    return errors.map(
      (k, v) => MapEntry(k.toString(), v.toString()),
    );
  }
}

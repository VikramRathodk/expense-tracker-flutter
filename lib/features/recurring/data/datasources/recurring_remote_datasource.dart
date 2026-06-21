import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/auth_exception.dart';
import '../../domain/models/recurring_expense_model.dart';

class RecurringRemoteDataSource {
  RecurringRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<RecurringExpenseModel>> getRecurring() async {
    try {
      final response =
          await _dio.get<List<dynamic>>(ApiConstants.recurring);
      return (response.data ?? [])
          .map((e) =>
              RecurringExpenseModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<RecurringExpenseModel> createRecurring(
      CreateRecurringRequest request) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiConstants.recurring,
        data: request.toJson(),
      );
      return RecurringExpenseModel.fromJson(response.data!);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<RecurringExpenseModel> updateRecurring(
      int id, CreateRecurringRequest request) async {
    try {
      final response = await _dio.put<Map<String, dynamic>>(
        '${ApiConstants.recurring}/$id',
        data: request.toJson(),
      );
      return RecurringExpenseModel.fromJson(response.data!);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<RecurringExpenseModel> toggleRecurring(int id) async {
    try {
      final response = await _dio.patch<Map<String, dynamic>>(
        '${ApiConstants.recurring}/$id/toggle',
      );
      return RecurringExpenseModel.fromJson(response.data!);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<void> deleteRecurring(int id) async {
    try {
      await _dio.delete<void>('${ApiConstants.recurring}/$id');
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  AppException _mapError(DioException e) {
    final statusCode = e.response?.statusCode;
    final data = e.response?.data;
    final message = (data is Map ? data['message'] as String? : null) ??
        e.message ??
        'An unexpected error occurred.';

    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
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

  Map<String, String>? _extractFieldErrors(dynamic data) {
    if (data is! Map) return null;
    final errors = data['fieldErrors'] ?? data['errors'];
    if (errors is! Map) return null;
    return errors.map((k, v) => MapEntry(k.toString(), v.toString()));
  }
}

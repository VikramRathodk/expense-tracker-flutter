import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/auth_exception.dart';
import '../../domain/models/budget_model.dart';

class BudgetRemoteDataSource {
  BudgetRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<BudgetModel>> getBudgets({String? period}) async {
    try {
      final response = await _dio.get<List<dynamic>>(
        ApiConstants.budgets,
        queryParameters: period != null ? {'period': period} : null,
      );
      return (response.data ?? [])
          .map((e) => BudgetModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<BudgetModel> createBudget(CreateBudgetRequest request) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiConstants.budgets,
        data: request.toJson(),
      );
      return BudgetModel.fromJson(response.data!);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<BudgetModel> updateBudget(
      int id, CreateBudgetRequest request) async {
    try {
      final response = await _dio.put<Map<String, dynamic>>(
        '${ApiConstants.budgets}/$id',
        data: request.toJson(),
      );
      return BudgetModel.fromJson(response.data!);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<void> deleteBudget(int id) async {
    try {
      await _dio.delete<void>('${ApiConstants.budgets}/$id');
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

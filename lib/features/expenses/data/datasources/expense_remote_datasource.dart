import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/auth_exception.dart';
import '../../../../network/page_response.dart';
import '../../domain/models/expense_model.dart';

class ExpenseRemoteDataSource {
  ExpenseRemoteDataSource(this._dio);

  final Dio _dio;

  Future<PageResponse<ExpenseModel>> getExpenses({
    required int page,
    required int size,
    int? categoryId,
    String? startDate,
    String? endDate,
    String? search,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'size': size,
        'sort': 'date,desc',
        'categoryId': ?categoryId,
        'startDate': ?startDate,
        'endDate': ?endDate,
        if (search != null && search.isNotEmpty) 'search': search,
      };

      final endpoint = (search != null && search.isNotEmpty)
          ? ApiConstants.expensesSearch
          : (categoryId != null || startDate != null || endDate != null)
              ? ApiConstants.expensesFilter
              : ApiConstants.expenses;

      final response = await _dio.get<Map<String, dynamic>>(
        endpoint,
        queryParameters: queryParams,
      );
      return PageResponse.fromJson(
        response.data!,
        (e) => ExpenseModel.fromJson(e as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<ExpenseModel> getExpenseById(int id) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '${ApiConstants.expenses}/$id',
      );
      return ExpenseModel.fromJson(response.data!);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<ExpenseModel> createExpense(CreateExpenseRequest request) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiConstants.expenses,
        data: request.toJson(),
      );
      return ExpenseModel.fromJson(response.data!);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<ExpenseModel> updateExpense(
    int id,
    CreateExpenseRequest request,
  ) async {
    try {
      final response = await _dio.put<Map<String, dynamic>>(
        '${ApiConstants.expenses}/$id',
        data: request.toJson(),
      );
      return ExpenseModel.fromJson(response.data!);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<void> deleteExpense(int id) async {
    try {
      await _dio.delete<void>('${ApiConstants.expenses}/$id');
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

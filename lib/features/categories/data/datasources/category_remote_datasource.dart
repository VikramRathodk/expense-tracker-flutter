import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/auth_exception.dart';
import '../../domain/models/category_model.dart';

class CategoryRemoteDataSource {
  CategoryRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(ApiConstants.categories);
      final list = response.data?['data'] as List<dynamic>? ?? [];
      return list
          .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<CategoryModel> createCategory({
    required String name,
    required String icon,
    required String color,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiConstants.categories,
        data: {'name': name, 'icon': icon, 'color': color},
      );
      final body = response.data!;
      return CategoryModel.fromJson(
          body.containsKey('data') ? body['data'] as Map<String, dynamic> : body);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<CategoryModel> updateCategory({
    required int id,
    required String name,
    required String icon,
    required String color,
  }) async {
    try {
      final response = await _dio.patch<Map<String, dynamic>>(
        '${ApiConstants.categories}/$id',
        data: {'name': name, 'icon': icon, 'color': color},
      );
      final body = response.data!;
      return CategoryModel.fromJson(
          body.containsKey('data') ? body['data'] as Map<String, dynamic> : body);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<void> deleteCategory({required int id}) async {
    try {
      await _dio.delete<void>('${ApiConstants.categories}/$id');
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
      401 => UnauthorizedException(message: message),
      403 => ForbiddenException(message: message),
      _ => ServerException(message: message, statusCode: statusCode),
    };
  }
}

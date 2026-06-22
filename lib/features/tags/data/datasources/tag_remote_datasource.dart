import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/auth_exception.dart';
import '../../domain/models/tag_model.dart';

class TagRemoteDataSource {
  TagRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<TagModel>> getTags() async {
    try {
      final response = await _dio.get<List<dynamic>>(ApiConstants.tags);
      return (response.data ?? []).map(TagModel.fromJson).toList();
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<void> renameTag({
    required String name,
    required String newName,
  }) async {
    try {
      await _dio.patch<void>(
        '${ApiConstants.tags}/${Uri.encodeComponent(name)}',
        data: {'newName': newName},
      );
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<void> deleteTag({required String name}) async {
    try {
      await _dio.delete<void>(
        '${ApiConstants.tags}/${Uri.encodeComponent(name)}',
      );
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
      404 => NotFoundException(message: message),
      409 => ConflictException(message: message),
      _ => ServerException(message: message, statusCode: statusCode),
    };
  }
}
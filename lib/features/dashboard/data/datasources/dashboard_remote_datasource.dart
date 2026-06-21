import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/auth_exception.dart';
import '../../domain/models/dashboard_summary_model.dart';

class DashboardRemoteDataSource {
  DashboardRemoteDataSource(this._dio);

  final Dio _dio;

  Future<DashboardSummaryModel> getSummary({String? period}) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiConstants.dashboard,
        queryParameters: period != null ? {'period': period} : null,
      );
      return DashboardSummaryModel.fromJson(response.data!);
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

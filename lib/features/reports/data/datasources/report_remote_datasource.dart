import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../domain/models/report_model.dart';

class ReportRemoteDataSource {
  const ReportRemoteDataSource(this._dio);

  final Dio _dio;

  Future<ReportSummary> getSummary({
    required String startDate,
    required String endDate,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiConstants.reportsSummary,
      queryParameters: {'startDate': startDate, 'endDate': endDate},
    );
    return ReportSummary.fromJson(response.data!);
  }

  Future<List<ReportCategoryBreakdown>> getCategoryBreakdown({
    required String startDate,
    required String endDate,
  }) async {
    final response = await _dio.get<List<dynamic>>(
      ApiConstants.reportsCategoryWise,
      queryParameters: {'startDate': startDate, 'endDate': endDate},
    );
    return (response.data ?? [])
        .map((e) =>
            ReportCategoryBreakdown.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<ReportMonthlyTrend>> getTrends({int months = 6}) async {
    final response = await _dio.get<List<dynamic>>(
      ApiConstants.reportsTrends,
      queryParameters: {'months': months},
    );
    return (response.data ?? [])
        .map((e) => ReportMonthlyTrend.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<String> exportReport({
    required String startDate,
    required String endDate,
    String format = 'csv',
  }) async {
    final response = await _dio.get<String>(
      ApiConstants.reportsExport,
      queryParameters: {
        'startDate': startDate,
        'endDate': endDate,
        'format': format,
      },
      options: Options(responseType: ResponseType.plain),
    );
    return response.data ?? '';
  }
}
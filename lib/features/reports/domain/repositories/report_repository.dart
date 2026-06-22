import '../models/report_model.dart';

abstract class ReportRepository {
  Future<ReportSummary> getSummary({
    required String startDate,
    required String endDate,
  });

  Future<List<ReportCategoryBreakdown>> getCategoryBreakdown({
    required String startDate,
    required String endDate,
  });

  Future<List<ReportMonthlyTrend>> getTrends({int months = 6});

  Future<String> exportReport({
    required String startDate,
    required String endDate,
    String format = 'csv',
  });
}
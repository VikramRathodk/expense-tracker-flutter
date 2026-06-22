import '../../domain/models/report_model.dart';
import '../../domain/repositories/report_repository.dart';
import '../datasources/report_remote_datasource.dart';

class ReportRepositoryImpl implements ReportRepository {
  const ReportRepositoryImpl(this._dataSource);

  final ReportRemoteDataSource _dataSource;

  @override
  Future<ReportSummary> getSummary({
    required String startDate,
    required String endDate,
  }) =>
      _dataSource.getSummary(startDate: startDate, endDate: endDate);

  @override
  Future<List<ReportCategoryBreakdown>> getCategoryBreakdown({
    required String startDate,
    required String endDate,
  }) =>
      _dataSource.getCategoryBreakdown(startDate: startDate, endDate: endDate);

  @override
  Future<List<ReportMonthlyTrend>> getTrends({int months = 6}) =>
      _dataSource.getTrends(months: months);

  @override
  Future<String> exportReport({
    required String startDate,
    required String endDate,
    String format = 'csv',
  }) =>
      _dataSource.exportReport(
          startDate: startDate, endDate: endDate, format: format);
}
import '../../domain/models/dashboard_summary_model.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_remote_datasource.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  DashboardRepositoryImpl(this._dataSource);

  final DashboardRemoteDataSource _dataSource;

  @override
  Future<DashboardSummaryModel> getSummary({String? period}) {
    return _dataSource.getSummary(period: period);
  }
}

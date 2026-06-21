import '../models/dashboard_summary_model.dart';

abstract class DashboardRepository {
  Future<DashboardSummaryModel> getSummary({String? period});
}

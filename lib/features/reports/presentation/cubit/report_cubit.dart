import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/models/report_model.dart';
import '../../domain/repositories/report_repository.dart';

part 'report_state.dart';

class ReportCubit extends Cubit<ReportState> {
  ReportCubit(this._repository)
      : super(ReportInitial(filter: ReportFilter.defaultFilter()));

  final ReportRepository _repository;

  Future<void> load() async {
    final filter = _currentFilter;
    emit(ReportLoading(filter: filter));
    try {
      final results = await Future.wait([
        _repository.getSummary(
          startDate: filter.startDateStr,
          endDate: filter.endDateStr,
        ),
        _repository.getCategoryBreakdown(
          startDate: filter.startDateStr,
          endDate: filter.endDateStr,
        ),
        _repository.getTrends(months: _trendsMonths(filter.period)),
      ]);
      emit(ReportLoaded(
        data: ReportData(
          summary: results[0] as ReportSummary,
          categoryBreakdown:
              results[1] as List<ReportCategoryBreakdown>,
          monthlyTrend: results[2] as List<ReportMonthlyTrend>,
          filter: filter,
        ),
      ));
    } catch (e) {
      emit(ReportError(message: e.toString(), filter: filter));
    }
  }

  Future<void> changeFilter(ReportPeriod period) async {
    final newFilter = ReportFilter.forPeriod(period);
    emit(ReportLoading(filter: newFilter));
    try {
      final results = await Future.wait([
        _repository.getSummary(
          startDate: newFilter.startDateStr,
          endDate: newFilter.endDateStr,
        ),
        _repository.getCategoryBreakdown(
          startDate: newFilter.startDateStr,
          endDate: newFilter.endDateStr,
        ),
        _repository.getTrends(months: _trendsMonths(period)),
      ]);
      emit(ReportLoaded(
        data: ReportData(
          summary: results[0] as ReportSummary,
          categoryBreakdown:
              results[1] as List<ReportCategoryBreakdown>,
          monthlyTrend: results[2] as List<ReportMonthlyTrend>,
          filter: newFilter,
        ),
      ));
    } catch (e) {
      emit(ReportError(message: e.toString(), filter: newFilter));
    }
  }

  Future<void> exportReport(String format) async {
    final filter = _currentFilter;
    emit(ReportExporting(
        data: state is ReportLoaded ? (state as ReportLoaded).data : null));
    try {
      await _repository.exportReport(
        startDate: filter.startDateStr,
        endDate: filter.endDateStr,
        format: format,
      );
      final current = state;
      if (current is ReportExporting && current.data != null) {
        emit(ReportLoaded(data: current.data!));
      } else {
        await load();
      }
    } catch (e) {
      if (state is ReportExporting) {
        final d = (state as ReportExporting).data;
        if (d != null) {
          emit(ReportLoaded(data: d));
        } else {
          emit(ReportError(message: e.toString(), filter: filter));
        }
      }
    }
  }

  ReportFilter get _currentFilter => switch (state) {
        ReportInitial(:final filter) => filter,
        ReportLoading(:final filter) => filter,
        ReportLoaded(:final data) => data.filter,
        ReportError(:final filter) => filter,
        ReportExporting() => ReportFilter.defaultFilter(),
      };

  int _trendsMonths(ReportPeriod period) => switch (period) {
        ReportPeriod.thisMonth => 6,
        ReportPeriod.lastMonth => 6,
        ReportPeriod.last3Months => 6,
        ReportPeriod.last6Months => 6,
        ReportPeriod.thisYear => 12,
      };
}
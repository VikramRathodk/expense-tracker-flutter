import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/models/dashboard_summary_model.dart';
import '../../domain/repositories/dashboard_repository.dart';

// ─── States ──────────────────────────────────────────────────────────────────

sealed class DashboardState {}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  DashboardLoaded(this.summary);
  final DashboardSummaryModel summary;
}

class DashboardError extends DashboardState {
  DashboardError(this.message);
  final String message;
}

// ─── Cubit ───────────────────────────────────────────────────────────────────

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit(this._repository) : super(DashboardInitial());

  final DashboardRepository _repository;
  String? _currentPeriod;

  Future<void> loadSummary({String? period}) async {
    _currentPeriod = period;
    emit(DashboardLoading());
    try {
      final summary = await _repository.getSummary(period: period);
      emit(DashboardLoaded(summary));
    } catch (e) {
      emit(DashboardError(_friendlyMessage(e)));
    }
  }

  Future<void> refresh() => loadSummary(period: _currentPeriod);

  String _friendlyMessage(Object e) {
    final str = e.toString();
    if (str.contains('connect') || str.contains('network')) {
      return 'Unable to load. Check your internet connection.';
    }
    return 'Failed to load dashboard. Please try again.';
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../domain/models/budget_model.dart';
import '../../domain/repositories/budget_repository.dart';

// ─── States ──────────────────────────────────────────────────────────────────

sealed class BudgetListState {}

class BudgetListInitial extends BudgetListState {}

class BudgetListLoading extends BudgetListState {}

class BudgetListLoaded extends BudgetListState {
  BudgetListLoaded(this.budgets, this.period);
  final List<BudgetModel> budgets;
  final String period;

  BudgetModel? get overallBudget =>
      budgets.cast<BudgetModel?>().firstWhere(
            (b) => b!.isOverall,
            orElse: () => null,
          );

  List<BudgetModel> get categoryBudgets =>
      budgets.where((b) => !b.isOverall).toList();
}

class BudgetListError extends BudgetListState {
  BudgetListError(this.message);
  final String message;
}

// ─── Cubit ───────────────────────────────────────────────────────────────────

class BudgetListCubit extends Cubit<BudgetListState> {
  BudgetListCubit(this._repository) : super(BudgetListInitial());

  final BudgetRepository _repository;
  late String _currentPeriod = DateFormat('yyyy-MM').format(DateTime.now());

  String get currentPeriod => _currentPeriod;

  Future<void> loadBudgets({String? period}) async {
    _currentPeriod = period ?? _currentPeriod;
    emit(BudgetListLoading());
    try {
      final budgets = await _repository.getBudgets(period: _currentPeriod);
      emit(BudgetListLoaded(budgets, _currentPeriod));
    } catch (e) {
      emit(BudgetListError(_friendlyMessage(e)));
    }
  }

  Future<void> refresh() => loadBudgets(period: _currentPeriod);

  Future<void> deleteBudget(int id) async {
    final current = state;
    if (current is! BudgetListLoaded) return;

    // Optimistic removal
    emit(BudgetListLoaded(
      current.budgets.where((b) => b.id != id).toList(),
      current.period,
    ));

    try {
      await _repository.deleteBudget(id);
    } catch (_) {
      // Restore on failure
      emit(current);
      rethrow;
    }
  }

  String _friendlyMessage(Object e) {
    final str = e.toString();
    if (str.contains('connect') || str.contains('network')) {
      return 'Unable to load budgets. Check your internet connection.';
    }
    return 'Failed to load budgets. Please try again.';
  }
}

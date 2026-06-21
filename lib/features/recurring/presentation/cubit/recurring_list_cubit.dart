import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/models/recurring_expense_model.dart';
import '../../domain/repositories/recurring_repository.dart';

// ─── States ──────────────────────────────────────────────────────────────────

sealed class RecurringListState {}

class RecurringListInitial extends RecurringListState {}

class RecurringListLoading extends RecurringListState {}

class RecurringListLoaded extends RecurringListState {
  RecurringListLoaded(this.items);
  final List<RecurringExpenseModel> items;

  List<RecurringExpenseModel> get active =>
      items.where((i) => i.isActive).toList();

  List<RecurringExpenseModel> get paused =>
      items.where((i) => !i.isActive).toList();
}

class RecurringListError extends RecurringListState {
  RecurringListError(this.message);
  final String message;
}

// ─── Cubit ───────────────────────────────────────────────────────────────────

class RecurringListCubit extends Cubit<RecurringListState> {
  RecurringListCubit(this._repository) : super(RecurringListInitial());

  final RecurringRepository _repository;

  Future<void> loadRecurring() async {
    emit(RecurringListLoading());
    try {
      final items = await _repository.getRecurring();
      emit(RecurringListLoaded(items));
    } catch (e) {
      emit(RecurringListError(_friendlyMessage(e)));
    }
  }

  Future<void> refresh() => loadRecurring();

  Future<void> toggle(int id) async {
    final current = state;
    if (current is! RecurringListLoaded) return;
    try {
      final updated = await _repository.toggleRecurring(id);
      final newItems = current.items
          .map((i) => i.id == updated.id ? updated : i)
          .toList();
      emit(RecurringListLoaded(newItems));
    } catch (e) {
      emit(current);
      rethrow;
    }
  }

  Future<void> delete(int id) async {
    final current = state;
    if (current is! RecurringListLoaded) return;

    // Optimistic removal
    emit(RecurringListLoaded(
        current.items.where((i) => i.id != id).toList()));

    try {
      await _repository.deleteRecurring(id);
    } catch (_) {
      emit(current);
      rethrow;
    }
  }

  String _friendlyMessage(Object e) {
    final str = e.toString();
    if (str.contains('connect') || str.contains('network')) {
      return 'Unable to load. Check your internet connection.';
    }
    return 'Failed to load recurring expenses. Please try again.';
  }
}

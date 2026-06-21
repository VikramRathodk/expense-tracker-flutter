import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/models/budget_model.dart';
import '../../domain/repositories/budget_repository.dart';

// ─── States ──────────────────────────────────────────────────────────────────

sealed class BudgetFormState {}

class BudgetFormInitial extends BudgetFormState {}

class BudgetFormSubmitting extends BudgetFormState {}

class BudgetFormSuccess extends BudgetFormState {
  BudgetFormSuccess(this.budget, {this.isEdit = false});
  final BudgetModel budget;
  final bool isEdit;
}

class BudgetFormError extends BudgetFormState {
  BudgetFormError(this.message);
  final String message;
}

// ─── Cubit ───────────────────────────────────────────────────────────────────

class BudgetFormCubit extends Cubit<BudgetFormState> {
  BudgetFormCubit(this._repository) : super(BudgetFormInitial());

  final BudgetRepository _repository;

  Future<void> createBudget(CreateBudgetRequest request) async {
    emit(BudgetFormSubmitting());
    try {
      final budget = await _repository.createBudget(request);
      emit(BudgetFormSuccess(budget));
    } catch (e) {
      emit(BudgetFormError(_friendlyMessage(e)));
    }
  }

  Future<void> updateBudget(int id, CreateBudgetRequest request) async {
    emit(BudgetFormSubmitting());
    try {
      final budget = await _repository.updateBudget(id, request);
      emit(BudgetFormSuccess(budget, isEdit: true));
    } catch (e) {
      emit(BudgetFormError(_friendlyMessage(e)));
    }
  }

  void reset() => emit(BudgetFormInitial());

  String _friendlyMessage(Object e) {
    final str = e.toString();
    final match = RegExp(r'AppException\(\d+\): (.+)').firstMatch(str);
    return match?.group(1) ?? 'An error occurred. Please try again.';
  }
}

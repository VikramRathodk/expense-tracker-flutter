import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/models/expense_model.dart';
import '../../domain/repositories/expense_repository.dart';

// ─── States ──────────────────────────────────────────────────────────────────

sealed class ExpenseFormState {}

class ExpenseFormInitial extends ExpenseFormState {}

class ExpenseFormSubmitting extends ExpenseFormState {}

class ExpenseFormSuccess extends ExpenseFormState {
  ExpenseFormSuccess(this.expense, {this.isEdit = false});
  final ExpenseModel expense;
  final bool isEdit;
}

class ExpenseFormError extends ExpenseFormState {
  ExpenseFormError(this.message, {this.fieldErrors});
  final String message;
  final Map<String, String>? fieldErrors;
}

// ─── Cubit ───────────────────────────────────────────────────────────────────

class ExpenseFormCubit extends Cubit<ExpenseFormState> {
  ExpenseFormCubit(this._repository) : super(ExpenseFormInitial());

  final ExpenseRepository _repository;

  Future<void> createExpense(CreateExpenseRequest request) async {
    emit(ExpenseFormSubmitting());
    try {
      final expense = await _repository.createExpense(request);
      emit(ExpenseFormSuccess(expense));
    } catch (e) {
      emit(ExpenseFormError(_friendlyMessage(e)));
    }
  }

  Future<void> updateExpense(int id, CreateExpenseRequest request) async {
    emit(ExpenseFormSubmitting());
    try {
      final expense = await _repository.updateExpense(id, request);
      emit(ExpenseFormSuccess(expense, isEdit: true));
    } catch (e) {
      emit(ExpenseFormError(_friendlyMessage(e)));
    }
  }

  void resetToInitial() => emit(ExpenseFormInitial());

  String _friendlyMessage(Object e) {
    final str = e.toString();
    if (str.contains('AppException')) {
      final match = RegExp(r'AppException\(\d+\): (.+)').firstMatch(str);
      return match?.group(1) ?? 'An error occurred. Please try again.';
    }
    return 'An error occurred. Please try again.';
  }
}

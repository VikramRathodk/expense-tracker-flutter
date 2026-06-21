import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/models/recurring_expense_model.dart';
import '../../domain/repositories/recurring_repository.dart';

// ─── States ──────────────────────────────────────────────────────────────────

sealed class RecurringFormState {}

class RecurringFormInitial extends RecurringFormState {}

class RecurringFormSubmitting extends RecurringFormState {}

class RecurringFormSuccess extends RecurringFormState {
  RecurringFormSuccess(this.item, {this.isEdit = false});
  final RecurringExpenseModel item;
  final bool isEdit;
}

class RecurringFormError extends RecurringFormState {
  RecurringFormError(this.message);
  final String message;
}

// ─── Cubit ───────────────────────────────────────────────────────────────────

class RecurringFormCubit extends Cubit<RecurringFormState> {
  RecurringFormCubit(this._repository) : super(RecurringFormInitial());

  final RecurringRepository _repository;

  Future<void> createRecurring(CreateRecurringRequest request) async {
    emit(RecurringFormSubmitting());
    try {
      final item = await _repository.createRecurring(request);
      emit(RecurringFormSuccess(item));
    } catch (e) {
      emit(RecurringFormError(_friendlyMessage(e)));
    }
  }

  Future<void> updateRecurring(int id, CreateRecurringRequest request) async {
    emit(RecurringFormSubmitting());
    try {
      final item = await _repository.updateRecurring(id, request);
      emit(RecurringFormSuccess(item, isEdit: true));
    } catch (e) {
      emit(RecurringFormError(_friendlyMessage(e)));
    }
  }

  void reset() => emit(RecurringFormInitial());

  String _friendlyMessage(Object e) {
    final str = e.toString();
    final match = RegExp(r'AppException\(\d+\): (.+)').firstMatch(str);
    return match?.group(1) ?? 'An error occurred. Please try again.';
  }
}

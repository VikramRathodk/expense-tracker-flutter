import '../models/recurring_expense_model.dart';

abstract class RecurringRepository {
  Future<List<RecurringExpenseModel>> getRecurring();
  Future<RecurringExpenseModel> createRecurring(CreateRecurringRequest request);
  Future<RecurringExpenseModel> updateRecurring(
      int id, CreateRecurringRequest request);
  Future<RecurringExpenseModel> toggleRecurring(int id);
  Future<void> deleteRecurring(int id);
}

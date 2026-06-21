import '../../../../network/page_response.dart';
import '../models/expense_model.dart';

abstract class ExpenseRepository {
  Future<PageResponse<ExpenseModel>> getExpenses({
    required int page,
    required int size,
    int? categoryId,
    String? startDate,
    String? endDate,
    String? search,
  });

  Future<ExpenseModel> getExpenseById(int id);

  Future<ExpenseModel> createExpense(CreateExpenseRequest request);

  Future<ExpenseModel> updateExpense(int id, CreateExpenseRequest request);

  Future<void> deleteExpense(int id);
}

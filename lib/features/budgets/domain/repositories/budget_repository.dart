import '../models/budget_model.dart';

abstract class BudgetRepository {
  Future<List<BudgetModel>> getBudgets({String? period});
  Future<BudgetModel> createBudget(CreateBudgetRequest request);
  Future<BudgetModel> updateBudget(int id, CreateBudgetRequest request);
  Future<void> deleteBudget(int id);
}

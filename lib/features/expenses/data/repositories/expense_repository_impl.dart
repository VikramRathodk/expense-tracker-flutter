import '../../../../network/page_response.dart';
import '../../domain/models/expense_model.dart';
import '../../domain/repositories/expense_repository.dart';
import '../datasources/expense_remote_datasource.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  ExpenseRepositoryImpl(this._dataSource);

  final ExpenseRemoteDataSource _dataSource;

  @override
  Future<PageResponse<ExpenseModel>> getExpenses({
    required int page,
    required int size,
    int? categoryId,
    String? startDate,
    String? endDate,
    String? search,
  }) {
    return _dataSource.getExpenses(
      page: page,
      size: size,
      categoryId: categoryId,
      startDate: startDate,
      endDate: endDate,
      search: search,
    );
  }

  @override
  Future<ExpenseModel> getExpenseById(int id) {
    return _dataSource.getExpenseById(id);
  }

  @override
  Future<ExpenseModel> createExpense(CreateExpenseRequest request) {
    return _dataSource.createExpense(request);
  }

  @override
  Future<ExpenseModel> updateExpense(int id, CreateExpenseRequest request) {
    return _dataSource.updateExpense(id, request);
  }

  @override
  Future<void> deleteExpense(int id) {
    return _dataSource.deleteExpense(id);
  }
}

import '../../domain/models/budget_model.dart';
import '../../domain/repositories/budget_repository.dart';
import '../datasources/budget_remote_datasource.dart';

class BudgetRepositoryImpl implements BudgetRepository {
  BudgetRepositoryImpl(this._dataSource);

  final BudgetRemoteDataSource _dataSource;

  @override
  Future<List<BudgetModel>> getBudgets({String? period}) =>
      _dataSource.getBudgets(period: period);

  @override
  Future<BudgetModel> createBudget(CreateBudgetRequest request) =>
      _dataSource.createBudget(request);

  @override
  Future<BudgetModel> updateBudget(int id, CreateBudgetRequest request) =>
      _dataSource.updateBudget(id, request);

  @override
  Future<void> deleteBudget(int id) => _dataSource.deleteBudget(id);
}

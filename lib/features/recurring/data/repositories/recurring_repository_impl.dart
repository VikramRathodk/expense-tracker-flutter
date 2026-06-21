import '../../domain/models/recurring_expense_model.dart';
import '../../domain/repositories/recurring_repository.dart';
import '../datasources/recurring_remote_datasource.dart';

class RecurringRepositoryImpl implements RecurringRepository {
  RecurringRepositoryImpl(this._dataSource);

  final RecurringRemoteDataSource _dataSource;

  @override
  Future<List<RecurringExpenseModel>> getRecurring() =>
      _dataSource.getRecurring();

  @override
  Future<RecurringExpenseModel> createRecurring(
          CreateRecurringRequest request) =>
      _dataSource.createRecurring(request);

  @override
  Future<RecurringExpenseModel> updateRecurring(
          int id, CreateRecurringRequest request) =>
      _dataSource.updateRecurring(id, request);

  @override
  Future<RecurringExpenseModel> toggleRecurring(int id) =>
      _dataSource.toggleRecurring(id);

  @override
  Future<void> deleteRecurring(int id) => _dataSource.deleteRecurring(id);
}

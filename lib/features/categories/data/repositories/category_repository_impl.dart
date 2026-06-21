import '../../domain/models/category_model.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/category_remote_datasource.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  CategoryRepositoryImpl(this._dataSource);

  final CategoryRemoteDataSource _dataSource;

  @override
  Future<List<CategoryModel>> getCategories() {
    return _dataSource.getCategories();
  }
}

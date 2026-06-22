import '../../domain/models/category_model.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/category_remote_datasource.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  CategoryRepositoryImpl(this._dataSource);

  final CategoryRemoteDataSource _dataSource;

  @override
  Future<List<CategoryModel>> getCategories() => _dataSource.getCategories();

  @override
  Future<CategoryModel> createCategory({
    required String name,
    required String icon,
    required String color,
  }) =>
      _dataSource.createCategory(name: name, icon: icon, color: color);

  @override
  Future<CategoryModel> updateCategory({
    required int id,
    required String name,
    required String icon,
    required String color,
  }) =>
      _dataSource.updateCategory(id: id, name: name, icon: icon, color: color);

  @override
  Future<void> deleteCategory({required int id}) =>
      _dataSource.deleteCategory(id: id);
}

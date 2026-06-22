import '../models/category_model.dart';

abstract class CategoryRepository {
  Future<List<CategoryModel>> getCategories();

  Future<CategoryModel> createCategory({
    required String name,
    required String icon,
    required String color,
  });

  Future<CategoryModel> updateCategory({
    required int id,
    required String name,
    required String icon,
    required String color,
  });

  Future<void> deleteCategory({required int id});
}

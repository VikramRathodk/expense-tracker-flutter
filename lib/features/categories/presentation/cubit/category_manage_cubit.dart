import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/app_exception.dart';
import '../../domain/models/category_model.dart';
import '../../domain/repositories/category_repository.dart';

// ─── States ──────────────────────────────────────────────────────────────────

sealed class CategoryManageState {}

class CategoryManageInitial extends CategoryManageState {}

class CategoryManageLoading extends CategoryManageState {}

class CategoryManageLoaded extends CategoryManageState {
  CategoryManageLoaded(this.categories);
  final List<CategoryModel> categories;
}

class CategoryManageError extends CategoryManageState {
  CategoryManageError(this.message, {this.categories = const []});
  final String message;
  final List<CategoryModel> categories;
}

// ─── Cubit ───────────────────────────────────────────────────────────────────

class CategoryManageCubit extends Cubit<CategoryManageState> {
  CategoryManageCubit(this._repository) : super(CategoryManageInitial());

  final CategoryRepository _repository;

  List<CategoryModel> get _current => switch (state) {
        CategoryManageLoaded s => s.categories,
        CategoryManageError s => s.categories,
        _ => [],
      };

  Future<void> load() async {
    emit(CategoryManageLoading());
    try {
      emit(CategoryManageLoaded(await _repository.getCategories()));
    } on AppException catch (e) {
      emit(CategoryManageError(e.message));
    } catch (_) {
      emit(CategoryManageError('Failed to load categories.'));
    }
  }

  Future<void> refresh() => load();

  Future<void> createCategory({
    required String name,
    required String icon,
    required String color,
  }) async {
    final prev = _current;
    emit(CategoryManageLoading());
    try {
      await _repository.createCategory(name: name, icon: icon, color: color);
      emit(CategoryManageLoaded(await _repository.getCategories()));
    } on AppException catch (e) {
      emit(CategoryManageError(e.message, categories: prev));
    } catch (_) {
      emit(CategoryManageError('Failed to create category.', categories: prev));
    }
  }

  Future<void> updateCategory({
    required int id,
    required String name,
    required String icon,
    required String color,
  }) async {
    final prev = _current;
    emit(CategoryManageLoading());
    try {
      await _repository.updateCategory(
          id: id, name: name, icon: icon, color: color);
      emit(CategoryManageLoaded(await _repository.getCategories()));
    } on AppException catch (e) {
      emit(CategoryManageError(e.message, categories: prev));
    } catch (_) {
      emit(CategoryManageError('Failed to update category.', categories: prev));
    }
  }

  Future<void> deleteCategory(int id) async {
    final prev = _current;
    // Optimistically remove from list
    final optimistic = prev.where((c) => c.id != id).toList();
    emit(CategoryManageLoaded(optimistic));
    try {
      await _repository.deleteCategory(id: id);
    } on AppException catch (e) {
      emit(CategoryManageError(e.message, categories: prev));
    } catch (_) {
      emit(CategoryManageError('Failed to delete category.', categories: prev));
    }
  }
}
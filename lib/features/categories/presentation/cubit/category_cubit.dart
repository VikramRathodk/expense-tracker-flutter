import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/models/category_model.dart';
import '../../domain/repositories/category_repository.dart';

// ─── States ──────────────────────────────────────────────────────────────────

sealed class CategoryState {}

class CategoryInitial extends CategoryState {}

class CategoryLoading extends CategoryState {}

class CategoryLoaded extends CategoryState {
  CategoryLoaded(this.categories);
  final List<CategoryModel> categories;
}

class CategoryError extends CategoryState {
  CategoryError(this.message);
  final String message;
}

// ─── Cubit ───────────────────────────────────────────────────────────────────

class CategoryCubit extends Cubit<CategoryState> {
  CategoryCubit(this._repository) : super(CategoryInitial());

  final CategoryRepository _repository;

  Future<void> loadCategories() async {
    if (state is CategoryLoaded) return;
    emit(CategoryLoading());
    try {
      final categories = await _repository.getCategories();
      emit(CategoryLoaded(categories));
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  Future<void> reload() async {
    emit(CategoryLoading());
    try {
      final categories = await _repository.getCategories();
      emit(CategoryLoaded(categories));
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }
}

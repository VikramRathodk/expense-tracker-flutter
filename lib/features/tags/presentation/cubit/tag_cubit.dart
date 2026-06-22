import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/app_exception.dart';
import '../../domain/models/tag_model.dart';
import '../../domain/repositories/tag_repository.dart';

// ─── States ──────────────────────────────────────────────────────────────────

sealed class TagState {}

class TagInitial extends TagState {}

class TagLoading extends TagState {}

class TagLoaded extends TagState {
  TagLoaded(this.tags);
  final List<TagModel> tags;
}

class TagError extends TagState {
  TagError(this.message, {this.tags = const []});
  final String message;
  final List<TagModel> tags;
}

// ─── Cubit ───────────────────────────────────────────────────────────────────

class TagCubit extends Cubit<TagState> {
  TagCubit(this._repository) : super(TagInitial());

  final TagRepository _repository;

  List<TagModel> get _current => switch (state) {
        TagLoaded s => s.tags,
        TagError s => s.tags,
        _ => [],
      };

  Future<void> load() async {
    emit(TagLoading());
    try {
      final tags = await _repository.getTags();
      tags.sort((a, b) => b.expenseCount.compareTo(a.expenseCount));
      emit(TagLoaded(tags));
    } on AppException catch (e) {
      emit(TagError(e.message));
    } catch (_) {
      emit(TagError('Failed to load tags.'));
    }
  }

  Future<void> refresh() => load();

  Future<void> renameTag({
    required String name,
    required String newName,
  }) async {
    final prev = _current;
    // Optimistic update
    final updated = prev
        .map((t) => t.name == name ? t.copyWith(name: newName) : t)
        .toList();
    emit(TagLoaded(updated));
    try {
      await _repository.renameTag(name: name, newName: newName);
    } on AppException catch (e) {
      emit(TagError(e.message, tags: prev));
    } catch (_) {
      emit(TagError('Failed to rename tag.', tags: prev));
    }
  }

  Future<void> deleteTag(String name) async {
    final prev = _current;
    // Optimistic removal
    emit(TagLoaded(prev.where((t) => t.name != name).toList()));
    try {
      await _repository.deleteTag(name: name);
    } on AppException catch (e) {
      emit(TagError(e.message, tags: prev));
    } catch (_) {
      emit(TagError('Failed to delete tag.', tags: prev));
    }
  }
}
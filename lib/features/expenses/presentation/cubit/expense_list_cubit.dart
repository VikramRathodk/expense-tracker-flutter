import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import '../../domain/models/expense_model.dart';
import '../../domain/repositories/expense_repository.dart';

// ─── Filter model ─────────────────────────────────────────────────────────────

class ExpenseFilter {
  const ExpenseFilter({
    this.categoryId,
    this.startDate,
    this.endDate,
    this.search,
  });

  final int? categoryId;
  final String? startDate;
  final String? endDate;
  final String? search;

  bool get hasActiveFilters =>
      categoryId != null ||
      startDate != null ||
      endDate != null ||
      (search?.isNotEmpty ?? false);
}

// ─── State ───────────────────────────────────────────────────────────────────

class ExpenseListState {
  const ExpenseListState({required this.filter});

  final ExpenseFilter filter;

  static ExpenseListState initial() =>
      const ExpenseListState(filter: ExpenseFilter());

  ExpenseListState copyWith({ExpenseFilter? filter}) =>
      ExpenseListState(filter: filter ?? this.filter);
}

// ─── Cubit ───────────────────────────────────────────────────────────────────

class ExpenseListCubit extends Cubit<ExpenseListState> {
  ExpenseListCubit(this._repository) : super(ExpenseListState.initial()) {
    _isLastPage = false;
    _pagingController = PagingController<int, ExpenseModel>(
      getNextPageKey: _getNextPageKey,
      fetchPage: _fetchPage,
    );
  }

  final ExpenseRepository _repository;
  late final PagingController<int, ExpenseModel> _pagingController;
  bool _isLastPage = false;

  static const _pageSize = 20;

  PagingController<int, ExpenseModel> get pagingController => _pagingController;

  int? _getNextPageKey(PagingState<int, ExpenseModel> state) {
    if (_isLastPage) return null;
    final keys = state.keys;
    if (keys == null || keys.isEmpty) return 0;
    return keys.last + 1;
  }

  Future<List<ExpenseModel>> _fetchPage(int pageKey) async {
    final filter = state.filter;
    final page = await _repository.getExpenses(
      page: pageKey,
      size: _pageSize,
      categoryId: filter.categoryId,
      startDate: filter.startDate,
      endDate: filter.endDate,
      search: filter.search,
    );
    _isLastPage = page.last;
    return page.content;
  }

  void applyFilter(ExpenseFilter filter) {
    emit(state.copyWith(filter: filter));
    _isLastPage = false;
    _pagingController.refresh();
  }

  void clearFilters() {
    emit(ExpenseListState.initial());
    _isLastPage = false;
    _pagingController.refresh();
  }

  void refresh() {
    _isLastPage = false;
    _pagingController.refresh();
  }

  void removeExpenseLocally(int id) {
    final pages = _pagingController.value.pages;
    if (pages == null) return;
    final newPages = pages
        .map((page) => page.where((e) => e.id != id).toList())
        .toList();
    _pagingController.value =
        _pagingController.value.copyWith(pages: newPages);
  }

  void updateExpenseLocally(ExpenseModel updated) {
    final pages = _pagingController.value.pages;
    if (pages == null) return;
    final newPages = pages
        .map((page) =>
            page.map((e) => e.id == updated.id ? updated : e).toList())
        .toList();
    _pagingController.value =
        _pagingController.value.copyWith(pages: newPages);
  }

  Future<void> deleteExpense(int id) async {
    removeExpenseLocally(id);
    try {
      await _repository.deleteExpense(id);
    } catch (_) {
      _isLastPage = false;
      _pagingController.refresh();
      rethrow;
    }
  }

  @override
  Future<void> close() {
    _pagingController.dispose();
    return super.close();
  }
}

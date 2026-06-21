import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:intl/intl.dart';
import '../../../../config/app_theme.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../routes/app_routes.dart';
import '../../../../shared/widgets/confirmation_dialog.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/expense_list_tile.dart';
import '../../../../shared/widgets/pagination_footer.dart';
import '../../../../shared/widgets/shimmer_loader.dart';
import '../../../categories/domain/models/category_model.dart';
import '../../../categories/presentation/cubit/category_cubit.dart';
import '../../domain/models/expense_model.dart';
import '../cubit/expense_list_cubit.dart';

class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<CategoryCubit>().loadCategories();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ExpenseListCubit>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses',
            style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          BlocBuilder<ExpenseListCubit, ExpenseListState>(
            builder: (context, state) {
              if (!state.filter.hasActiveFilters) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.filter_alt_off_outlined),
                tooltip: 'Clear filters',
                onPressed: () {
                  _searchController.clear();
                  cubit.clearFilters();
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list_outlined),
            onPressed: () => _showFilterSheet(context, cubit),
          ),
        ],
      ),
      body: Column(
        children: [
          _SearchBar(
            controller: _searchController,
            onSearch: (query) => cubit.applyFilter(
              ExpenseFilter(
                categoryId: cubit.state.filter.categoryId,
                startDate: cubit.state.filter.startDate,
                endDate: cubit.state.filter.endDate,
                search: query.isEmpty ? null : query,
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => cubit.refresh(),
              child: ValueListenableBuilder<PagingState<int, ExpenseModel>>(
                valueListenable: cubit.pagingController,
                builder: (context, pagingState, _) {
                  return PagedListView<int, ExpenseModel>(
                    state: pagingState,
                    fetchNextPage: cubit.pagingController.fetchNextPage,
                    builderDelegate:
                        PagedChildBuilderDelegate<ExpenseModel>(
                      animateTransitions: true,
                      itemBuilder: (context, expense, _) => Column(
                        children: [
                          ExpenseListTile(
                            expense: expense,
                            onTap: () async {
                              await context.push(
                                AppRoutes.expenseEdit.replaceAll(
                                    ':id', '${expense.id}'),
                                extra: expense,
                              );
                              cubit.refresh();
                            },
                            onDelete: () =>
                                _confirmDelete(context, cubit, expense),
                          ),
                          const Divider(height: 1, indent: 72),
                        ],
                      ),
                      firstPageProgressIndicatorBuilder: (_) =>
                          const ShimmerList(count: 8),
                      newPageProgressIndicatorBuilder: (_) =>
                          const PaginationLoadingFooter(),
                      noItemsFoundIndicatorBuilder: (_) => EmptyStateWidget(
                        title: 'No expenses yet',
                        subtitle:
                            'Tap the + button to log your first expense.',
                        icon: Icons.receipt_long_outlined,
                        actionLabel: 'Add Expense',
                        onAction: () async {
                          await context.push(AppRoutes.expenseNew);
                          cubit.refresh();
                        },
                      ),
                      firstPageErrorIndicatorBuilder: (_) => ErrorView(
                        message: pagingState.error?.toString() ??
                            'Failed to load expenses.',
                        onRetry: cubit.pagingController.fetchNextPage,
                      ),
                      newPageErrorIndicatorBuilder: (_) =>
                          PaginationErrorFooter(
                        onRetry: cubit.pagingController.fetchNextPage,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await context.push(AppRoutes.expenseNew);
          cubit.refresh();
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    ExpenseListCubit cubit,
    ExpenseModel expense,
  ) async {
    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Delete Expense',
      message:
          'Delete "${expense.description}"? This action cannot be undone.',
      confirmLabel: 'Delete',
      isDestructive: true,
    );
    if (!confirmed || !context.mounted) return;
    try {
      await cubit.deleteExpense(expense.id);
    } catch (_) {
      if (context.mounted) context.showErrorSnackBar('Failed to delete expense.');
    }
  }

  void _showFilterSheet(BuildContext context, ExpenseListCubit cubit) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<CategoryCubit>(),
        child: _FilterSheet(
          currentFilter: cubit.state.filter,
          onApply: cubit.applyFilter,
        ),
      ),
    );
  }
}

// ─── Search bar ──────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.controller, required this.onSearch});

  final TextEditingController controller;
  final ValueChanged<String> onSearch;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.sm),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: 'Search expenses...',
          prefixIcon: const Icon(Icons.search, size: 20),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () {
                    controller.clear();
                    onSearch('');
                  },
                )
              : null,
        ),
        onChanged: onSearch,
      ),
    );
  }
}

// ─── Filter bottom sheet ─────────────────────────────────────────────────────

class _FilterSheet extends StatefulWidget {
  const _FilterSheet({required this.currentFilter, required this.onApply});

  final ExpenseFilter currentFilter;
  final ValueChanged<ExpenseFilter> onApply;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late ExpenseFilter _filter;

  @override
  void initState() {
    super.initState();
    _filter = widget.currentFilter;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md + MediaQuery.paddingOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filter Expenses',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              TextButton(
                onPressed: () =>
                    setState(() => _filter = const ExpenseFilter()),
                child: const Text('Clear all'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Category',
            style: Theme.of(context)
                .textTheme
                .labelMedium
                ?.copyWith(color: const Color(0xFF64748B)),
          ),
          const SizedBox(height: AppSpacing.sm),
          BlocBuilder<CategoryCubit, CategoryState>(
            builder: (context, state) {
              if (state is! CategoryLoaded) return const SizedBox.shrink();
              return Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: state.categories
                    .map(
                      (cat) => _CategoryFilterChip(
                        category: cat,
                        isSelected: _filter.categoryId == cat.id,
                        onTap: () => setState(
                          () => _filter = ExpenseFilter(
                            categoryId: _filter.categoryId == cat.id
                                ? null
                                : cat.id,
                            startDate: _filter.startDate,
                            endDate: _filter.endDate,
                            search: _filter.search,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _DatePickerTile(
                  label: 'From',
                  value: _filter.startDate,
                  onPicked: (date) => setState(
                    () => _filter = ExpenseFilter(
                      categoryId: _filter.categoryId,
                      startDate: date,
                      endDate: _filter.endDate,
                      search: _filter.search,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _DatePickerTile(
                  label: 'To',
                  value: _filter.endDate,
                  onPicked: (date) => setState(
                    () => _filter = ExpenseFilter(
                      categoryId: _filter.categoryId,
                      startDate: _filter.startDate,
                      endDate: date,
                      search: _filter.search,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                widget.onApply(_filter);
                Navigator.of(context).pop();
              },
              child: const Text('Apply Filters'),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryFilterChip extends StatelessWidget {
  const _CategoryFilterChip({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  final CategoryModel category;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = category.displayColor;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(category.iconData,
                size: 14,
                color: isSelected ? Colors.white : color),
            const SizedBox(width: 4),
            Text(
              category.name,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DatePickerTile extends StatelessWidget {
  const _DatePickerTile({
    required this.label,
    required this.value,
    required this.onPicked,
  });

  final String label;
  final String? value;
  final ValueChanged<String?> onPicked;

  @override
  Widget build(BuildContext context) {
    final display = value != null
        ? DateFormat('d MMM yy').format(DateTime.parse(value!))
        : 'Any';

    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate:
              value != null ? DateTime.parse(value!) : DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
        );
        onPicked(
          picked != null
              ? DateFormat('yyyy-MM-dd').format(picked)
              : null,
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: value != null
              ? GestureDetector(
                  onTap: () => onPicked(null),
                  child: const Icon(Icons.close, size: 16))
              : const Icon(Icons.calendar_today_outlined, size: 16),
        ),
        child: Text(display, style: const TextStyle(fontSize: 14)),
      ),
    );
  }
}

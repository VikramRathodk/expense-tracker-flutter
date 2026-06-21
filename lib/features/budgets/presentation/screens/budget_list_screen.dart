import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../config/app_theme.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/double_extensions.dart';
import '../../../../shared/widgets/budget_progress_bar.dart';
import '../../../../shared/widgets/confirmation_dialog.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/shimmer_loader.dart';
import '../../domain/models/budget_model.dart';
import '../cubit/budget_list_cubit.dart';

class BudgetListScreen extends StatefulWidget {
  const BudgetListScreen({super.key});

  @override
  State<BudgetListScreen> createState() => _BudgetListScreenState();
}

class _BudgetListScreenState extends State<BudgetListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<BudgetListCubit>().loadBudgets();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<BudgetListCubit>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budgets',
            style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          TextButton.icon(
            onPressed: () async {
              await context.push('/budgets/recurring');
              cubit.refresh();
            },
            icon: const Icon(Icons.repeat, size: 18),
            label: const Text('Recurring'),
          ),
        ],
      ),
      body: BlocBuilder<BudgetListCubit, BudgetListState>(
        builder: (context, state) {
          if (state is BudgetListLoading || state is BudgetListInitial) {
            return ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: const [
                ShimmerCard(height: 130),
                SizedBox(height: AppSpacing.md),
                ShimmerCard(height: 80),
                ShimmerCard(height: 80),
                ShimmerCard(height: 80),
              ],
            );
          }

          if (state is BudgetListError) {
            return ErrorView(
              message: state.message,
              onRetry: cubit.refresh,
            );
          }

          if (state is BudgetListLoaded) {
            if (state.budgets.isEmpty) {
              return EmptyStateWidget(
                title: 'No budgets set',
                subtitle:
                    'Set spending limits to track your finances better.',
                icon: Icons.pie_chart_outline,
                actionLabel: 'Set Budget',
                onAction: () async {
                  await context.push('/budgets/new');
                  cubit.refresh();
                },
              );
            }

            return RefreshIndicator(
              onRefresh: cubit.refresh,
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.md),
                children: [
                  _PeriodSelector(
                    period: state.period,
                    onChanged: (p) => cubit.loadBudgets(period: p),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  if (state.overallBudget != null) ...[
                    _OverallBudgetCard(budget: state.overallBudget!),
                    const SizedBox(height: AppSpacing.md),
                  ],
                  if (state.categoryBudgets.isNotEmpty) ...[
                    Text(
                      'By Category',
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    ...state.categoryBudgets.map(
                      (b) => _BudgetCard(
                        budget: b,
                        onEdit: () async {
                          await context.push('/budgets/${b.id}/edit',
                              extra: b);
                          cubit.refresh();
                        },
                        onDelete: () =>
                            _confirmDelete(context, cubit, b),
                      ),
                    ),
                  ],
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final budgetCubit = context.read<BudgetListCubit>();
          await context.push('/budgets/new');
          budgetCubit.refresh();
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    BudgetListCubit cubit,
    BudgetModel budget,
  ) async {
    final label =
        budget.isOverall ? 'Overall Budget' : budget.category!.name;
    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Delete Budget',
      message: 'Delete the $label budget? This cannot be undone.',
      confirmLabel: 'Delete',
      isDestructive: true,
    );
    if (!confirmed || !context.mounted) return;
    try {
      await cubit.deleteBudget(budget.id);
      if (context.mounted) {
        context.showSuccessSnackBar('Budget deleted.');
      }
    } catch (_) {
      if (context.mounted) {
        context.showErrorSnackBar('Failed to delete budget.');
      }
    }
  }
}

// ─── Period selector ─────────────────────────────────────────────────────────

class _PeriodSelector extends StatelessWidget {
  const _PeriodSelector({required this.period, required this.onChanged});

  final String period;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('yyyy-MM').parse(period);
    final label = DateFormat('MMMM yyyy').format(date);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () {
            final prev = DateTime(date.year, date.month - 1);
            onChanged(DateFormat('yyyy-MM').format(prev));
          },
        ),
        GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: date,
              firstDate: DateTime(2020),
              lastDate: DateTime(
                  DateTime.now().year, DateTime.now().month + 1),
              initialDatePickerMode: DatePickerMode.year,
            );
            if (picked != null) {
              onChanged(DateFormat('yyyy-MM').format(picked));
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: AppSpacing.xs),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
                fontSize: 15,
              ),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: () {
            final next = DateTime(date.year, date.month + 1);
            if (next.isAfter(DateTime.now())) return;
            onChanged(DateFormat('yyyy-MM').format(next));
          },
        ),
      ],
    );
  }
}

// ─── Overall budget card ──────────────────────────────────────────────────────

class _OverallBudgetCard extends StatelessWidget {
  const _OverallBudgetCard({required this.budget});

  final BudgetModel budget;

  @override
  Widget build(BuildContext context) {
    final color = budget.isOverBudget
        ? AppColors.budgetDanger
        : budget.isNearLimit
            ? AppColors.budgetWarning
            : AppColors.primary;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Total Budget',
                style: TextStyle(color: Colors.white70, fontSize: 13)),
            const SizedBox(height: AppSpacing.xs),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  budget.amount.toCurrencyString(budget.currency),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  '${(budget.percentageUsed * 100).toStringAsFixed(0)}% used',
                  style: const TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: budget.percentageUsed,
                minHeight: 6,
                backgroundColor: Colors.white24,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Spent: ${budget.spentAmount.toCurrencyString(budget.currency)}',
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 12),
                ),
                Text(
                  budget.isOverBudget
                      ? 'Over by ${(-budget.remainingAmount).toCurrencyString(budget.currency)}'
                      : 'Left: ${budget.remainingAmount.toCurrencyString(budget.currency)}',
                  style: TextStyle(
                    color: budget.isOverBudget
                        ? Colors.orange.shade200
                        : Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Category budget card ─────────────────────────────────────────────────────

class _BudgetCard extends StatelessWidget {
  const _BudgetCard({
    required this.budget,
    required this.onEdit,
    required this.onDelete,
  });

  final BudgetModel budget;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final cat = budget.category!;

    return Card(
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: cat.displayColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(cat.iconData,
                      size: 18, color: cat.displayColor),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    cat.name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined,
                      size: 18, color: Color(0xFF94A3B8)),
                  onPressed: onEdit,
                  constraints:
                      const BoxConstraints(minWidth: 32, minHeight: 32),
                  padding: EdgeInsets.zero,
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      size: 18, color: Color(0xFFCBD5E1)),
                  onPressed: onDelete,
                  constraints:
                      const BoxConstraints(minWidth: 32, minHeight: 32),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            BudgetProgressBar(
              label:
                  '${budget.spentAmount.toCompactCurrency(budget.currency)} of ${budget.amount.toCompactCurrency(budget.currency)}',
              spent: budget.spentAmount,
              total: budget.amount,
              currency: budget.currency,
            ),
          ],
        ),
      ),
    );
  }
}

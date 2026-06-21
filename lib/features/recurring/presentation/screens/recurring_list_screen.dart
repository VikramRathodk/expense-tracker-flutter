import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../config/app_theme.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/double_extensions.dart';
import '../../../../shared/widgets/confirmation_dialog.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/shimmer_loader.dart';
import '../../domain/models/recurring_expense_model.dart';
import '../cubit/recurring_list_cubit.dart';

class RecurringListScreen extends StatefulWidget {
  const RecurringListScreen({super.key});

  @override
  State<RecurringListScreen> createState() => _RecurringListScreenState();
}

class _RecurringListScreenState extends State<RecurringListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<RecurringListCubit>().loadRecurring();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<RecurringListCubit>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recurring Expenses',
            style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: BlocBuilder<RecurringListCubit, RecurringListState>(
        builder: (context, state) {
          if (state is RecurringListLoading ||
              state is RecurringListInitial) {
            return const ShimmerList(count: 6);
          }

          if (state is RecurringListError) {
            return ErrorView(
              message: state.message,
              onRetry: cubit.loadRecurring,
            );
          }

          if (state is RecurringListLoaded) {
            if (state.items.isEmpty) {
              return EmptyStateWidget(
                title: 'No recurring expenses',
                subtitle:
                    'Add recurring expenses like rent, subscriptions, or utilities.',
                icon: Icons.repeat_outlined,
                actionLabel: 'Add Recurring',
                onAction: () async {
                  await context.push('/budgets/recurring/new');
                  cubit.refresh();
                },
              );
            }

            return RefreshIndicator(
              onRefresh: cubit.refresh,
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                children: [
                  if (state.active.isNotEmpty) ...[
                    _SectionLabel(label: 'Active (${state.active.length})'),
                    ...state.active.map(
                      (item) => _RecurringTile(
                        item: item,
                        onToggle: () => _toggle(context, cubit, item),
                        onEdit: () async {
                          await context.push(
                            '/budgets/recurring/${item.id}/edit',
                            extra: item,
                          );
                          cubit.refresh();
                        },
                        onDelete: () => _confirmDelete(context, cubit, item),
                      ),
                    ),
                  ],
                  if (state.paused.isNotEmpty) ...[
                    _SectionLabel(
                        label: 'Paused (${state.paused.length})'),
                    ...state.paused.map(
                      (item) => _RecurringTile(
                        item: item,
                        onToggle: () => _toggle(context, cubit, item),
                        onEdit: () async {
                          await context.push(
                            '/budgets/recurring/${item.id}/edit',
                            extra: item,
                          );
                          cubit.refresh();
                        },
                        onDelete: () => _confirmDelete(context, cubit, item),
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
          await context.push('/budgets/recurring/new');
          cubit.refresh();
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _toggle(
    BuildContext context,
    RecurringListCubit cubit,
    RecurringExpenseModel item,
  ) async {
    try {
      await cubit.toggle(item.id);
      if (context.mounted) {
        context.showInfoSnackBar(
          item.isActive ? 'Paused.' : 'Resumed.',
        );
      }
    } catch (_) {
      if (context.mounted) {
        context.showErrorSnackBar('Failed to update status.');
      }
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    RecurringListCubit cubit,
    RecurringExpenseModel item,
  ) async {
    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Delete Recurring Expense',
      message:
          'Stop and delete "${item.description}"? Future executions will be cancelled.',
      confirmLabel: 'Delete',
      isDestructive: true,
    );
    if (!confirmed || !context.mounted) return;
    try {
      await cubit.delete(item.id);
      if (context.mounted) {
        context.showSuccessSnackBar('Recurring expense deleted.');
      }
    } catch (_) {
      if (context.mounted) {
        context.showErrorSnackBar('Failed to delete.');
      }
    }
  }
}

// ─── Section label ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.xs),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: const Color(0xFF64748B),
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
      ),
    );
  }
}

// ─── Recurring tile ───────────────────────────────────────────────────────────

class _RecurringTile extends StatelessWidget {
  const _RecurringTile({
    required this.item,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  final RecurringExpenseModel item;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final cat = item.category;
    final color = cat.displayColor;
    final isActive = item.isActive;

    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.lg),
        color: AppColors.error,
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        final confirmed = await ConfirmationDialog.show(
          context,
          title: 'Delete?',
          message: 'Delete "${item.description}"?',
          confirmLabel: 'Delete',
          isDestructive: true,
        );
        return confirmed;
      },
      onDismissed: (_) => onDelete(),
      child: Opacity(
        opacity: isActive ? 1.0 : 0.55,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: AppSpacing.xs),
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(cat.iconData, size: 20, color: color),
          ),
          title: Text(
            item.description,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Row(
            children: [
              _FrequencyBadge(frequency: item.frequency),
              const SizedBox(width: AppSpacing.xs),
              if (item.nextExecutionDate != null)
                Text(
                  'Next: ${_formatDate(item.nextExecutionDate!)}',
                  style: const TextStyle(
                      fontSize: 11, color: Color(0xFF94A3B8)),
                ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                item.amount.toCurrencyString(item.currency),
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.error,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              PopupMenuButton<_TileAction>(
                icon: const Icon(Icons.more_vert,
                    size: 18, color: Color(0xFF94A3B8)),
                onSelected: (action) {
                  switch (action) {
                    case _TileAction.edit:
                      onEdit();
                    case _TileAction.toggle:
                      onToggle();
                    case _TileAction.delete:
                      onDelete();
                  }
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: _TileAction.edit,
                    child: ListTile(
                      leading: Icon(Icons.edit_outlined, size: 18),
                      title: Text('Edit'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  PopupMenuItem(
                    value: _TileAction.toggle,
                    child: ListTile(
                      leading: Icon(
                        isActive
                            ? Icons.pause_outlined
                            : Icons.play_arrow_outlined,
                        size: 18,
                      ),
                      title: Text(isActive ? 'Pause' : 'Resume'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem(
                    value: _TileAction.delete,
                    child: ListTile(
                      leading: Icon(Icons.delete_outline,
                          size: 18, color: AppColors.error),
                      title: Text('Delete',
                          style: TextStyle(color: AppColors.error)),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ],
          ),
          onTap: onEdit,
        ),
      ),
    );
  }

  String _formatDate(String isoDate) {
    try {
      return DateFormat('d MMM yyyy').format(DateTime.parse(isoDate));
    } catch (_) {
      return isoDate;
    }
  }
}

enum _TileAction { edit, toggle, delete }

// ─── Frequency badge ──────────────────────────────────────────────────────────

class _FrequencyBadge extends StatelessWidget {
  const _FrequencyBadge({required this.frequency});

  final RecurringFrequency frequency;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        frequency.label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: AppColors.info,
        ),
      ),
    );
  }
}

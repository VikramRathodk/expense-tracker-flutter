import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../config/app_theme.dart';
import '../../../../core/extensions/double_extensions.dart';
import '../../../../routes/app_routes.dart';
import '../../../../shared/widgets/budget_progress_bar.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/expense_list_tile.dart';
import '../../../../shared/widgets/shimmer_loader.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../domain/models/dashboard_summary_model.dart';
import '../cubit/dashboard_cubit.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<DashboardCubit>().loadSummary();
  }

  @override
  Widget build(BuildContext context) {
    final user = (context.read<AuthBloc>().state as AuthAuthenticated?)?.user;
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good morning'
        : hour < 17
            ? 'Good afternoon'
            : 'Good evening';

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$greeting,',
              style: const TextStyle(
                  fontSize: 13, color: Color(0xFF64748B)),
            ),
            Text(
              user?.name.split(' ').first ?? 'there',
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            onPressed: () => context.read<DashboardCubit>().refresh(),
          ),
        ],
      ),
      body: BlocBuilder<DashboardCubit, DashboardState>(
        builder: (context, state) {
          if (state is DashboardLoading || state is DashboardInitial) {
            return _DashboardSkeleton();
          }
          if (state is DashboardError) {
            return ErrorView(
              message: state.message,
              onRetry: () => context.read<DashboardCubit>().refresh(),
            );
          }
          if (state is DashboardLoaded) {
            return _DashboardBody(summary: state.summary);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

// ─── Dashboard body ───────────────────────────────────────────────────────────

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({required this.summary});

  final DashboardSummaryModel summary;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => context.read<DashboardCubit>().refresh(),
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          _SpendSummaryCard(summary: summary),
          const SizedBox(height: AppSpacing.md),
          if (summary.categoryBreakdown.isNotEmpty) ...[
            _SectionHeader(
              title: 'By Category',
              onSeeAll: () => context.go(AppRoutes.expenses),
            ),
            const SizedBox(height: AppSpacing.sm),
            _CategoryBreakdownCard(summary: summary),
            const SizedBox(height: AppSpacing.md),
          ],
          if (summary.monthlyTrend.isNotEmpty) ...[
            const _SectionHeader(title: 'Monthly Trend'),
            const SizedBox(height: AppSpacing.sm),
            _MonthlyTrendCard(trend: summary.monthlyTrend),
            const SizedBox(height: AppSpacing.md),
          ],
          if (summary.recentExpenses.isNotEmpty) ...[
            _SectionHeader(
              title: 'Recent Expenses',
              onSeeAll: () => context.go(AppRoutes.expenses),
            ),
            const SizedBox(height: AppSpacing.sm),
            _RecentExpensesList(
              expenses: summary.recentExpenses.take(5).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Spend summary card ───────────────────────────────────────────────────────

class _SpendSummaryCard extends StatelessWidget {
  const _SpendSummaryCard({required this.summary});

  final DashboardSummaryModel summary;

  @override
  Widget build(BuildContext context) {
    final periodLabel = _formatPeriod(summary.period);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: AppColors.primary,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              periodLabel,
              style: const TextStyle(
                  color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              summary.totalSpent.toCurrencyString(summary.currency),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (summary.totalBudget > 0) ...[
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Budget: ${summary.totalBudget.toCurrencyString(summary.currency)}',
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 13),
                  ),
                  Text(
                    '${(summary.budgetUsedPercent * 100).toStringAsFixed(0)}% used',
                    style: TextStyle(
                      color: summary.budgetUsedPercent >= 0.9
                          ? AppColors.warning
                          : Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: summary.budgetUsedPercent,
                  minHeight: 6,
                  backgroundColor: Colors.white24,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    summary.budgetUsedPercent >= 0.9
                        ? AppColors.warning
                        : Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatPeriod(String period) {
    if (period.isEmpty) return 'This Month';
    try {
      final date = DateFormat('yyyy-MM').parse(period);
      return DateFormat('MMMM yyyy').format(date);
    } catch (_) {
      return period;
    }
  }
}

// ─── Category breakdown ───────────────────────────────────────────────────────

class _CategoryBreakdownCard extends StatelessWidget {
  const _CategoryBreakdownCard({required this.summary});

  final DashboardSummaryModel summary;

  @override
  Widget build(BuildContext context) {
    final breakdown = summary.categoryBreakdown.take(5).toList();
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            SizedBox(
              width: 120,
              height: 120,
              child: PieChart(
                PieChartData(
                  sections: breakdown
                      .map(
                        (b) => PieChartSectionData(
                          value: b.percentage,
                          color: b.category.displayColor,
                          title: '',
                          radius: 50,
                        ),
                      )
                      .toList(),
                  sectionsSpace: 2,
                  centerSpaceRadius: 28,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                children: breakdown.map((b) {
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                    child: BudgetProgressBar(
                      label: b.category.name,
                      spent: b.amount,
                      total: summary.totalSpent > 0 ? summary.totalSpent : 1,
                      currency: summary.currency,
                      icon: b.category.iconData,
                      iconColor: b.category.displayColor,
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Monthly trend ────────────────────────────────────────────────────────────

class _MonthlyTrendCard extends StatelessWidget {
  const _MonthlyTrendCard({required this.trend});

  final List<MonthlyTrend> trend;

  @override
  Widget build(BuildContext context) {
    if (trend.isEmpty) return const SizedBox.shrink();

    final maxAmount = trend.map((t) => t.amount).reduce((a, b) => a > b ? a : b);
    final spots = trend.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.amount);
    }).toList();

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: SizedBox(
          height: 140,
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                leftTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index < 0 || index >= trend.length) {
                        return const SizedBox.shrink();
                      }
                      final month = trend[index].month;
                      try {
                        final date = DateFormat('yyyy-MM').parse(month);
                        return Text(
                          DateFormat('MMM').format(date),
                          style: const TextStyle(
                              fontSize: 10, color: Color(0xFF94A3B8)),
                        );
                      } catch (_) {
                        return Text(month,
                            style: const TextStyle(fontSize: 10));
                      }
                    },
                  ),
                ),
              ),
              minY: 0,
              maxY: maxAmount * 1.2,
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: AppColors.primary,
                  barWidth: 2.5,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: AppColors.primary.withValues(alpha: 0.08),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Recent expenses ──────────────────────────────────────────────────────────

class _RecentExpensesList extends StatelessWidget {
  const _RecentExpensesList({required this.expenses});

  final List expenses;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: expenses.asMap().entries.map((e) {
          final expense = e.value;
          final isLast = e.key == expenses.length - 1;
          return Column(
            children: [
              ExpenseListTile(
                expense: expense,
                onTap: () => context.push(
                  AppRoutes.expenseEdit.replaceAll(':id', '${expense.id}'),
                ),
              ),
              if (!isLast) const Divider(height: 1, indent: 72),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// ─── Section header ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.onSeeAll});

  final String title;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        if (onSeeAll != null)
          TextButton(
            onPressed: onSeeAll,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 0),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('See all',
                style: TextStyle(fontSize: 13)),
          ),
      ],
    );
  }
}

// ─── Skeleton loader ──────────────────────────────────────────────────────────

class _DashboardSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: const [
        ShimmerCard(height: 140),
        SizedBox(height: AppSpacing.md),
        ShimmerCard(height: 160),
        SizedBox(height: AppSpacing.md),
        ShimmerList(count: 5),
      ],
    );
  }
}

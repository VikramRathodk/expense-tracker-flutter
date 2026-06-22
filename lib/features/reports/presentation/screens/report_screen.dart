import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../config/app_theme.dart';
import '../../../../core/extensions/double_extensions.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/shimmer_loader.dart';
import '../../domain/models/report_model.dart';
import '../cubit/report_cubit.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ReportCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        actions: [
          BlocBuilder<ReportCubit, ReportState>(
            builder: (context, state) {
              final isExporting = state is ReportExporting;
              final hasData = state is ReportLoaded;
              if (!hasData && !isExporting) return const SizedBox.shrink();
              return isExporting
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : IconButton(
                      icon: const Icon(Icons.download_outlined),
                      tooltip: 'Export CSV',
                      onPressed: () =>
                          context.read<ReportCubit>().exportReport('csv'),
                    );
            },
          ),
        ],
      ),
      body: BlocBuilder<ReportCubit, ReportState>(
        builder: (context, state) {
          final currentFilter = switch (state) {
            ReportInitial(:final filter) => filter,
            ReportLoading(:final filter) => filter,
            ReportLoaded(:final data) => data.filter,
            ReportError(:final filter) => filter,
            ReportExporting(:final data) =>
              data?.filter ?? ReportFilter.defaultFilter(),
          };

          return Column(
            children: [
              _PeriodFilterBar(
                selected: currentFilter.period,
                onSelected: (p) =>
                    context.read<ReportCubit>().changeFilter(p),
              ),
              Expanded(
                child: switch (state) {
                  ReportLoading() => const ShimmerList(count: 6),
                  ReportInitial() => const ShimmerList(count: 6),
                  ReportError(:final message, :final filter) => ErrorView(
                      message: message,
                      onRetry: () =>
                          context.read<ReportCubit>().changeFilter(filter.period),
                    ),
                  ReportLoaded(:final data) => _ReportBody(data: data),
                  ReportExporting(:final data) =>
                    data != null ? _ReportBody(data: data) : const ShimmerList(count: 6),
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PeriodFilterBar extends StatelessWidget {
  const _PeriodFilterBar({
    required this.selected,
    required this.onSelected,
  });

  final ReportPeriod selected;
  final void Function(ReportPeriod) onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: ReportPeriod.values.map((period) {
          final isSelected = period == selected;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(ReportFilter.forPeriod(period).label),
              selected: isSelected,
              onSelected: (_) => onSelected(period),
              showCheckmark: false,
              selectedColor: AppColors.primary.withValues(alpha:0.15),
              labelStyle: TextStyle(
                fontSize: 12,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? AppColors.primary : null,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ReportBody extends StatelessWidget {
  const _ReportBody({required this.data});

  final ReportData data;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () =>
          context.read<ReportCubit>().changeFilter(data.filter.period),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SummaryCards(summary: data.summary),
          const SizedBox(height: 16),
          if (data.monthlyTrend.isNotEmpty) ...[
            _TrendCard(trend: data.monthlyTrend),
            const SizedBox(height: 16),
          ],
          if (data.categoryBreakdown.isNotEmpty) ...[
            _CategoryBreakdownCard(breakdown: data.categoryBreakdown),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }
}

class _SummaryCards extends StatelessWidget {
  const _SummaryCards({required this.summary});

  final ReportSummary summary;

  @override
  Widget build(BuildContext context) {
    final currency = summary.currency;
    return Column(
      children: [
        _BigCard(
          label: 'Total Spent',
          value: summary.totalSpent.toCurrencyString(currency),
          icon: Icons.payments_outlined,
          color: AppColors.primary,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _SmallCard(
                label: 'Avg / Day',
                value: summary.avgPerDay.toCurrencyString(currency),
                icon: Icons.today_outlined,
                color: AppColors.info,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SmallCard(
                label: 'Transactions',
                value: '${summary.expenseCount}',
                icon: Icons.receipt_long_outlined,
                color: AppColors.success,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _BigCard extends StatelessWidget {
  const _BigCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha:0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha:0.5))),
                const SizedBox(height: 4),
                Text(value,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.w700)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SmallCard extends StatelessWidget {
  const _SmallCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha:0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 10),
            Text(value,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w700)),
            Text(label,
                style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha:0.5))),
          ],
        ),
      ),
    );
  }
}

class _TrendCard extends StatelessWidget {
  const _TrendCard({required this.trend});

  final List<ReportMonthlyTrend> trend;

  @override
  Widget build(BuildContext context) {
    final maxAmount =
        trend.map((t) => t.amount).reduce((a, b) => a > b ? a : b);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Monthly Trend',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 160,
              child: BarChart(
                BarChartData(
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
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
                            return const SizedBox.shrink();
                          }
                        },
                      ),
                    ),
                  ),
                  maxY: maxAmount * 1.2,
                  barGroups: trend.asMap().entries.map((e) {
                    return BarChartGroupData(
                      x: e.key,
                      barRods: [
                        BarChartRodData(
                          toY: e.value.amount,
                          color: AppColors.primary,
                          width: 14,
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4)),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryBreakdownCard extends StatelessWidget {
  const _CategoryBreakdownCard({required this.breakdown});

  final List<ReportCategoryBreakdown> breakdown;

  @override
  Widget build(BuildContext context) {
    final topItems = breakdown.take(6).toList();
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Spending by Category',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: PieChart(
                    PieChartData(
                      sections: topItems
                          .map((b) => PieChartSectionData(
                                value: b.percentage,
                                color: b.category.displayColor,
                                title: '',
                                radius: 50,
                              ))
                          .toList(),
                      sectionsSpace: 2,
                      centerSpaceRadius: 28,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    children: topItems
                        .map((b) => _CategoryRow(item: b))
                        .toList(),
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

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({required this.item});

  final ReportCategoryBreakdown item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: item.category.displayColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              item.category.name,
              style: const TextStyle(fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '${item.percentage.toStringAsFixed(0)}%',
            style: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
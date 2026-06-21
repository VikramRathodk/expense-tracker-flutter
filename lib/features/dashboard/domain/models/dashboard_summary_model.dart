import '../../../categories/domain/models/category_model.dart';
import '../../../expenses/domain/models/expense_model.dart';

class DashboardSummaryModel {
  const DashboardSummaryModel({
    required this.totalSpent,
    required this.totalBudget,
    required this.currency,
    required this.period,
    required this.categoryBreakdown,
    required this.recentExpenses,
    required this.monthlyTrend,
  });

  final double totalSpent;
  final double totalBudget;
  final String currency;
  final String period;
  final List<CategoryExpenseSummary> categoryBreakdown;
  final List<ExpenseModel> recentExpenses;
  final List<MonthlyTrend> monthlyTrend;

  double get budgetUsedPercent =>
      totalBudget > 0 ? (totalSpent / totalBudget).clamp(0.0, 1.0) : 0.0;

  double get remainingBudget => (totalBudget - totalSpent).clamp(0.0, double.infinity);

  factory DashboardSummaryModel.fromJson(Map<String, dynamic> json) {
    return DashboardSummaryModel(
      totalSpent: (json['totalSpent'] as num?)?.toDouble() ?? 0.0,
      totalBudget: (json['totalBudget'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'INR',
      period: json['period'] as String? ?? '',
      categoryBreakdown: (json['categoryBreakdown'] as List<dynamic>? ?? [])
          .map((e) => CategoryExpenseSummary.fromJson(e as Map<String, dynamic>))
          .toList(),
      recentExpenses: (json['recentExpenses'] as List<dynamic>? ?? [])
          .map((e) => ExpenseModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      monthlyTrend: (json['monthlyTrend'] as List<dynamic>? ?? [])
          .map((e) => MonthlyTrend.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class CategoryExpenseSummary {
  const CategoryExpenseSummary({
    required this.category,
    required this.amount,
    required this.percentage,
  });

  final CategoryModel category;
  final double amount;
  final double percentage;

  factory CategoryExpenseSummary.fromJson(Map<String, dynamic> json) {
    return CategoryExpenseSummary(
      category: CategoryModel.fromJson(json['category'] as Map<String, dynamic>),
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class MonthlyTrend {
  const MonthlyTrend({required this.month, required this.amount});

  final String month;
  final double amount;

  factory MonthlyTrend.fromJson(Map<String, dynamic> json) {
    return MonthlyTrend(
      month: json['month'] as String,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

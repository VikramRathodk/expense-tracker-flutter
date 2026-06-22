import '../../../categories/domain/models/category_model.dart';

class ReportData {
  const ReportData({
    required this.summary,
    required this.categoryBreakdown,
    required this.monthlyTrend,
    required this.filter,
  });

  final ReportSummary summary;
  final List<ReportCategoryBreakdown> categoryBreakdown;
  final List<ReportMonthlyTrend> monthlyTrend;
  final ReportFilter filter;
}

class ReportSummary {
  const ReportSummary({
    required this.totalSpent,
    required this.avgPerDay,
    required this.expenseCount,
    required this.currency,
    required this.startDate,
    required this.endDate,
  });

  final double totalSpent;
  final double avgPerDay;
  final int expenseCount;
  final String currency;
  final String startDate;
  final String endDate;

  factory ReportSummary.fromJson(Map<String, dynamic> json) {
    return ReportSummary(
      totalSpent: (json['totalSpent'] as num?)?.toDouble() ?? 0.0,
      avgPerDay: (json['avgPerDay'] as num?)?.toDouble() ?? 0.0,
      expenseCount: (json['expenseCount'] as num?)?.toInt() ?? 0,
      currency: json['currency'] as String? ?? 'INR',
      startDate: json['startDate'] as String? ?? '',
      endDate: json['endDate'] as String? ?? '',
    );
  }
}

class ReportCategoryBreakdown {
  const ReportCategoryBreakdown({
    required this.category,
    required this.amount,
    required this.percentage,
    required this.count,
  });

  final CategoryModel category;
  final double amount;
  final double percentage;
  final int count;

  factory ReportCategoryBreakdown.fromJson(Map<String, dynamic> json) {
    return ReportCategoryBreakdown(
      category: CategoryModel.fromJson(
          json['category'] as Map<String, dynamic>),
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
      count: (json['count'] as num?)?.toInt() ?? 0,
    );
  }
}

class ReportMonthlyTrend {
  const ReportMonthlyTrend({
    required this.month,
    required this.amount,
    required this.count,
  });

  final String month;
  final double amount;
  final int count;

  factory ReportMonthlyTrend.fromJson(Map<String, dynamic> json) {
    return ReportMonthlyTrend(
      month: json['month'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      count: (json['count'] as num?)?.toInt() ?? 0,
    );
  }
}

enum ReportPeriod { thisMonth, lastMonth, last3Months, last6Months, thisYear }

class ReportFilter {
  const ReportFilter({
    required this.period,
    required this.startDate,
    required this.endDate,
  });

  final ReportPeriod period;
  final DateTime startDate;
  final DateTime endDate;

  static ReportFilter defaultFilter() {
    final now = DateTime.now();
    return ReportFilter(
      period: ReportPeriod.thisMonth,
      startDate: DateTime(now.year, now.month, 1),
      endDate: DateTime(now.year, now.month + 1, 0),
    );
  }

  static ReportFilter forPeriod(ReportPeriod period) {
    final now = DateTime.now();
    return switch (period) {
      ReportPeriod.thisMonth => ReportFilter(
          period: period,
          startDate: DateTime(now.year, now.month, 1),
          endDate: DateTime(now.year, now.month + 1, 0),
        ),
      ReportPeriod.lastMonth => ReportFilter(
          period: period,
          startDate: DateTime(now.year, now.month - 1, 1),
          endDate: DateTime(now.year, now.month, 0),
        ),
      ReportPeriod.last3Months => ReportFilter(
          period: period,
          startDate: DateTime(now.year, now.month - 2, 1),
          endDate: DateTime(now.year, now.month + 1, 0),
        ),
      ReportPeriod.last6Months => ReportFilter(
          period: period,
          startDate: DateTime(now.year, now.month - 5, 1),
          endDate: DateTime(now.year, now.month + 1, 0),
        ),
      ReportPeriod.thisYear => ReportFilter(
          period: period,
          startDate: DateTime(now.year, 1, 1),
          endDate: DateTime(now.year, 12, 31),
        ),
    };
  }

  String get label => switch (period) {
        ReportPeriod.thisMonth => 'This Month',
        ReportPeriod.lastMonth => 'Last Month',
        ReportPeriod.last3Months => 'Last 3 Months',
        ReportPeriod.last6Months => 'Last 6 Months',
        ReportPeriod.thisYear => 'This Year',
      };

  String get startDateStr =>
      '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-'
      '${startDate.day.toString().padLeft(2, '0')}';

  String get endDateStr =>
      '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-'
      '${endDate.day.toString().padLeft(2, '0')}';
}
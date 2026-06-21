import '../../../categories/domain/models/category_model.dart';

class BudgetModel {
  const BudgetModel({
    required this.id,
    required this.amount,
    required this.currency,
    required this.period,
    required this.spentAmount,
    this.category,
  });

  final int id;
  final double amount;
  final String currency;
  final String period;
  final double spentAmount;
  final CategoryModel? category;

  bool get isOverall => category == null;

  double get remainingAmount => amount - spentAmount;

  double get percentageUsed =>
      amount > 0 ? (spentAmount / amount).clamp(0.0, 1.0) : 0.0;

  bool get isOverBudget => spentAmount > amount;

  bool get isNearLimit => !isOverBudget && percentageUsed >= 0.8;

  factory BudgetModel.fromJson(Map<String, dynamic> json) {
    return BudgetModel(
      id: (json['id'] as num).toInt(),
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'INR',
      period: json['period'] as String? ?? '',
      spentAmount: (json['spentAmount'] as num?)?.toDouble() ?? 0.0,
      category: json['category'] != null
          ? CategoryModel.fromJson(json['category'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'amount': amount,
        'currency': currency,
        'period': period,
        'spentAmount': spentAmount,
        if (category != null) 'category': category!.toJson(),
      };

  BudgetModel copyWith({
    int? id,
    double? amount,
    String? currency,
    String? period,
    double? spentAmount,
    CategoryModel? category,
  }) {
    return BudgetModel(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      period: period ?? this.period,
      spentAmount: spentAmount ?? this.spentAmount,
      category: category ?? this.category,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BudgetModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'BudgetModel(id: $id, amount: $amount, period: $period)';
}

class CreateBudgetRequest {
  const CreateBudgetRequest({
    required this.amount,
    required this.currency,
    required this.period,
    this.categoryId,
  });

  final double amount;
  final String currency;
  final String period;
  final int? categoryId;

  Map<String, dynamic> toJson() => {
        'amount': amount,
        'currency': currency,
        'period': period,
        if (categoryId != null) 'categoryId': categoryId,
      };
}

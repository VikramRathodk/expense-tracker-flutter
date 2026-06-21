import '../../../categories/domain/models/category_model.dart';

enum RecurringFrequency { daily, weekly, monthly, yearly }

extension RecurringFrequencyX on RecurringFrequency {
  String get label => switch (this) {
        RecurringFrequency.daily => 'Daily',
        RecurringFrequency.weekly => 'Weekly',
        RecurringFrequency.monthly => 'Monthly',
        RecurringFrequency.yearly => 'Yearly',
      };

  String get apiValue => name.toUpperCase();

  static RecurringFrequency fromApi(String value) {
    return RecurringFrequency.values.firstWhere(
      (f) => f.apiValue == value.toUpperCase(),
      orElse: () => RecurringFrequency.monthly,
    );
  }
}

class RecurringExpenseModel {
  const RecurringExpenseModel({
    required this.id,
    required this.description,
    required this.amount,
    required this.currency,
    required this.category,
    required this.frequency,
    required this.startDate,
    required this.isActive,
    this.endDate,
    this.nextExecutionDate,
  });

  final int id;
  final String description;
  final double amount;
  final String currency;
  final CategoryModel category;
  final RecurringFrequency frequency;
  final String startDate;
  final bool isActive;
  final String? endDate;
  final String? nextExecutionDate;

  factory RecurringExpenseModel.fromJson(Map<String, dynamic> json) {
    return RecurringExpenseModel(
      id: (json['id'] as num).toInt(),
      description: json['description'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'INR',
      category:
          CategoryModel.fromJson(json['category'] as Map<String, dynamic>),
      frequency: RecurringFrequencyX.fromApi(
          json['frequency'] as String? ?? 'MONTHLY'),
      startDate: json['startDate'] as String,
      isActive: json['isActive'] as bool? ?? true,
      endDate: json['endDate'] as String?,
      nextExecutionDate: json['nextExecutionDate'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'description': description,
        'amount': amount,
        'currency': currency,
        'category': category.toJson(),
        'frequency': frequency.apiValue,
        'startDate': startDate,
        'isActive': isActive,
        if (endDate != null) 'endDate': endDate,
        if (nextExecutionDate != null) 'nextExecutionDate': nextExecutionDate,
      };

  RecurringExpenseModel copyWith({
    int? id,
    String? description,
    double? amount,
    String? currency,
    CategoryModel? category,
    RecurringFrequency? frequency,
    String? startDate,
    bool? isActive,
    String? endDate,
    String? nextExecutionDate,
  }) {
    return RecurringExpenseModel(
      id: id ?? this.id,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      category: category ?? this.category,
      frequency: frequency ?? this.frequency,
      startDate: startDate ?? this.startDate,
      isActive: isActive ?? this.isActive,
      endDate: endDate ?? this.endDate,
      nextExecutionDate: nextExecutionDate ?? this.nextExecutionDate,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecurringExpenseModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class CreateRecurringRequest {
  const CreateRecurringRequest({
    required this.description,
    required this.amount,
    required this.currency,
    required this.categoryId,
    required this.frequency,
    required this.startDate,
    this.endDate,
  });

  final String description;
  final double amount;
  final String currency;
  final int categoryId;
  final RecurringFrequency frequency;
  final String startDate;
  final String? endDate;

  Map<String, dynamic> toJson() => {
        'description': description,
        'amount': amount,
        'currency': currency,
        'categoryId': categoryId,
        'frequency': frequency.apiValue,
        'startDate': startDate,
        if (endDate != null) 'endDate': endDate,
      };
}

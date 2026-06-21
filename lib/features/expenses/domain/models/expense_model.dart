import '../../../categories/domain/models/category_model.dart';

class ExpenseModel {
  const ExpenseModel({
    required this.id,
    required this.amount,
    required this.currency,
    required this.description,
    required this.date,
    required this.category,
    required this.tags,
    required this.createdAt,
    this.receiptUrl,
    this.notes,
    this.isRecurring = false,
    this.recurringExpenseId,
  });

  final int id;
  final double amount;
  final String currency;
  final String description;
  final String date;
  final CategoryModel category;
  final List<String> tags;
  final String createdAt;
  final String? receiptUrl;
  final String? notes;
  final bool isRecurring;
  final int? recurringExpenseId;

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: (json['id'] as num).toInt(),
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'INR',
      description: json['description'] as String,
      date: json['date'] as String,
      category: CategoryModel.fromJson(json['category'] as Map<String, dynamic>),
      tags: List<String>.from(json['tags'] as List? ?? []),
      createdAt: json['createdAt'] as String? ?? '',
      receiptUrl: json['receiptUrl'] as String?,
      notes: json['notes'] as String?,
      isRecurring: json['isRecurring'] as bool? ?? false,
      recurringExpenseId: (json['recurringExpenseId'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'amount': amount,
        'currency': currency,
        'description': description,
        'date': date,
        'category': category.toJson(),
        'tags': tags,
        'createdAt': createdAt,
        'receiptUrl': receiptUrl,
        'notes': notes,
        'isRecurring': isRecurring,
        'recurringExpenseId': recurringExpenseId,
      };

  ExpenseModel copyWith({
    int? id,
    double? amount,
    String? currency,
    String? description,
    String? date,
    CategoryModel? category,
    List<String>? tags,
    String? createdAt,
    String? receiptUrl,
    String? notes,
    bool? isRecurring,
    int? recurringExpenseId,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      description: description ?? this.description,
      date: date ?? this.date,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      receiptUrl: receiptUrl ?? this.receiptUrl,
      notes: notes ?? this.notes,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringExpenseId: recurringExpenseId ?? this.recurringExpenseId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExpenseModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'ExpenseModel(id: $id, amount: $amount $currency, description: $description)';
}

class CreateExpenseRequest {
  const CreateExpenseRequest({
    required this.amount,
    required this.currency,
    required this.description,
    required this.date,
    required this.categoryId,
    this.tags = const [],
    this.notes,
  });

  final double amount;
  final String currency;
  final String description;
  final String date;
  final int categoryId;
  final List<String> tags;
  final String? notes;

  Map<String, dynamic> toJson() => {
        'amount': amount,
        'currency': currency,
        'description': description,
        'date': date,
        'categoryId': categoryId,
        'tags': tags,
        if (notes != null) 'notes': notes,
      };
}

class TagModel {
  const TagModel({required this.name, this.expenseCount = 0});

  final String name;
  final int expenseCount;

  factory TagModel.fromJson(dynamic json) {
    if (json is String) return TagModel(name: json);
    final map = json as Map<String, dynamic>;
    return TagModel(
      name: map['name'] as String,
      expenseCount:
          ((map['count'] ?? map['expenseCount'] ?? 0) as num).toInt(),
    );
  }

  TagModel copyWith({String? name, int? expenseCount}) => TagModel(
        name: name ?? this.name,
        expenseCount: expenseCount ?? this.expenseCount,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is TagModel && name == other.name;

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() => 'TagModel(name: $name, count: $expenseCount)';
}
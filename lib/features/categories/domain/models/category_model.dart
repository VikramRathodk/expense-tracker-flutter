import 'package:flutter/material.dart';

class CategoryModel {
  const CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.isSystem,
  });

  final int id;
  final String name;
  final String icon;
  final String color;
  final bool isSystem;

  Color get displayColor {
    try {
      final hex = color.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return const Color(0xFF6366F1);
    }
  }

  IconData get iconData => _iconMap[icon] ?? Icons.category_outlined;

  static const _iconMap = <String, IconData>{
    'restaurant': Icons.restaurant_outlined,
    'food': Icons.fastfood_outlined,
    'transport': Icons.directions_car_outlined,
    'car': Icons.directions_car_outlined,
    'bus': Icons.directions_bus_outlined,
    'flight': Icons.flight_outlined,
    'shopping': Icons.shopping_bag_outlined,
    'cart': Icons.shopping_cart_outlined,
    'health': Icons.health_and_safety_outlined,
    'medical': Icons.local_hospital_outlined,
    'entertainment': Icons.movie_outlined,
    'movies': Icons.movie_outlined,
    'sports': Icons.sports_soccer_outlined,
    'education': Icons.school_outlined,
    'books': Icons.menu_book_outlined,
    'home': Icons.home_outlined,
    'utilities': Icons.bolt_outlined,
    'rent': Icons.apartment_outlined,
    'travel': Icons.luggage_outlined,
    'hotel': Icons.hotel_outlined,
    'gifts': Icons.card_giftcard_outlined,
    'savings': Icons.savings_outlined,
    'investment': Icons.trending_up_outlined,
    'salary': Icons.attach_money_outlined,
    'work': Icons.work_outline,
    'coffee': Icons.local_cafe_outlined,
    'grocery': Icons.local_grocery_store_outlined,
    'pharmacy': Icons.local_pharmacy_outlined,
    'fitness': Icons.fitness_center_outlined,
    'pets': Icons.pets_outlined,
    'subscriptions': Icons.subscriptions_outlined,
    'electronics': Icons.devices_outlined,
    'clothing': Icons.checkroom_outlined,
    'beauty': Icons.face_outlined,
    'taxes': Icons.account_balance_outlined,
    'insurance': Icons.security_outlined,
  };

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      icon: json['icon'] as String? ?? 'category',
      color: json['color'] as String? ?? '#6366F1',
      isSystem: json['isSystem'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'icon': icon,
        'color': color,
        'isSystem': isSystem,
      };

  CategoryModel copyWith({
    int? id,
    String? name,
    String? icon,
    String? color,
    bool? isSystem,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isSystem: isSystem ?? this.isSystem,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'CategoryModel(id: $id, name: $name)';
}

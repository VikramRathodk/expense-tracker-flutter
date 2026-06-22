import 'package:flutter/material.dart';
import '../../../../config/app_theme.dart';

class NotificationModel {
  const NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
    this.entityId,
    this.entityType,
  });

  final int id;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final String createdAt;
  final int? entityId;
  final String? entityType;

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      type: json['type'] as String? ?? 'GENERAL',
      isRead: json['isRead'] as bool? ?? false,
      createdAt: json['createdAt'] as String? ?? '',
      entityId: (json['entityId'] as num?)?.toInt(),
      entityType: json['entityType'] as String?,
    );
  }

  NotificationModel copyWith({bool? isRead}) => NotificationModel(
        id: id,
        title: title,
        message: message,
        type: type,
        isRead: isRead ?? this.isRead,
        createdAt: createdAt,
        entityId: entityId,
        entityType: entityType,
      );

  IconData get icon => switch (type) {
        'BUDGET_ALERT' => Icons.pie_chart_outline,
        'BUDGET_EXCEEDED' => Icons.warning_amber_outlined,
        'EXPENSE_REMINDER' => Icons.receipt_long_outlined,
        'RECURRING_DUE' => Icons.repeat_outlined,
        'SYSTEM' => Icons.settings_outlined,
        _ => Icons.notifications_outlined,
      };

  Color get iconColor => switch (type) {
        'BUDGET_ALERT' => AppColors.warning,
        'BUDGET_EXCEEDED' => AppColors.error,
        'EXPENSE_REMINDER' => AppColors.info,
        'RECURRING_DUE' => AppColors.primary,
        'SYSTEM' => const Color(0xFF64748B),
        _ => AppColors.primary,
      };
}
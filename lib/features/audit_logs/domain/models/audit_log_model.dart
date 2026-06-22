import 'package:flutter/material.dart';
import '../../../../config/app_theme.dart';

class AuditLogModel {
  const AuditLogModel({
    required this.id,
    required this.action,
    required this.entityType,
    required this.createdAt,
    this.entityId,
    this.details,
    this.performedBy,
    this.userEmail,
  });

  final int id;
  final String action;
  final String entityType;
  final String createdAt;
  final int? entityId;
  final String? details;
  final String? performedBy;
  final String? userEmail;

  factory AuditLogModel.fromJson(Map<String, dynamic> json) {
    return AuditLogModel(
      id: (json['id'] as num).toInt(),
      action: json['action'] as String? ?? '',
      entityType: json['entityType'] as String? ?? '',
      createdAt: json['createdAt'] as String? ?? '',
      entityId: (json['entityId'] as num?)?.toInt(),
      details: json['details'] as String?,
      performedBy: json['performedBy'] as String? ?? json['userName'] as String?,
      userEmail: json['userEmail'] as String?,
    );
  }

  String get actionLabel {
    final parts = action.split('_');
    if (parts.isEmpty) return action;
    final verb = switch (parts.first) {
      'CREATE' => 'Created',
      'UPDATE' => 'Updated',
      'DELETE' => 'Deleted',
      'LOGIN' => 'Logged in',
      'LOGOUT' => 'Logged out',
      'EXPORT' => 'Exported',
      _ => parts.first,
    };
    if (parts.length > 1) {
      final entity = parts.sublist(1).join(' ').toLowerCase();
      return '$verb $entity';
    }
    return verb;
  }

  Color get actionColor => switch (action.split('_').first) {
        'CREATE' => AppColors.success,
        'UPDATE' => AppColors.info,
        'DELETE' => AppColors.error,
        'LOGIN' => AppColors.primary,
        'LOGOUT' => const Color(0xFF64748B),
        'EXPORT' => AppColors.warning,
        _ => const Color(0xFF94A3B8),
      };

  IconData get actionIcon => switch (action.split('_').first) {
        'CREATE' => Icons.add_circle_outline,
        'UPDATE' => Icons.edit_outlined,
        'DELETE' => Icons.delete_outline,
        'LOGIN' => Icons.login_outlined,
        'LOGOUT' => Icons.logout_outlined,
        'EXPORT' => Icons.download_outlined,
        _ => Icons.history_outlined,
      };
}
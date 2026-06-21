import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../core/extensions/double_extensions.dart';

class BudgetProgressBar extends StatelessWidget {
  const BudgetProgressBar({
    super.key,
    required this.label,
    required this.spent,
    required this.total,
    required this.currency,
    this.icon,
    this.iconColor,
  });

  final String label;
  final double spent;
  final double total;
  final String currency;
  final IconData? icon;
  final Color? iconColor;

  double get _progress => total > 0 ? (spent / total).clamp(0.0, 1.0) : 0.0;

  Color get _barColor {
    if (_progress >= 0.9) return AppColors.budgetDanger;
    if (_progress >= 0.7) return AppColors.budgetWarning;
    return AppColors.budgetSafe;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: iconColor ?? _barColor),
                const SizedBox(width: AppSpacing.sm),
              ],
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF475569),
                      ),
                ),
              ),
              Text(
                '${spent.toCompactCurrency(currency)} / ${total.toCompactCurrency(currency)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF64748B),
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _progress,
              minHeight: 6,
              backgroundColor: const Color(0xFFE2E8F0),
              valueColor: AlwaysStoppedAnimation<Color>(_barColor),
            ),
          ),
          const SizedBox(height: 2),
          if (_progress >= 0.9)
            Text(
              'Budget nearly exhausted',
              style: TextStyle(
                fontSize: 11,
                color: _barColor,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }
}

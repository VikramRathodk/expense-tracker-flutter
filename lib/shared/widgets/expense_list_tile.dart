import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../config/app_theme.dart';
import '../../core/extensions/double_extensions.dart';
import '../../features/expenses/domain/models/expense_model.dart';

class ExpenseListTile extends StatelessWidget {
  const ExpenseListTile({
    super.key,
    required this.expense,
    this.onTap,
    this.onDelete,
  });

  final ExpenseModel expense;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final category = expense.category;
    final color = category.displayColor;
    final formattedDate = _formatDate(expense.date);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(category.iconData, size: 20, color: color),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        category.name,
                        style: TextStyle(
                          fontSize: 12,
                          color: color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Text(
                        ' · ',
                        style: TextStyle(
                            fontSize: 12, color: Color(0xFFCBD5E1)),
                      ),
                      Text(
                        formattedDate,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                      if (expense.isRecurring) ...[
                        const Text(
                          ' · ',
                          style: TextStyle(
                              fontSize: 12, color: Color(0xFFCBD5E1)),
                        ),
                        const Icon(
                          Icons.repeat,
                          size: 12,
                          color: AppColors.info,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  expense.amount.toCurrencyString(expense.currency),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.error,
                      ),
                ),
                if (expense.receiptUrl != null)
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Icon(
                      Icons.receipt_outlined,
                      size: 12,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
              ],
            ),
            if (onDelete != null) ...[
              const SizedBox(width: AppSpacing.xs),
              IconButton(
                icon: const Icon(Icons.delete_outline,
                    size: 18, color: Color(0xFFCBD5E1)),
                onPressed: onDelete,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final expDay = DateTime(date.year, date.month, date.day);
      final diff = today.difference(expDay).inDays;

      if (diff == 0) return 'Today';
      if (diff == 1) return 'Yesterday';
      if (diff < 7) return DateFormat('EEEE').format(date);
      return DateFormat('d MMM').format(date);
    } catch (_) {
      return isoDate;
    }
  }
}

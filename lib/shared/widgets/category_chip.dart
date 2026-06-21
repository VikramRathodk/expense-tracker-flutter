import 'package:flutter/material.dart';
import '../../features/categories/domain/models/category_model.dart';
import '../../config/app_theme.dart';

class CategoryChip extends StatelessWidget {
  const CategoryChip({
    super.key,
    required this.category,
    this.isSelected = false,
    this.onTap,
    this.compact = false,
  });

  final CategoryModel category;
  final bool isSelected;
  final VoidCallback? onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final color = category.displayColor;
    final bg = isSelected ? color : color.withValues(alpha: 0.12);
    final fg = isSelected ? Colors.white : color;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(
          horizontal: compact ? AppSpacing.sm : AppSpacing.md,
          vertical: compact ? AppSpacing.xs : AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? null
              : Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(category.iconData, size: compact ? 14 : 16, color: fg),
            const SizedBox(width: AppSpacing.xs),
            Text(
              category.name,
              style: TextStyle(
                fontSize: compact ? 12 : 13,
                fontWeight: FontWeight.w500,
                color: fg,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

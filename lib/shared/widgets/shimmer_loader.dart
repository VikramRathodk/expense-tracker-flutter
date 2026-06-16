import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../config/app_theme.dart';

/// Wraps any widget in a shimmer animation for skeleton loading states.
/// Replace the real content widget with ShimmerLoader wrapping a placeholder shape.
class ShimmerLoader extends StatelessWidget {
  const ShimmerLoader({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? const Color(0xFF2A2A3E) : const Color(0xFFE2E8F0),
      highlightColor: isDark ? const Color(0xFF3A3A50) : const Color(0xFFF8FAFC),
      child: child,
    );
  }
}

/// A shimmer placeholder shaped like a rounded rectangle.
class ShimmerBox extends StatelessWidget {
  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  final double width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

/// Shimmer placeholder for a single list tile row.
class ShimmerListTile extends StatelessWidget {
  const ShimmerListTile({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoader(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            const ShimmerBox(width: 44, height: 44, borderRadius: 12),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerBox(
                    width: MediaQuery.sizeOf(context).width * 0.5,
                    height: 14,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  const ShimmerBox(width: 80, height: 11),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            const ShimmerBox(width: 60, height: 16),
          ],
        ),
      ),
    );
  }
}

/// Shimmer placeholder for a card block (e.g. dashboard summary card).
class ShimmerCard extends StatelessWidget {
  const ShimmerCard({super.key, this.height = 120});

  final double height;

  @override
  Widget build(BuildContext context) {
    return ShimmerLoader(
      child: Container(
        width: double.infinity,
        height: height,
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}

/// Stacks [count] ShimmerListTile widgets for list screens.
class ShimmerList extends StatelessWidget {
  const ShimmerList({super.key, this.count = 6});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(count, (_) => const ShimmerListTile()),
    );
  }
}

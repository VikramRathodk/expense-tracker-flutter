import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import 'app_button.dart';

class ErrorView extends StatelessWidget {
  const ErrorView({
    super.key,
    required this.message,
    this.onRetry,
    this.isFullPage = true,
  });

  final String message;
  final VoidCallback? onRetry;
  final bool isFullPage;

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.error_outline_rounded,
          size: 56,
          color: AppColors.error,
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF64748B),
              ),
        ),
        if (onRetry != null) ...[
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: 160,
            child: AppButton(label: 'Try Again', onPressed: onRetry),
          ),
        ],
      ],
    );

    if (!isFullPage) return content;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: content,
      ),
    );
  }
}

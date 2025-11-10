import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// حالة خطأ مع رسالة
class ErrorWidget extends StatelessWidget {
  final String title;
  final String? message;
  final IconData? icon;

  const ErrorWidget({
    super.key,
    this.title = 'حدث خطأ',
    this.message,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.danger.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon ?? Icons.error_outline,
                size: 60,
                color: AppColors.danger,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(
                message!,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

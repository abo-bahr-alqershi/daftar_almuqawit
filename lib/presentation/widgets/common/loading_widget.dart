import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// مؤشر تحميل مخصص
class LoadingWidget extends StatelessWidget {
  final double size;
  final Color? color;
  final String? message;

  const LoadingWidget({
    super.key,
    this.size = 40,
    this.color,
    this.message,
  });

  /// مؤشر تحميل صغير
  const LoadingWidget.small({super.key})
      : size = 24,
        color = null,
        message = null;

  /// مؤشر تحميل كبير
  const LoadingWidget.large({super.key, this.message})
      : size = 60,
        color = null;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              strokeWidth: size > 40 ? 4 : 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                color ?? AppColors.primary,
              ),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
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
    );
  }
}

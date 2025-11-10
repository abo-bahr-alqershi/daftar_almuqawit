/// بطاقة التقرير
/// ويدجت لعرض بطاقة تقرير قابلة للنقر

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// بطاقة التقرير
class ReportCard extends StatelessWidget {
  /// عنوان التقرير
  final String title;
  
  /// وصف التقرير
  final String description;
  
  /// أيقونة التقرير
  final IconData icon;
  
  /// لون البطاقة
  final Color color;
  
  /// دالة عند النقر
  final VoidCallback onTap;
  
  /// هل التقرير متاح
  final bool isEnabled;
  
  /// شارة إشعار (اختيارية)
  final String? badge;

  const ReportCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    this.color = AppColors.primary,
    required this.onTap,
    this.isEnabled = true,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isEnabled ? 1.0 : 0.5,
      child: InkWell(
        onTap: isEnabled ? onTap : null,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.border,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // أيقونة التقرير
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      icon,
                      color: color,
                      size: 28,
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // شارة الإشعار
                  if (badge != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.danger.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        badge!,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.danger,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  
                  // سهم الانتقال
                  if (isEnabled)
                    const Icon(
                      Icons.arrow_back_ios,
                      size: 16,
                      color: AppColors.textHint,
                    ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // عنوان التقرير
              Text(
                title,
                style: AppTextStyles.h3.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 8),
              
              // وصف التقرير
              Text(
                description,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

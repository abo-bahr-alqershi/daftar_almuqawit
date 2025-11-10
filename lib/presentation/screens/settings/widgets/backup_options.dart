import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../widgets/common/app_button.dart';

/// ويدجت خيارات النسخ الاحتياطي
/// يعرض خيارات إنشاء واستعادة النسخ الاحتياطية
class BackupOptions extends StatelessWidget {
  /// وقت آخر نسخة احتياطية
  final DateTime? lastBackupTime;
  
  /// هل جاري عمل نسخة احتياطية
  final bool isBackingUp;
  
  /// هل جاري استعادة نسخة احتياطية
  final bool isRestoring;
  
  /// حجم آخر نسخة احتياطية بالميجابايت
  final double? lastBackupSize;
  
  /// عدد الملفات في النسخة الاحتياطية
  final int? filesCount;
  
  /// عند الضغط على إنشاء نسخة احتياطية
  final VoidCallback onCreateBackup;
  
  /// عند الضغط على استعادة نسخة احتياطية
  final VoidCallback onRestoreBackup;
  
  /// عند الضغط على جدولة النسخ الاحتياطي التلقائي
  final VoidCallback onScheduleAutoBackup;

  const BackupOptions({
    super.key,
    this.lastBackupTime,
    required this.isBackingUp,
    required this.isRestoring,
    this.lastBackupSize,
    this.filesCount,
    required this.onCreateBackup,
    required this.onRestoreBackup,
    required this.onScheduleAutoBackup,
  });

  /// تنسيق التاريخ
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return 'منذ ${difference.inMinutes} دقيقة';
      }
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inDays == 1) {
      return 'أمس';
    } else if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} أيام';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // بطاقة معلومات آخر نسخة احتياطية
        if (lastBackupTime != null) ...[
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingL),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.border,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.cloud_done,
                      color: AppColors.success,
                      size: 24,
                    ),
                    const SizedBox(width: AppDimensions.spaceM),
                    Text(
                      'آخر نسخة احتياطية',
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.spaceM),
                
                // معلومات النسخة الاحتياطية
                _InfoRow(
                  icon: Icons.access_time,
                  label: 'الوقت',
                  value: _formatDate(lastBackupTime!),
                ),
                const SizedBox(height: AppDimensions.spaceS),
                
                if (lastBackupSize != null)
                  _InfoRow(
                    icon: Icons.storage,
                    label: 'الحجم',
                    value: '${lastBackupSize!.toStringAsFixed(2)} MB',
                  ),
                const SizedBox(height: AppDimensions.spaceS),
                
                if (filesCount != null)
                  _InfoRow(
                    icon: Icons.folder,
                    label: 'عدد الملفات',
                    value: filesCount.toString(),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.spaceL),
        ],

        // زر إنشاء نسخة احتياطية
        AppButton.primary(
          text: isBackingUp ? 'جاري الإنشاء...' : 'إنشاء نسخة احتياطية',
          onPressed: isBackingUp || isRestoring ? null : onCreateBackup,
          icon: Icons.backup,
          isLoading: isBackingUp,
          fullWidth: true,
        ),
        
        const SizedBox(height: AppDimensions.spaceM),
        
        // زر استعادة نسخة احتياطية
        AppButton.secondary(
          text: isRestoring ? 'جاري الاستعادة...' : 'استعادة نسخة احتياطية',
          onPressed: isBackingUp || isRestoring ? null : onRestoreBackup,
          icon: Icons.restore,
          isLoading: isRestoring,
          fullWidth: true,
        ),
        
        const SizedBox(height: AppDimensions.spaceM),
        
        // زر جدولة النسخ التلقائي
        AppButton.secondary(
          text: 'جدولة النسخ التلقائي',
          onPressed: isBackingUp || isRestoring ? null : onScheduleAutoBackup,
          icon: Icons.schedule,
          fullWidth: true,
        ),

        // رسالة تحذيرية
        const SizedBox(height: AppDimensions.spaceL),
        Container(
          padding: const EdgeInsets.all(AppDimensions.paddingM),
          decoration: BoxDecoration(
            color: AppColors.warning.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.warning.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppColors.warning,
                size: 20,
              ),
              const SizedBox(width: AppDimensions.spaceM),
              Expanded(
                child: Text(
                  'تأكد من حفظ النسخة الاحتياطية في مكان آمن',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.warning,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// صف معلومات
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: AppDimensions.spaceS),
        Text(
          '$label: ',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

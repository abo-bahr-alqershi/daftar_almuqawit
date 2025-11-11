import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';

/// ويدجت خيارات النسخ الاحتياطي
///
/// يعرض خيارات النسخ الاحتياطي والاستعادة مع أيقونات وأوصاف
class BackupOptions extends StatelessWidget {
  final VoidCallback? onBackupNow;
  final VoidCallback? onBackupToDrive;
  final VoidCallback? onRestoreFromDrive;
  final VoidCallback? onRestore;
  final VoidCallback? onAutoBackup;
  final VoidCallback? onExportData;
  final bool isAutoBackupEnabled;
  final DateTime? lastBackupDate;

  const BackupOptions({
    super.key,
    this.onBackupNow,
    this.onBackupToDrive,
    this.onRestoreFromDrive,
    this.onRestore,
    this.onAutoBackup,
    this.onExportData,
    this.isAutoBackupEnabled = false,
    this.lastBackupDate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // بطاقة آخر نسخة احتياطية
        if (lastBackupDate != null) ...[
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingM),
            decoration: BoxDecoration(
              color: AppColors.infoLight,
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              border: Border.all(color: AppColors.info.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppColors.info,
                  size: AppDimensions.iconM,
                ),
                const SizedBox(width: AppDimensions.spaceM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'آخر نسخة احتياطية',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.info,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(lastBackupDate!),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.spaceL),
        ],

        // خيار النسخ الاحتياطي الآن
        _BackupOptionTile(
          icon: Icons.backup,
          title: 'نسخ احتياطي الآن',
          description: 'حفظ نسخة من بياناتك على السحابة',
          iconColor: AppColors.primary,
          iconBackgroundColor: AppColors.primaryLight.withOpacity(0.1),
          onTap: onBackupNow,
        ),
        const SizedBox(height: AppDimensions.spaceM),

        // خيار النسخ الاحتياطي إلى Google Drive
        _BackupOptionTile(
          icon: Icons.cloud_upload,
          title: 'نسخ احتياطي إلى Google Drive',
          description: 'رفع نسخة آمنة إلى حسابك على Google Drive',
          iconColor: const Color(0xFF4285F4), // Google Blue
          iconBackgroundColor: const Color(0xFF4285F4).withOpacity(0.1),
          onTap: onBackupToDrive,
        ),
        const SizedBox(height: AppDimensions.spaceM),

        // خيار الاستعادة من Google Drive
        _BackupOptionTile(
          icon: Icons.cloud_download,
          title: 'استعادة من Google Drive',
          description: 'استرجاع نسخة احتياطية من حسابك على Drive',
          iconColor: const Color(0xFF34A853), // Google Green
          iconBackgroundColor: const Color(0xFF34A853).withOpacity(0.1),
          onTap: onRestoreFromDrive,
        ),
        const SizedBox(height: AppDimensions.spaceM),

        // خيار الاستعادة
        _BackupOptionTile(
          icon: Icons.restore,
          title: 'استعادة البيانات',
          description: 'استرجاع البيانات من نسخة احتياطية سابقة',
          iconColor: AppColors.info,
          iconBackgroundColor: AppColors.infoLight,
          onTap: onRestore,
        ),
        const SizedBox(height: AppDimensions.spaceM),

        // خيار النسخ الاحتياطي التلقائي
        _BackupOptionTile(
          icon: isAutoBackupEnabled ? Icons.cloud_done : Icons.cloud_off,
          title: 'النسخ الاحتياطي التلقائي',
          description: isAutoBackupEnabled
              ? 'النسخ التلقائي مفعّل'
              : 'النسخ التلقائي معطّل',
          iconColor: isAutoBackupEnabled
              ? AppColors.success
              : AppColors.textSecondary,
          iconBackgroundColor: isAutoBackupEnabled
              ? AppColors.successLight
              : AppColors.disabled.withOpacity(0.1),
          onTap: onAutoBackup,
          trailing: Switch(
            value: isAutoBackupEnabled,
            onChanged: onAutoBackup != null ? (_) => onAutoBackup!() : null,
            activeColor: AppColors.success,
          ),
        ),
        const SizedBox(height: AppDimensions.spaceM),

        // خيار تصدير البيانات
        _BackupOptionTile(
          icon: Icons.file_download,
          title: 'تصدير البيانات',
          description: 'حفظ نسخة محلية من البيانات',
          iconColor: AppColors.warning,
          iconBackgroundColor: AppColors.warningLight,
          onTap: onExportData,
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'الآن';
    } else if (difference.inHours < 1) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else if (difference.inHours < 24) {
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} يوم';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

/// عنصر خيار النسخ الاحتياطي
class _BackupOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color iconColor;
  final Color iconBackgroundColor;
  final VoidCallback? onTap;
  final Widget? trailing;

  const _BackupOptionTile({
    required this.icon,
    required this.title,
    required this.description,
    required this.iconColor,
    required this.iconBackgroundColor,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            // الأيقونة
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconBackgroundColor,
                borderRadius: BorderRadius.circular(AppDimensions.radiusS),
              ),
              child: Icon(icon, color: iconColor, size: AppDimensions.iconM),
            ),
            const SizedBox(width: AppDimensions.spaceM),

            // النص
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.titleSmall),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // السهم أو الـ trailing
            if (trailing != null)
              trailing!
            else if (onTap != null)
              Icon(
                Icons.arrow_back_ios,
                color: AppColors.textSecondary,
                size: AppDimensions.iconS,
              ),
          ],
        ),
      ),
    );
  }
}

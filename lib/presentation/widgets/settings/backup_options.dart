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

        // زر النسخ الاحتياطي مع قائمة منسدلة
        _buildDropdownButton(
          context: context,
          icon: Icons.backup,
          title: 'إنشاء نسخة احتياطية',
          description: 'حفظ نسخة من بياناتك',
          iconColor: AppColors.primary,
          iconBackgroundColor: AppColors.primaryLight.withOpacity(0.1),
          options: [
            _DropdownOption(
              icon: Icons.phone_android,
              title: 'نسخ احتياطي محلي',
              description: 'حفظ النسخة على الجهاز',
              onTap: onBackupNow,
            ),
            _DropdownOption(
              icon: Icons.cloud_upload,
              title: 'نسخ احتياطي إلى Google Drive',
              description: 'رفع نسخة آمنة إلى حسابك',
              onTap: onBackupToDrive,
              iconColor: const Color(0xFF4285F4),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.spaceM),

        // زر الاستعادة مع قائمة منسدلة
        _buildDropdownButton(
          context: context,
          icon: Icons.restore,
          title: 'استعادة البيانات',
          description: 'استرجاع نسخة احتياطية سابقة',
          iconColor: AppColors.info,
          iconBackgroundColor: AppColors.infoLight,
          options: [
            _DropdownOption(
              icon: Icons.phone_android,
              title: 'استعادة محلية',
              description: 'استرجاع من نسخة محفوظة على الجهاز',
              onTap: onRestore,
            ),
            _DropdownOption(
              icon: Icons.cloud_download,
              title: 'استعادة من Google Drive',
              description: 'استرجاع من حسابك على Drive',
              onTap: onRestoreFromDrive,
              iconColor: const Color(0xFF34A853),
            ),
          ],
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

  Widget _buildDropdownButton({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required Color iconColor,
    required Color iconBackgroundColor,
    required List<_DropdownOption> options,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(color: AppColors.border),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: ExpansionTile(
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBackgroundColor,
              borderRadius: BorderRadius.circular(AppDimensions.radiusS),
            ),
            child: Icon(icon, color: iconColor, size: AppDimensions.iconM),
          ),
          title: Text(title, style: AppTextStyles.titleSmall),
          subtitle: Text(
            description,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          tilePadding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingM,
            vertical: AppDimensions.paddingS,
          ),
          childrenPadding: const EdgeInsets.only(
            right: AppDimensions.paddingM,
            left: AppDimensions.paddingM,
            bottom: AppDimensions.paddingS,
          ),
          children: options.map((option) {
            return InkWell(
              onTap: option.onTap,
              borderRadius: BorderRadius.circular(AppDimensions.radiusS),
              child: Container(
                padding: const EdgeInsets.all(AppDimensions.paddingM),
                margin: const EdgeInsets.only(bottom: AppDimensions.paddingS),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                  border: Border.all(
                    color: AppColors.border.withOpacity(0.5),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      option.icon,
                      color: option.iconColor ?? AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: AppDimensions.spaceM),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            option.title,
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (option.description != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              option.description!,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_back_ios,
                      color: AppColors.textSecondary,
                      size: 14,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
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

/// خيار في القائمة المنسدلة
class _DropdownOption {
  final IconData icon;
  final String title;
  final String? description;
  final VoidCallback? onTap;
  final Color? iconColor;

  const _DropdownOption({
    required this.icon,
    required this.title,
    this.description,
    this.onTap,
    this.iconColor,
  });
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

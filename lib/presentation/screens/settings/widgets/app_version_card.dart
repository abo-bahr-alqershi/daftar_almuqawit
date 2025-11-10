import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';

/// بطاقة معلومات إصدار التطبيق
/// تعرض رقم الإصدار وتاريخ البناء ومعلومات أخرى عن التطبيق
class AppVersionCard extends StatelessWidget {
  /// اسم التطبيق
  final String appName;
  
  /// رقم الإصدار
  final String version;
  
  /// رقم البناء
  final String buildNumber;
  
  /// تاريخ البناء
  final String? buildDate;
  
  /// البيئة (production, development, testing)
  final String? environment;
  
  /// هل يوجد تحديث متاح
  final bool hasUpdate;
  
  /// رقم الإصدار الجديد
  final String? newVersion;
  
  /// عند الضغط على فحص التحديثات
  final VoidCallback? onCheckUpdate;
  
  /// عند الضغط على زيارة الموقع
  final VoidCallback? onVisitWebsite;

  const AppVersionCard({
    super.key,
    required this.appName,
    required this.version,
    required this.buildNumber,
    this.buildDate,
    this.environment,
    this.hasUpdate = false,
    this.newVersion,
    this.onCheckUpdate,
    this.onVisitWebsite,
  });

  /// الحصول على لون البيئة
  Color _getEnvironmentColor() {
    switch (environment?.toLowerCase()) {
      case 'production':
        return AppColors.success;
      case 'development':
        return AppColors.warning;
      case 'testing':
        return AppColors.info;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // شعار التطبيق
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.textOnDark.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.account_balance_wallet_rounded,
              size: 48,
              color: AppColors.textOnDark,
            ),
          ),
          
          const SizedBox(height: AppDimensions.spaceL),

          // اسم التطبيق
          Text(
            appName,
            style: AppTextStyles.headlineMedium.copyWith(
              color: AppColors.textOnDark,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: AppDimensions.spaceS),

          // رقم الإصدار
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingM,
              vertical: AppDimensions.paddingS,
            ),
            decoration: BoxDecoration(
              color: AppColors.textOnDark.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'الإصدار $version ($buildNumber)',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textOnDark,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // تاريخ البناء
          if (buildDate != null) ...[
            const SizedBox(height: AppDimensions.spaceS),
            Text(
              'تاريخ البناء: $buildDate',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textOnDark.withOpacity(0.8),
              ),
            ),
          ],

          // البيئة
          if (environment != null) ...[
            const SizedBox(height: AppDimensions.spaceS),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingS,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: _getEnvironmentColor().withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getEnvironmentColor(),
                  width: 1,
                ),
              ),
              child: Text(
                environment!.toUpperCase(),
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textOnDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],

          // تنبيه التحديث
          if (hasUpdate) ...[
            const SizedBox(height: AppDimensions.spaceL),
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingM),
              decoration: BoxDecoration(
                color: AppColors.textOnDark,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.system_update,
                        color: AppColors.info,
                        size: 20,
                      ),
                      const SizedBox(width: AppDimensions.spaceS),
                      Text(
                        'يتوفر تحديث جديد!',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.info,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  if (newVersion != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'الإصدار $newVersion',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],

          const SizedBox(height: AppDimensions.spaceL),
          const Divider(
            color: Colors.white24,
            height: 1,
          ),
          const SizedBox(height: AppDimensions.spaceL),

          // الأزرار
          Row(
            children: [
              if (onCheckUpdate != null)
                Expanded(
                  child: _ActionButton(
                    icon: Icons.system_update,
                    label: 'فحص التحديثات',
                    onPressed: onCheckUpdate!,
                  ),
                ),
              if (onCheckUpdate != null && onVisitWebsite != null)
                const SizedBox(width: AppDimensions.spaceM),
              if (onVisitWebsite != null)
                Expanded(
                  child: _ActionButton(
                    icon: Icons.language,
                    label: 'الموقع',
                    onPressed: onVisitWebsite!,
                  ),
                ),
            ],
          ),

          const SizedBox(height: AppDimensions.spaceM),

          // معلومات حقوق النشر
          Text(
            '© 2024 جميع الحقوق محفوظة',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textOnDark.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// زر إجراء
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textOnDark,
        side: BorderSide(color: AppColors.textOnDark.withOpacity(0.5)),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingM,
          vertical: AppDimensions.paddingS,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

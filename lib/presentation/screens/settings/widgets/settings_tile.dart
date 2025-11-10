import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';

/// عنصر قائمة الإعدادات
/// يستخدم لعرض خيار من خيارات الإعدادات مع أيقونة ووصف
class SettingsTile extends StatelessWidget {
  /// عنوان الإعداد
  final String title;
  
  /// وصف الإعداد (اختياري)
  final String? subtitle;
  
  /// أيقونة الإعداد
  final IconData icon;
  
  /// لون الأيقونة
  final Color? iconColor;
  
  /// لون خلفية الأيقونة
  final Color? iconBackgroundColor;
  
  /// عنصر إضافي على اليسار (مثل Switch أو سهم)
  final Widget? trailing;
  
  /// عند الضغط على العنصر
  final VoidCallback? onTap;
  
  /// إظهار خط فاصل
  final bool showDivider;

  const SettingsTile({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    this.iconColor,
    this.iconBackgroundColor,
    this.trailing,
    this.onTap,
    this.showDivider = true,
  });

  /// إنشاء عنصر إعداد مع سهم للتصفح
  factory SettingsTile.navigation({
    Key? key,
    required String title,
    String? subtitle,
    required IconData icon,
    Color? iconColor,
    Color? iconBackgroundColor,
    required VoidCallback onTap,
    bool showDivider = true,
  }) {
    return SettingsTile(
      key: key,
      title: title,
      subtitle: subtitle,
      icon: icon,
      iconColor: iconColor,
      iconBackgroundColor: iconBackgroundColor,
      trailing: const Icon(
        Icons.arrow_back_ios,
        size: 16,
        color: AppColors.textSecondary,
      ),
      onTap: onTap,
      showDivider: showDivider,
    );
  }

  /// إنشاء عنصر إعداد مع مفتاح تبديل (Switch)
  factory SettingsTile.switchTile({
    Key? key,
    required String title,
    String? subtitle,
    required IconData icon,
    Color? iconColor,
    Color? iconBackgroundColor,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool showDivider = true,
  }) {
    return SettingsTile(
      key: key,
      title: title,
      subtitle: subtitle,
      icon: icon,
      iconColor: iconColor,
      iconBackgroundColor: iconBackgroundColor,
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
      ),
      showDivider: showDivider,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingL,
            vertical: AppDimensions.paddingS,
          ),
          // أيقونة الإعداد
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBackgroundColor ?? AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: iconColor ?? AppColors.primary,
              size: 24,
            ),
          ),
          // العنوان والوصف
          title: Text(
            title,
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: subtitle != null
              ? Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    subtitle!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                )
              : null,
          // العنصر الإضافي
          trailing: trailing,
          // عند الضغط
          onTap: onTap,
          // تنسيق الشكل
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        // خط فاصل
        if (showDivider)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
            child: Divider(height: 1),
          ),
      ],
    );
  }
}

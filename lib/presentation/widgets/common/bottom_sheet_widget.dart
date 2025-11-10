import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// ورقة سفلية مخصصة
/// 
/// تستخدم لعرض محتوى إضافي من أسفل الشاشة
class BottomSheetWidget extends StatelessWidget {
  /// العنوان
  final String? title;
  
  /// المحتوى
  final Widget child;
  
  /// ارتفاع الورقة
  final double? height;
  
  /// هل يمكن السحب للإغلاق
  final bool isDismissible;
  
  /// هل تظهر المقبض (Handle)
  final bool showHandle;
  
  /// لون الخلفية
  final Color? backgroundColor;

  const BottomSheetWidget({
    super.key,
    this.title,
    required this.child,
    this.height,
    this.isDismissible = true,
    this.showHandle = true,
    this.backgroundColor,
  });

  /// عرض الورقة السفلية
  static Future<T?> show<T>({
    required BuildContext context,
    String? title,
    required Widget child,
    double? height,
    bool isDismissible = true,
    bool showHandle = true,
    Color? backgroundColor,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      enableDrag: isDismissible,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => BottomSheetWidget(
        title: title,
        height: height,
        isDismissible: isDismissible,
        showHandle: showHandle,
        backgroundColor: backgroundColor,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final effectiveHeight = height ?? screenHeight * 0.5;

    return Container(
      height: effectiveHeight,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showHandle) ...[
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.disabled,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 8),
          ],
          if (title != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title!,
                      style: AppTextStyles.headlineSmall.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (isDismissible)
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                      color: AppColors.textSecondary,
                    ),
                ],
              ),
            ),
            const Divider(height: 1),
          ],
          Expanded(
            child: child,
          ),
        ],
      ),
    );
  }
}

/// ورقة سفلية للخيارات
/// 
/// تعرض قائمة من الخيارات للاختيار
class BottomSheetOptions extends StatelessWidget {
  /// العنوان
  final String? title;
  
  /// الخيارات
  final List<BottomSheetOption> options;
  
  /// هل يظهر زر الإلغاء
  final bool showCancel;
  
  /// نص زر الإلغاء
  final String cancelText;

  const BottomSheetOptions({
    super.key,
    this.title,
    required this.options,
    this.showCancel = true,
    this.cancelText = 'إلغاء',
  });

  /// عرض ورقة الخيارات
  static Future<T?> show<T>({
    required BuildContext context,
    String? title,
    required List<BottomSheetOption<T>> options,
    bool showCancel = true,
    String cancelText = 'إلغاء',
  }) {
    return BottomSheetWidget.show<T>(
      context: context,
      child: BottomSheetOptions(
        title: title,
        options: options,
        showCancel: showCancel,
        cancelText: cancelText,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        ...options.map((option) => ListTile(
          leading: option.icon != null
              ? Icon(option.icon, color: option.iconColor ?? AppColors.textSecondary)
              : null,
          title: Text(
            option.title,
            style: AppTextStyles.bodyMedium.copyWith(
              color: option.textColor ?? AppColors.textPrimary,
            ),
          ),
          subtitle: option.subtitle != null
              ? Text(
                  option.subtitle!,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                )
              : null,
          onTap: () {
            Navigator.of(context).pop(option.value);
            option.onTap?.call();
          },
        )),
        if (showCancel) ...[
          const Divider(height: 1),
          ListTile(
            title: Text(
              cancelText,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            onTap: () => Navigator.of(context).pop(),
          ),
        ],
      ],
    );
  }
}

/// خيار في الورقة السفلية
class BottomSheetOption<T> {
  /// عنوان الخيار
  final String title;
  
  /// نص فرعي
  final String? subtitle;
  
  /// الأيقونة
  final IconData? icon;
  
  /// لون الأيقونة
  final Color? iconColor;
  
  /// لون النص
  final Color? textColor;
  
  /// القيمة المرتبطة
  final T? value;
  
  /// دالة يتم استدعاؤها عند الضغط
  final VoidCallback? onTap;

  const BottomSheetOption({
    required this.title,
    this.subtitle,
    this.icon,
    this.iconColor,
    this.textColor,
    this.value,
    this.onTap,
  });
}

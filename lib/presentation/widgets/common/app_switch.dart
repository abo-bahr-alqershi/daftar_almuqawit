import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// زر اختيار دائري مخصص
/// 
/// يوفر واجهة موحدة لأزرار الاختيار الدائرية في التطبيق
/// مع دعم التسميات والأوصاف والأنماط المختلفة
class AppRadioButton<T> extends StatelessWidget {
  /// القيمة الحالية المختارة
  final T groupValue;
  
  /// قيمة هذا الزر
  final T value;
  
  /// دالة يتم استدعاؤها عند اختيار هذا الزر
  final ValueChanged<T?>? onChanged;
  
  /// النص التوضيحي بجانب الزر
  final String? label;
  
  /// وصف إضافي أسفل التسمية
  final String? description;
  
  /// لون الزر عند التفعيل
  final Color? activeColor;
  
  /// هل الزر معطل
  final bool enabled;

  const AppRadioButton({
    super.key,
    required this.groupValue,
    required this.value,
    this.onChanged,
    this.label,
    this.description,
    this.activeColor,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveActiveColor = activeColor ?? AppColors.primary;
    final isEnabled = enabled && onChanged != null;
    final isSelected = groupValue == value;

    if (label == null && description == null) {
      return Radio<T>(
        value: value,
        groupValue: groupValue,
        onChanged: isEnabled ? onChanged : null,
        activeColor: effectiveActiveColor,
      );
    }

    return InkWell(
      onTap: isEnabled ? () => onChanged!(value) : null,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            Radio<T>(
              value: value,
              groupValue: groupValue,
              onChanged: isEnabled ? onChanged : null,
              activeColor: effectiveActiveColor,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (label != null)
                    Text(
                      label!,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: isEnabled ? AppColors.textPrimary : AppColors.textDisabled,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  if (description != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      description!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isEnabled ? AppColors.textSecondary : AppColors.textDisabled,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// مجموعة أزرار اختيار دائرية
/// 
/// تسمح باختيار خيار واحد فقط من قائمة
class AppRadioGroup<T> extends StatelessWidget {
  /// القيمة المختارة حالياً
  final T? value;
  
  /// دالة يتم استدعاؤها عند تغيير الاختيار
  final ValueChanged<T?>? onChanged;
  
  /// الخيارات المتاحة مع تسمياتها
  final Map<T, String> options;
  
  /// الأوصاف الاختيارية للخيارات
  final Map<T, String>? descriptions;
  
  /// العنوان الرئيسي للمجموعة
  final String? title;
  
  /// هل المجموعة معطلة
  final bool enabled;
  
  /// اتجاه عرض الأزرار (عمودي أو أفقي)
  final Axis direction;

  const AppRadioGroup({
    super.key,
    this.value,
    this.onChanged,
    required this.options,
    this.descriptions,
    this.title,
    this.enabled = true,
    this.direction = Axis.vertical,
  });

  @override
  Widget build(BuildContext context) {
    final radioButtons = options.entries.map((entry) {
      return AppRadioButton<T>(
        groupValue: value as T,
        value: entry.key,
        onChanged: enabled ? onChanged : null,
        label: entry.value,
        description: descriptions?[entry.key],
        enabled: enabled,
      );
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (title != null) ...[
          Text(
            title!,
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (direction == Axis.vertical)
          ...radioButtons
        else
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: radioButtons,
          ),
      ],
    );
  }
}

/// مفتاح تبديل مخصص
/// 
/// يوفر واجهة موحدة لمفاتيح التبديل في التطبيق
/// مع دعم التسميات والأوصاف والأنماط المختلفة
class AppSwitch extends StatelessWidget {
  /// القيمة الحالية للمفتاح
  final bool value;
  
  /// دالة يتم استدعاؤها عند تغيير القيمة
  final ValueChanged<bool>? onChanged;
  
  /// النص التوضيحي بجانب المفتاح
  final String? label;
  
  /// وصف إضافي أسفل التسمية
  final String? description;
  
  /// أيقونة اختيارية
  final IconData? icon;
  
  /// لون المفتاح عند التفعيل
  final Color? activeColor;
  
  /// هل المفتاح معطل
  final bool enabled;
  
  /// موضع المفتاح (يمين أو يسار)
  final bool trailingSwitch;

  const AppSwitch({
    super.key,
    required this.value,
    this.onChanged,
    this.label,
    this.description,
    this.icon,
    this.activeColor,
    this.enabled = true,
    this.trailingSwitch = true,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveActiveColor = activeColor ?? AppColors.primary;
    final isEnabled = enabled && onChanged != null;

    final switchWidget = Switch(
      value: value,
      onChanged: isEnabled ? onChanged : null,
      activeColor: effectiveActiveColor,
      activeTrackColor: effectiveActiveColor.withOpacity(0.5),
    );

    if (label == null && description == null && icon == null) {
      return switchWidget;
    }

    final content = Row(
      children: [
        if (icon != null) ...[
          Icon(
            icon,
            size: 24,
            color: isEnabled ? AppColors.textSecondary : AppColors.textDisabled,
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (label != null)
                Text(
                  label!,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isEnabled ? AppColors.textPrimary : AppColors.textDisabled,
                  ),
                ),
              if (description != null) ...[
                const SizedBox(height: 2),
                Text(
                  description!,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isEnabled ? AppColors.textSecondary : AppColors.textDisabled,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (trailingSwitch) ...[
          const SizedBox(width: 12),
          switchWidget,
        ],
      ],
    );

    if (!trailingSwitch) {
      return Row(
        children: [
          switchWidget,
          const SizedBox(width: 12),
          Expanded(child: content),
        ],
      );
    }

    return InkWell(
      onTap: isEnabled ? () => onChanged!(!value) : null,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: content,
      ),
    );
  }
}

/// بطاقة مفتاح تبديل
/// 
/// عرض مفتاح التبديل داخل بطاقة منفصلة
class AppSwitchTile extends StatelessWidget {
  /// القيمة الحالية للمفتاح
  final bool value;
  
  /// دالة يتم استدعاؤها عند تغيير القيمة
  final ValueChanged<bool>? onChanged;
  
  /// العنوان الرئيسي
  final String title;
  
  /// النص الفرعي
  final String? subtitle;
  
  /// الأيقونة
  final IconData? icon;
  
  /// لون المفتاح عند التفعيل
  final Color? activeColor;
  
  /// هل المفتاح معطل
  final bool enabled;

  const AppSwitchTile({
    super.key,
    required this.value,
    this.onChanged,
    required this.title,
    this.subtitle,
    this.icon,
    this.activeColor,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveActiveColor = activeColor ?? AppColors.primary;
    final isEnabled = enabled && onChanged != null;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: InkWell(
        onTap: isEnabled ? () => onChanged!(!value) : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              if (icon != null) ...[
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: effectiveActiveColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    size: 24,
                    color: effectiveActiveColor,
                  ),
                ),
                const SizedBox(width: 16),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: isEnabled ? AppColors.textPrimary : AppColors.textDisabled,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isEnabled ? AppColors.textSecondary : AppColors.textDisabled,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Switch(
                value: value,
                onChanged: isEnabled ? onChanged : null,
                activeColor: effectiveActiveColor,
                activeTrackColor: effectiveActiveColor.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

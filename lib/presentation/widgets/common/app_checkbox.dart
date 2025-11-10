import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// مربع اختيار مخصص مع تصميم احترافي
/// 
/// يوفر واجهة موحدة لمربعات الاختيار في التطبيق
/// مع دعم التسميات والأوصاف والأنماط المختلفة
class AppCheckbox extends StatelessWidget {
  /// القيمة الحالية للاختيار
  final bool value;
  
  /// دالة يتم استدعاؤها عند تغيير القيمة
  final ValueChanged<bool>? onChanged;
  
  /// النص التوضيحي بجانب المربع
  final String? label;
  
  /// وصف إضافي أسفل التسمية
  final String? description;
  
  /// لون المربع عند التفعيل
  final Color? activeColor;
  
  /// هل المربع معطل
  final bool enabled;
  
  /// حجم المربع
  final double size;

  const AppCheckbox({
    super.key,
    required this.value,
    this.onChanged,
    this.label,
    this.description,
    this.activeColor,
    this.enabled = true,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveActiveColor = activeColor ?? AppColors.primary;
    final isEnabled = enabled && onChanged != null;

    if (label == null && description == null) {
      return SizedBox(
        width: size,
        height: size,
        child: Checkbox(
          value: value,
          onChanged: isEnabled ? (val) => onChanged!(val ?? false) : null,
          activeColor: effectiveActiveColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      );
    }

    return InkWell(
      onTap: isEnabled ? () => onChanged!(!value) : null,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            SizedBox(
              width: size,
              height: size,
              child: Checkbox(
                value: value,
                onChanged: isEnabled ? (val) => onChanged!(val ?? false) : null,
                activeColor: effectiveActiveColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
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

/// مجموعة مربعات اختيار متعددة
/// 
/// تسمح باختيار عدة خيارات من قائمة
class AppCheckboxGroup<T> extends StatelessWidget {
  /// القيم المختارة حالياً
  final List<T> selectedValues;
  
  /// دالة يتم استدعاؤها عند تغيير الاختيار
  final ValueChanged<List<T>>? onChanged;
  
  /// الخيارات المتاحة
  final Map<T, String> options;
  
  /// العنوان الرئيسي للمجموعة
  final String? title;
  
  /// هل المجموعة معطلة
  final bool enabled;

  const AppCheckboxGroup({
    super.key,
    required this.selectedValues,
    this.onChanged,
    required this.options,
    this.title,
    this.enabled = true,
  });

  void _handleChanged(T value, bool isSelected) {
    if (onChanged == null || !enabled) return;

    final newValues = List<T>.from(selectedValues);
    if (isSelected) {
      newValues.add(value);
    } else {
      newValues.remove(value);
    }
    onChanged!(newValues);
  }

  @override
  Widget build(BuildContext context) {
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
        ...options.entries.map((entry) {
          final isSelected = selectedValues.contains(entry.key);
          return AppCheckbox(
            value: isSelected,
            onChanged: enabled
                ? (val) => _handleChanged(entry.key, val)
                : null,
            label: entry.value,
            enabled: enabled,
          );
        }),
      ],
    );
  }
}

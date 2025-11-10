import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

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

/// شريط تمرير مخصص
/// 
/// يوفر واجهة موحدة لشرائط التمرير في التطبيق
/// مع دعم التسميات والقيم والأنماط المختلفة
class AppSlider extends StatelessWidget {
  /// القيمة الحالية للشريط
  final double value;
  
  /// دالة يتم استدعاؤها عند تغيير القيمة
  final ValueChanged<double>? onChanged;
  
  /// أقل قيمة ممكنة
  final double min;
  
  /// أعلى قيمة ممكنة
  final double max;
  
  /// عدد الأقسام (divisions)
  final int? divisions;
  
  /// التسمية الظاهرة أثناء السحب
  final String? label;
  
  /// النص التوضيحي فوق الشريط
  final String? title;
  
  /// لون الشريط النشط
  final Color? activeColor;
  
  /// لون الشريط غير النشط
  final Color? inactiveColor;
  
  /// هل الشريط معطل
  final bool enabled;
  
  /// عرض القيمة الحالية
  final bool showValue;
  
  /// وحدة القياس (مثلاً: "ريال", "%")
  final String? unit;
  
  /// عدد المنازل العشرية للعرض
  final int decimalPlaces;

  const AppSlider({
    super.key,
    required this.value,
    this.onChanged,
    this.min = 0.0,
    this.max = 100.0,
    this.divisions,
    this.label,
    this.title,
    this.activeColor,
    this.inactiveColor,
    this.enabled = true,
    this.showValue = true,
    this.unit,
    this.decimalPlaces = 0,
  });

  String _formatValue(double val) {
    final formattedValue = val.toStringAsFixed(decimalPlaces);
    return unit != null ? '$formattedValue $unit' : formattedValue;
  }

  @override
  Widget build(BuildContext context) {
    final effectiveActiveColor = activeColor ?? AppColors.primary;
    final effectiveInactiveColor = inactiveColor ?? AppColors.disabled;
    final isEnabled = enabled && onChanged != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (title != null || showValue) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (title != null)
                Text(
                  title!,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isEnabled ? AppColors.textPrimary : AppColors.textDisabled,
                  ),
                ),
              if (showValue)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: effectiveActiveColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _formatValue(value),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: effectiveActiveColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: effectiveActiveColor,
            inactiveTrackColor: effectiveInactiveColor,
            thumbColor: effectiveActiveColor,
            overlayColor: effectiveActiveColor.withOpacity(0.2),
            valueIndicatorColor: effectiveActiveColor,
            valueIndicatorTextStyle: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textOnDark,
            ),
          ),
          child: Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            divisions: divisions,
            label: label ?? _formatValue(value),
            onChanged: isEnabled ? onChanged : null,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatValue(min),
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                _formatValue(max),
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// شريط تمرير نطاق (Range Slider)
/// 
/// يسمح باختيار نطاق من القيم
class AppRangeSlider extends StatelessWidget {
  /// القيم الحالية (البداية والنهاية)
  final RangeValues values;
  
  /// دالة يتم استدعاؤها عند تغيير القيم
  final ValueChanged<RangeValues>? onChanged;
  
  /// أقل قيمة ممكنة
  final double min;
  
  /// أعلى قيمة ممكنة
  final double max;
  
  /// عدد الأقسام
  final int? divisions;
  
  /// التسميات
  final RangeLabels? labels;
  
  /// النص التوضيحي فوق الشريط
  final String? title;
  
  /// لون الشريط النشط
  final Color? activeColor;
  
  /// لون الشريط غير النشط
  final Color? inactiveColor;
  
  /// هل الشريط معطل
  final bool enabled;
  
  /// وحدة القياس
  final String? unit;

  const AppRangeSlider({
    super.key,
    required this.values,
    this.onChanged,
    this.min = 0.0,
    this.max = 100.0,
    this.divisions,
    this.labels,
    this.title,
    this.activeColor,
    this.inactiveColor,
    this.enabled = true,
    this.unit,
  });

  String _formatValue(double val) {
    return unit != null ? '${val.toStringAsFixed(0)} $unit' : val.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    final effectiveActiveColor = activeColor ?? AppColors.primary;
    final effectiveInactiveColor = inactiveColor ?? AppColors.disabled;
    final isEnabled = enabled && onChanged != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (title != null) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title!,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isEnabled ? AppColors.textPrimary : AppColors.textDisabled,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: effectiveActiveColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_formatValue(values.start)} - ${_formatValue(values.end)}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: effectiveActiveColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: effectiveActiveColor,
            inactiveTrackColor: effectiveInactiveColor,
            thumbColor: effectiveActiveColor,
            overlayColor: effectiveActiveColor.withOpacity(0.2),
            valueIndicatorColor: effectiveActiveColor,
            valueIndicatorTextStyle: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textOnDark,
            ),
          ),
          child: RangeSlider(
            values: values,
            min: min,
            max: max,
            divisions: divisions,
            labels: labels,
            onChanged: isEnabled ? onChanged : null,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatValue(min),
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                _formatValue(max),
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

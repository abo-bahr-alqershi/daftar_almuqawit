import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/date_utils.dart' as app_date_utils;

/// منتقي تاريخ مخصص
/// 
/// يوفر واجهة موحدة لاختيار التواريخ في التطبيق
/// مع دعم التقويم الهجري والميلادي
class AppDatePicker extends StatelessWidget {
  /// التاريخ المختار حالياً
  final DateTime? selectedDate;
  
  /// دالة يتم استدعاؤها عند اختيار تاريخ
  final ValueChanged<DateTime?>? onDateSelected;
  
  /// التسمية
  final String? label;
  
  /// النص التلميحي
  final String? hint;
  
  /// الأيقونة
  final IconData? prefixIcon;
  
  /// أول تاريخ متاح للاختيار
  final DateTime? firstDate;
  
  /// آخر تاريخ متاح للاختيار
  final DateTime? lastDate;
  
  /// هل الحقل معطل
  final bool enabled;
  
  /// هل الحقل مطلوب
  final bool required;
  
  /// نص الخطأ
  final String? errorText;
  
  /// تنسيق عرض التاريخ
  final String dateFormat;

  const AppDatePicker({
    super.key,
    this.selectedDate,
    this.onDateSelected,
    this.label,
    this.hint = 'اختر التاريخ',
    this.prefixIcon = Icons.calendar_today,
    this.firstDate,
    this.lastDate,
    this.enabled = true,
    this.required = false,
    this.errorText,
    this.dateFormat = 'yyyy/MM/dd',
  });

  Future<void> _selectDate(BuildContext context) async {
    if (!enabled || onDateSelected == null) return;

    final now = DateTime.now();
    final initialDate = selectedDate ?? now;
    final effectiveFirstDate = firstDate ?? DateTime(now.year - 100);
    final effectiveLastDate = lastDate ?? DateTime(now.year + 100);

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: effectiveFirstDate,
      lastDate: effectiveLastDate,
      locale: const Locale('ar'),
      helpText: 'اختر التاريخ',
      cancelText: 'إلغاء',
      confirmText: 'تأكيد',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.textOnDark,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      onDateSelected!(pickedDate);
    }
  }

  String _formatDate(DateTime date) {
    return app_date_utils.formatDate(date, format: dateFormat);
  }

  @override
  Widget build(BuildContext context) {
    final displayText = selectedDate != null ? _formatDate(selectedDate!) : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Row(
            children: [
              Text(
                label!,
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              if (required)
                Text(
                  ' *',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.danger,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        InkWell(
          onTap: () => _selectDate(context),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: enabled ? AppColors.surface : AppColors.disabled.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: errorText != null ? AppColors.danger : AppColors.border,
                width: errorText != null ? 2 : 1.5,
              ),
            ),
            child: Row(
              children: [
                if (prefixIcon != null) ...[
                  Icon(
                    prefixIcon,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Text(
                    displayText ?? hint!,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: displayText != null 
                          ? AppColors.textPrimary 
                          : AppColors.textHint,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 8),
          Text(
            errorText!,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.danger,
            ),
          ),
        ],
      ],
    );
  }
}

/// منتقي نطاق تاريخ
/// 
/// يسمح باختيار فترة زمنية (من تاريخ إلى تاريخ)
class AppDateRangePicker extends StatelessWidget {
  /// نطاق التاريخ المختار
  final DateTimeRange? selectedRange;
  
  /// دالة يتم استدعاؤها عند اختيار نطاق
  final ValueChanged<DateTimeRange?>? onRangeSelected;
  
  /// التسمية
  final String? label;
  
  /// النص التلميحي
  final String? hint;
  
  /// الأيقونة
  final IconData? prefixIcon;
  
  /// أول تاريخ متاح
  final DateTime? firstDate;
  
  /// آخر تاريخ متاح
  final DateTime? lastDate;
  
  /// هل الحقل معطل
  final bool enabled;

  const AppDateRangePicker({
    super.key,
    this.selectedRange,
    this.onRangeSelected,
    this.label,
    this.hint = 'اختر الفترة الزمنية',
    this.prefixIcon = Icons.date_range,
    this.firstDate,
    this.lastDate,
    this.enabled = true,
  });

  Future<void> _selectDateRange(BuildContext context) async {
    if (!enabled || onRangeSelected == null) return;

    final now = DateTime.now();
    final effectiveFirstDate = firstDate ?? DateTime(now.year - 100);
    final effectiveLastDate = lastDate ?? DateTime(now.year + 100);

    final pickedRange = await showDateRangePicker(
      context: context,
      firstDate: effectiveFirstDate,
      lastDate: effectiveLastDate,
      initialDateRange: selectedRange,
      locale: const Locale('ar'),
      helpText: 'اختر الفترة الزمنية',
      cancelText: 'إلغاء',
      confirmText: 'تأكيد',
      saveText: 'حفظ',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.textOnDark,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedRange != null) {
      onRangeSelected!(pickedRange);
    }
  }

  String _formatDateRange(DateTimeRange range) {
    final start = app_date_utils.formatDate(range.start, format: 'yyyy/MM/dd');
    final end = app_date_utils.formatDate(range.end, format: 'yyyy/MM/dd');
    return '$start - $end';
  }

  @override
  Widget build(BuildContext context) {
    final displayText = selectedRange != null ? _formatDateRange(selectedRange!) : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
        ],
        InkWell(
          onTap: () => _selectDateRange(context),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: enabled ? AppColors.surface : AppColors.disabled.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border, width: 1.5),
            ),
            child: Row(
              children: [
                if (prefixIcon != null) ...[
                  Icon(
                    prefixIcon,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Text(
                    displayText ?? hint!,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: displayText != null 
                          ? AppColors.textPrimary 
                          : AppColors.textHint,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

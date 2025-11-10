import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// منتقي وقت مخصص
/// 
/// يوفر واجهة موحدة لاختيار الأوقات في التطبيق
class AppTimePicker extends StatelessWidget {
  /// الوقت المختار حالياً
  final TimeOfDay? selectedTime;
  
  /// دالة يتم استدعاؤها عند اختيار وقت
  final ValueChanged<TimeOfDay?>? onTimeSelected;
  
  /// التسمية
  final String? label;
  
  /// النص التلميحي
  final String? hint;
  
  /// الأيقونة
  final IconData? prefixIcon;
  
  /// هل الحقل معطل
  final bool enabled;
  
  /// هل الحقل مطلوب
  final bool required;
  
  /// نص الخطأ
  final String? errorText;
  
  /// استخدام صيغة 24 ساعة
  final bool use24HourFormat;

  const AppTimePicker({
    super.key,
    this.selectedTime,
    this.onTimeSelected,
    this.label,
    this.hint = 'اختر الوقت',
    this.prefixIcon = Icons.access_time,
    this.enabled = true,
    this.required = false,
    this.errorText,
    this.use24HourFormat = false,
  });

  Future<void> _selectTime(BuildContext context) async {
    if (!enabled || onTimeSelected == null) return;

    final initialTime = selectedTime ?? TimeOfDay.now();

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
      helpText: 'اختر الوقت',
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
            timePickerTheme: TimePickerThemeData(
              backgroundColor: AppColors.surface,
              dialBackgroundColor: AppColors.backgroundSecondary,
              hourMinuteTextColor: AppColors.textPrimary,
              dayPeriodTextColor: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      onTimeSelected!(pickedTime);
    }
  }

  String _formatTime(TimeOfDay time) {
    if (use24HourFormat) {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else {
      final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
      final period = time.period == DayPeriod.am ? 'ص' : 'م';
      return '${hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} $period';
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayText = selectedTime != null ? _formatTime(selectedTime!) : null;

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
          onTap: () => _selectTime(context),
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

/// منتقي تاريخ ووقت معاً
/// 
/// يسمح باختيار التاريخ والوقت في خطوة واحدة
class AppDateTimePicker extends StatelessWidget {
  /// التاريخ والوقت المختار
  final DateTime? selectedDateTime;
  
  /// دالة يتم استدعاؤها عند الاختيار
  final ValueChanged<DateTime?>? onDateTimeSelected;
  
  /// التسمية
  final String? label;
  
  /// النص التلميحي
  final String? hint;
  
  /// أول تاريخ متاح
  final DateTime? firstDate;
  
  /// آخر تاريخ متاح
  final DateTime? lastDate;
  
  /// هل الحقل معطل
  final bool enabled;

  const AppDateTimePicker({
    super.key,
    this.selectedDateTime,
    this.onDateTimeSelected,
    this.label,
    this.hint = 'اختر التاريخ والوقت',
    this.firstDate,
    this.lastDate,
    this.enabled = true,
  });

  Future<void> _selectDateTime(BuildContext context) async {
    if (!enabled || onDateTimeSelected == null) return;

    final now = DateTime.now();
    final initialDate = selectedDateTime ?? now;
    final effectiveFirstDate = firstDate ?? DateTime(now.year - 100);
    final effectiveLastDate = lastDate ?? DateTime(now.year + 100);

    // اختيار التاريخ أولاً
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: effectiveFirstDate,
      lastDate: effectiveLastDate,
      locale: const Locale('ar'),
      helpText: 'اختر التاريخ',
      cancelText: 'إلغاء',
      confirmText: 'التالي',
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

    if (pickedDate == null) return;

    // ثم اختيار الوقت
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
      helpText: 'اختر الوقت',
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

    if (pickedTime != null) {
      final dateTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
      onDateTimeSelected!(dateTime);
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final date = '${dateTime.year}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.day.toString().padLeft(2, '0')}';
    final time = TimeOfDay.fromDateTime(dateTime);
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final period = time.period == DayPeriod.am ? 'ص' : 'م';
    final timeStr = '${hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} $period';
    return '$date - $timeStr';
  }

  @override
  Widget build(BuildContext context) {
    final displayText = selectedDateTime != null ? _formatDateTime(selectedDateTime!) : null;

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
          onTap: () => _selectDateTime(context),
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
                Icon(
                  Icons.event_available,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: 12),
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

/// منتقي نطاق التاريخ
/// ويدجت لاختيار نطاق تاريخ للتقارير

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// منتقي نطاق التاريخ
class DateRangePicker extends StatelessWidget {
  /// تاريخ البداية
  final DateTime? startDate;
  
  /// تاريخ النهاية
  final DateTime? endDate;
  
  /// دالة عند تغيير التاريخ
  final Function(DateTime startDate, DateTime endDate) onDateRangeChanged;
  
  /// عنوان الويدجت
  final String title;
  
  /// هل يعرض الأيقونة
  final bool showIcon;

  const DateRangePicker({
    super.key,
    this.startDate,
    this.endDate,
    required this.onDateRangeChanged,
    this.title = 'اختر الفترة الزمنية',
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy/MM/dd', 'ar');
    
    return InkWell(
      onTap: () => _selectDateRange(context),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.border,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // أيقونة التقويم
            if (showIcon)
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.date_range,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
            
            if (showIcon) const SizedBox(width: 12),
            
            // معلومات التاريخ
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  
                  const SizedBox(height: 4),
                  
                  Text(
                    _getDateRangeText(dateFormat),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            
            // سهم التوسيع
            const Icon(
              Icons.arrow_back_ios,
              size: 16,
              color: AppColors.textHint,
            ),
          ],
        ),
      ),
    );
  }

  /// نص نطاق التاريخ
  String _getDateRangeText(DateFormat dateFormat) {
    if (startDate == null || endDate == null) {
      return 'اختر تاريخ البداية والنهاية';
    }
    
    final start = dateFormat.format(startDate!);
    final end = dateFormat.format(endDate!);
    
    return '$start - $end';
  }

  /// اختيار نطاق التاريخ
  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: startDate != null && endDate != null
          ? DateTimeRange(start: startDate!, end: endDate!)
          : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.textOnDark,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      onDateRangeChanged(picked.start, picked.end);
    }
  }
}

/// منتقي تاريخ سريع
class QuickDatePicker extends StatelessWidget {
  /// دالة عند اختيار فترة
  final Function(DateTime startDate, DateTime endDate) onDateRangeSelected;

  const QuickDatePicker({
    super.key,
    required this.onDateRangeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _QuickDateButton(
          label: 'اليوم',
          onTap: () => _selectToday(),
        ),
        _QuickDateButton(
          label: 'أمس',
          onTap: () => _selectYesterday(),
        ),
        _QuickDateButton(
          label: 'هذا الأسبوع',
          onTap: () => _selectThisWeek(),
        ),
        _QuickDateButton(
          label: 'هذا الشهر',
          onTap: () => _selectThisMonth(),
        ),
        _QuickDateButton(
          label: 'الشهر الماضي',
          onTap: () => _selectLastMonth(),
        ),
      ],
    );
  }

  void _selectToday() {
    final today = DateTime.now();
    onDateRangeSelected(
      DateTime(today.year, today.month, today.day),
      DateTime(today.year, today.month, today.day, 23, 59, 59),
    );
  }

  void _selectYesterday() {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    onDateRangeSelected(
      DateTime(yesterday.year, yesterday.month, yesterday.day),
      DateTime(yesterday.year, yesterday.month, yesterday.day, 23, 59, 59),
    );
  }

  void _selectThisWeek() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    onDateRangeSelected(
      DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day),
      DateTime(now.year, now.month, now.day, 23, 59, 59),
    );
  }

  void _selectThisMonth() {
    final now = DateTime.now();
    onDateRangeSelected(
      DateTime(now.year, now.month, 1),
      DateTime(now.year, now.month, now.day, 23, 59, 59),
    );
  }

  void _selectLastMonth() {
    final now = DateTime.now();
    final lastMonth = DateTime(now.year, now.month - 1, 1);
    final lastDayOfLastMonth = DateTime(now.year, now.month, 0);
    onDateRangeSelected(
      lastMonth,
      DateTime(
        lastDayOfLastMonth.year,
        lastDayOfLastMonth.month,
        lastDayOfLastMonth.day,
        23,
        59,
        59,
      ),
    );
  }
}

/// زر تاريخ سريع
class _QuickDateButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickDateButton({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

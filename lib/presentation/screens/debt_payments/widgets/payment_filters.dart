import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// ويدجت تصفية دفعات الديون
/// يوفر خيارات تصفية حسب طريقة الدفع والفترة الزمنية
class PaymentFilters extends StatelessWidget {
  /// طريقة الدفع المختارة للتصفية
  final String? selectedPaymentMethod;
  
  /// تاريخ البداية للتصفية
  final DateTime? startDate;
  
  /// تاريخ النهاية للتصفية
  final DateTime? endDate;
  
  /// دالة استدعاء عند تغيير طريقة الدفع
  final ValueChanged<String?>? onPaymentMethodChanged;
  
  /// دالة استدعاء عند تغيير الفترة الزمنية
  final Function(DateTime? start, DateTime? end)? onDateRangeChanged;
  
  /// دالة استدعاء عند إعادة تعيين الفلاتر
  final VoidCallback? onReset;

  const PaymentFilters({
    super.key,
    this.selectedPaymentMethod,
    this.startDate,
    this.endDate,
    this.onPaymentMethodChanged,
    this.onDateRangeChanged,
    this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final hasActiveFilters = selectedPaymentMethod != null || 
                             startDate != null || 
                             endDate != null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // رأس الفلاتر
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.filter_list,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'تصفية النتائج',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              
              // زر إعادة التعيين
              if (hasActiveFilters && onReset != null)
                TextButton.icon(
                  onPressed: onReset,
                  icon: const Icon(Icons.clear_all, size: 18),
                  label: const Text('إعادة تعيين'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.danger,
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // فلتر طريقة الدفع
          Text(
            'طريقة الدفع',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _FilterChip(
                label: 'الكل',
                isSelected: selectedPaymentMethod == null,
                onTap: () => onPaymentMethodChanged?.call(null),
              ),
              _FilterChip(
                label: 'نقد',
                icon: Icons.money,
                isSelected: selectedPaymentMethod == 'نقد',
                onTap: () => onPaymentMethodChanged?.call('نقد'),
              ),
              _FilterChip(
                label: 'تحويل',
                icon: Icons.account_balance,
                isSelected: selectedPaymentMethod == 'تحويل',
                onTap: () => onPaymentMethodChanged?.call('تحويل'),
              ),
              _FilterChip(
                label: 'حوالة',
                icon: Icons.receipt_long,
                isSelected: selectedPaymentMethod == 'حوالة',
                onTap: () => onPaymentMethodChanged?.call('حوالة'),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // فلتر الفترة الزمنية
          Text(
            'الفترة الزمنية',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          
          const SizedBox(height: 8),
          
          InkWell(
            onTap: () => _selectDateRange(context),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: (startDate != null || endDate != null)
                      ? AppColors.primary
                      : AppColors.border,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.date_range,
                        color: (startDate != null || endDate != null)
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _getDateRangeText(),
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: (startDate != null || endDate != null)
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    Icons.arrow_drop_down,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
          
          // عرض الفترة المختارة
          if (startDate != null || endDate != null) ...[
            const SizedBox(height: 8),
            Text(
              _getSelectedDateRangeText(),
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// الحصول على نص الفترة الزمنية
  String _getDateRangeText() {
    if (startDate == null && endDate == null) {
      return 'اختر الفترة الزمنية';
    }
    return 'الفترة المختارة';
  }

  /// الحصول على نص الفترة المختارة
  String _getSelectedDateRangeText() {
    if (startDate != null && endDate != null) {
      return 'من ${_formatDate(startDate!)} إلى ${_formatDate(endDate!)}';
    } else if (startDate != null) {
      return 'من ${_formatDate(startDate!)}';
    } else if (endDate != null) {
      return 'حتى ${_formatDate(endDate!)}';
    }
    return '';
  }

  /// تنسيق التاريخ
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// عرض منتقي الفترة الزمنية
  Future<void> _selectDateRange(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      initialDateRange: startDate != null && endDate != null
          ? DateTimeRange(start: startDate!, end: endDate!)
          : null,
      locale: const Locale('ar'),
    );
    
    if (picked != null) {
      onDateRangeChanged?.call(picked.start, picked.end);
    }
  }
}

/// ويدجت Chip للفلاتر
class _FilterChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : AppColors.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: isSelected
                    ? Colors.white
                    : AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: isSelected
                    ? Colors.white
                    : AppColors.textSecondary,
                fontWeight: isSelected
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// ويدجت فلترة دفعات الديون - تصميم راقي هادئ
class PaymentFilters extends StatelessWidget {
  final String? selectedPaymentMethod;
  final DateTime? startDate;
  final DateTime? endDate;
  final ValueChanged<String?>? onPaymentMethodChanged;
  final Function(DateTime? start, DateTime? end)? onDateRangeChanged;
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

    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHandle(),
            _buildHeader(context, hasActiveFilters),
            _buildContent(context),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: AppColors.border.withOpacity(0.5),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool hasActiveFilters) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.border.withOpacity(0.5)),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.success.withOpacity(0.1),
                  AppColors.primary.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.filter_list_rounded,
              color: AppColors.success,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'فلترة الدفعات',
              style: AppTextStyles.h3.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (hasActiveFilters && onReset != null)
            InkWell(
              onTap: onReset,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.danger.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.danger.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.clear_all_rounded,
                      size: 16,
                      color: AppColors.danger,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'إعادة تعيين',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.danger,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPaymentMethodFilter(),
          const SizedBox(height: 24),
          _buildDateRangeFilter(context),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 3,
              height: 16,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.success, AppColors.primary],
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'طريقة الدفع',
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _PaymentMethodChip(
              label: 'الكل',
              icon: Icons.list_alt_rounded,
              isSelected: selectedPaymentMethod == null,
              onTap: () => onPaymentMethodChanged?.call(null),
            ),
            _PaymentMethodChip(
              label: 'نقد',
              icon: Icons.money_rounded,
              isSelected: selectedPaymentMethod == 'نقد',
              onTap: () => onPaymentMethodChanged?.call('نقد'),
              color: AppColors.success,
            ),
            _PaymentMethodChip(
              label: 'تحويل',
              icon: Icons.account_balance_rounded,
              isSelected: selectedPaymentMethod == 'تحويل',
              onTap: () => onPaymentMethodChanged?.call('تحويل'),
              color: AppColors.info,
            ),
            _PaymentMethodChip(
              label: 'حوالة',
              icon: Icons.receipt_long_rounded,
              isSelected: selectedPaymentMethod == 'حوالة',
              onTap: () => onPaymentMethodChanged?.call('حوالة'),
              color: AppColors.warning,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateRangeFilter(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 3,
              height: 16,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.info, AppColors.primary],
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'الفترة الزمنية',
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        InkWell(
          onTap: () => _selectDateRange(context),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: (startDate != null || endDate != null)
                  ? AppColors.info.withOpacity(0.05)
                  : AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: (startDate != null || endDate != null)
                    ? AppColors.info.withOpacity(0.3)
                    : AppColors.border.withOpacity(0.5),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: (startDate != null || endDate != null)
                          ? [AppColors.info, AppColors.primary]
                          : [
                              AppColors.textSecondary.withOpacity(0.1),
                              AppColors.textSecondary.withOpacity(0.05),
                            ],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.date_range_rounded,
                    color: (startDate != null || endDate != null)
                        ? Colors.white
                        : AppColors.textSecondary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getDateRangeText(),
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: (startDate != null || endDate != null)
                              ? AppColors.info
                              : AppColors.textSecondary,
                          fontWeight: (startDate != null || endDate != null)
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                      if (startDate != null || endDate != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          _getSelectedDateRangeText(),
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.info,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down_rounded,
                  color: (startDate != null || endDate != null)
                      ? AppColors.info
                      : AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _getDateRangeText() {
    if (startDate == null && endDate == null) {
      return 'اختر الفترة الزمنية';
    }
    return 'الفترة المختارة';
  }

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

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }

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

class _PaymentMethodChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? color;

  const _PaymentMethodChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? AppColors.textSecondary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [chipColor, chipColor.withOpacity(0.8)],
                )
              : null,
          color: isSelected ? null : AppColors.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.transparent : AppColors.border,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: chipColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : chipColor,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

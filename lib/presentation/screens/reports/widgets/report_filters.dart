/// فلاتر التقرير
/// ويدجت لفلترة بيانات التقرير

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// نوع الفلتر
enum FilterType {
  /// الكل
  all,
  
  /// المبيعات
  sales,
  
  /// المشتريات
  purchases,
  
  /// المصروفات
  expenses,
  
  /// الديون
  debts,
}

/// فلاتر التقرير
class ReportFilters extends StatefulWidget {
  /// الفلتر المحدد حالياً
  final FilterType selectedFilter;
  
  /// دالة عند تغيير الفلتر
  final Function(FilterType filter) onFilterChanged;
  
  /// هل يعرض كقائمة أفقية
  final bool horizontal;

  const ReportFilters({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
    this.horizontal = true,
  });

  @override
  State<ReportFilters> createState() => _ReportFiltersState();
}

class _ReportFiltersState extends State<ReportFilters> {
  @override
  Widget build(BuildContext context) {
    final filters = [
      _FilterOption(
        type: FilterType.all,
        label: 'الكل',
        icon: Icons.dashboard,
      ),
      _FilterOption(
        type: FilterType.sales,
        label: 'المبيعات',
        icon: Icons.trending_up,
      ),
      _FilterOption(
        type: FilterType.purchases,
        label: 'المشتريات',
        icon: Icons.shopping_cart,
      ),
      _FilterOption(
        type: FilterType.expenses,
        label: 'المصروفات',
        icon: Icons.payment,
      ),
      _FilterOption(
        type: FilterType.debts,
        label: 'الديون',
        icon: Icons.account_balance_wallet,
      ),
    ];

    if (widget.horizontal) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: filters.map((filter) {
            return Padding(
              padding: const EdgeInsets.only(left: 8),
              child: _FilterChip(
                option: filter,
                isSelected: widget.selectedFilter == filter.type,
                onTap: () => widget.onFilterChanged(filter.type),
              ),
            );
          }).toList(),
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: filters.map((filter) {
        return _FilterChip(
          option: filter,
          isSelected: widget.selectedFilter == filter.type,
          onTap: () => widget.onFilterChanged(filter.type),
        );
      }).toList(),
    );
  }
}

/// خيار الفلتر
class _FilterOption {
  final FilterType type;
  final String label;
  final IconData icon;

  const _FilterOption({
    required this.type,
    required this.label,
    required this.icon,
  });
}

/// شريحة الفلتر
class _FilterChip extends StatelessWidget {
  final _FilterOption option;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.option,
    required this.isSelected,
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
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.border,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              option.icon,
              size: 18,
              color: isSelected
                  ? AppColors.textOnDark
                  : AppColors.textSecondary,
            ),
            
            const SizedBox(width: 8),
            
            Text(
              option.label,
              style: AppTextStyles.bodySmall.copyWith(
                color: isSelected
                    ? AppColors.textOnDark
                    : AppColors.textPrimary,
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

/// ترتيب التقرير
class ReportSorting extends StatelessWidget {
  /// خيارات الترتيب
  final List<String> sortOptions;
  
  /// الترتيب المحدد
  final String selectedSort;
  
  /// دالة عند تغيير الترتيب
  final Function(String sort) onSortChanged;
  
  /// هل الترتيب تصاعدي
  final bool isAscending;
  
  /// دالة عند تغيير اتجاه الترتيب
  final Function(bool ascending) onDirectionChanged;

  const ReportSorting({
    super.key,
    required this.sortOptions,
    required this.selectedSort,
    required this.onSortChanged,
    required this.isAscending,
    required this.onDirectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.border,
                width: 1,
              ),
            ),
            child: DropdownButton<String>(
              value: selectedSort,
              isExpanded: true,
              underline: const SizedBox.shrink(),
              icon: const Icon(Icons.arrow_drop_down),
              items: sortOptions.map((option) {
                return DropdownMenuItem<String>(
                  value: option,
                  child: Text(
                    option,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  onSortChanged(value);
                }
              },
            ),
          ),
        ),
        
        const SizedBox(width: 8),
        
        IconButton(
          icon: Icon(
            isAscending
                ? Icons.arrow_upward
                : Icons.arrow_downward,
          ),
          color: AppColors.textPrimary,
          onPressed: () => onDirectionChanged(!isAscending),
        ),
      ],
    );
  }
}

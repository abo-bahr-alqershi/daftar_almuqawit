import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// فلاتر المبيعات - تصميم راقي هادئ
class SaleFilters extends StatefulWidget {
  final String selectedFilter;
  final ValueChanged<String> onFilterChanged;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final List<String> filterOptions;

  const SaleFilters({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.searchQuery,
    required this.onSearchChanged,
    this.filterOptions = const [
      'الكل',
      'اليوم',
      'الأسبوع',
      'الشهر',
      'مدفوع',
      'غير مدفوع',
    ],
  });

  @override
  State<SaleFilters> createState() => _SaleFiltersState();
}

class _SaleFiltersState extends State<SaleFilters> {
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearchFocused = false;

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(() {
      setState(() {
        _isSearchFocused = _searchFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildSearchBar(),
          const SizedBox(height: 16),
          _buildFilterChips(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withOpacity(0.15),
                AppColors.primary.withOpacity(0.08),
              ],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.filter_list_rounded,
            color: AppColors.primary,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'البحث والتصفية',
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isSearchFocused
              ? AppColors.primary.withOpacity(0.3)
              : AppColors.border.withOpacity(0.1),
          width: _isSearchFocused ? 1.5 : 1,
        ),
        boxShadow: _isSearchFocused
            ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: TextField(
        focusNode: _searchFocusNode,
        onChanged: (value) {
          widget.onSearchChanged(value);
          if (value.isNotEmpty) {
            HapticFeedback.lightImpact();
          }
        },
        style: AppTextStyles.bodyMedium,
        decoration: InputDecoration(
          hintText: 'ابحث عن فاتورة، عميل، أو منتج...',
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textHint,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: _isSearchFocused ? AppColors.primary : AppColors.textSecondary,
            size: 22,
          ),
          suffixIcon: widget.searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(
                    Icons.close_rounded,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  onPressed: () {
                    widget.onSearchChanged('');
                    HapticFeedback.lightImpact();
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'تصفية حسب',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: widget.filterOptions.map((filter) {
              final isSelected = widget.selectedFilter == filter;
              return Padding(
                padding: const EdgeInsets.only(left: 8),
                child: _FilterChip(
                  label: filter,
                  isSelected: isSelected,
                  onSelected: () {
                    widget.onFilterChanged(filter);
                    HapticFeedback.lightImpact();
                  },
                  icon: _getFilterIcon(filter),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  IconData _getFilterIcon(String filter) {
    switch (filter) {
      case 'الكل':
        return Icons.grid_view_rounded;
      case 'اليوم':
        return Icons.today_rounded;
      case 'الأسبوع':
        return Icons.date_range_rounded;
      case 'الشهر':
        return Icons.calendar_month_rounded;
      case 'مدفوع':
        return Icons.check_circle_rounded;
      case 'غير مدفوع':
        return Icons.pending_rounded;
      default:
        return Icons.filter_alt_rounded;
    }
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;
  final IconData icon;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelected,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.15),
                    AppColors.primary.withOpacity(0.08),
                  ],
                )
              : null,
          color: isSelected ? null : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primary.withOpacity(0.3)
                : AppColors.border.withOpacity(0.15),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

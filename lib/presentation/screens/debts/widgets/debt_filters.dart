import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// فلترة وتصفية الديون
/// 
/// يوفر خيارات متعددة لتصفية قائمة الديون
class DebtFilters extends StatefulWidget {
  final String selectedFilter;
  final String selectedSortBy;
  final Function(String) onFilterChanged;
  final Function(String) onSortChanged;

  const DebtFilters({
    super.key,
    this.selectedFilter = 'الكل',
    this.selectedSortBy = 'التاريخ',
    required this.onFilterChanged,
    required this.onSortChanged,
  });

  @override
  State<DebtFilters> createState() => _DebtFiltersState();
}

class _DebtFiltersState extends State<DebtFilters> {
  late String _selectedFilter;
  late String _selectedSortBy;

  @override
  void initState() {
    super.initState();
    _selectedFilter = widget.selectedFilter;
    _selectedSortBy = widget.selectedSortBy;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // عنوان
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'تصفية الديون',
                style: AppTextStyles.headlineMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // قسم التصفية حسب الحالة
          _buildSectionTitle('حسب الحالة'),
          const SizedBox(height: 12),
          
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildFilterChip('الكل', Icons.all_inclusive, null),
              _buildFilterChip('معلقة', Icons.pending, AppColors.warning),
              _buildFilterChip('متأخرة', Icons.warning, AppColors.danger),
              _buildFilterChip('مدفوعة', Icons.check_circle, AppColors.success),
              _buildFilterChip('جزئية', Icons.payments, AppColors.info),
            ],
          ),
          const SizedBox(height: 24),

          // قسم الترتيب
          _buildSectionTitle('الترتيب'),
          const SizedBox(height: 12),
          
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildSortChip('التاريخ', Icons.calendar_today),
              _buildSortChip('المبلغ', Icons.attach_money),
              _buildSortChip('العميل', Icons.person),
              _buildSortChip('الاستحقاق', Icons.event_available),
            ],
          ),
          const SizedBox(height: 24),

          // أزرار الإجراءات
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _selectedFilter = 'الكل';
                      _selectedSortBy = 'التاريخ';
                    });
                    widget.onFilterChanged('الكل');
                    widget.onSortChanged('التاريخ');
                  },
                  child: const Text('إعادة تعيين'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () {
                    widget.onFilterChanged(_selectedFilter);
                    widget.onSortChanged(_selectedSortBy);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  child: const Text('تطبيق'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.bodyLarge.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildFilterChip(String label, IconData icon, Color? color) {
    final isSelected = _selectedFilter == label;
    final chipColor = color ?? AppColors.primary;

    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 18,
            color: isSelected ? AppColors.textOnDark : chipColor,
          ),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = label;
        });
      },
      selectedColor: chipColor,
      backgroundColor: AppColors.backgroundSecondary,
      labelStyle: AppTextStyles.bodyMedium.copyWith(
        color: isSelected ? AppColors.textOnDark : AppColors.textPrimary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      checkmarkColor: AppColors.textOnDark,
    );
  }

  Widget _buildSortChip(String label, IconData icon) {
    final isSelected = _selectedSortBy == label;

    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 18,
            color: isSelected ? AppColors.textOnDark : AppColors.primary,
          ),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedSortBy = label;
        });
      },
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.backgroundSecondary,
      labelStyle: AppTextStyles.bodyMedium.copyWith(
        color: isSelected ? AppColors.textOnDark : AppColors.textPrimary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      checkmarkColor: AppColors.textOnDark,
    );
  }
}

/// عرض الفلترة كـ Bottom Sheet
Future<void> showDebtFilters({
  required BuildContext context,
  required String selectedFilter,
  required String selectedSortBy,
  required Function(String) onFilterChanged,
  required Function(String) onSortChanged,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => DebtFilters(
      selectedFilter: selectedFilter,
      selectedSortBy: selectedSortBy,
      onFilterChanged: onFilterChanged,
      onSortChanged: onSortChanged,
    ),
  );
}

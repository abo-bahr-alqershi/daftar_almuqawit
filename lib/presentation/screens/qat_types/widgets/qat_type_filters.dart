import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// فلترة وتصفية أنواع القات
/// 
/// يوفر خيارات متعددة لتصفية قائمة أنواع القات
class QatTypeFilters extends StatefulWidget {
  final String selectedFilter;
  final String selectedSortBy;
  final Function(String) onFilterChanged;
  final Function(String) onSortChanged;

  const QatTypeFilters({
    super.key,
    this.selectedFilter = 'الكل',
    this.selectedSortBy = 'الاسم',
    required this.onFilterChanged,
    required this.onSortChanged,
  });

  @override
  State<QatTypeFilters> createState() => _QatTypeFiltersState();
}

class _QatTypeFiltersState extends State<QatTypeFilters> {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'تصفية أنواع القات',
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

          _buildSectionTitle('حسب الجودة'),
          const SizedBox(height: 12),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildFilterChip('الكل', Icons.all_inclusive, null),
              _buildFilterChip('ممتاز', Icons.star, AppColors.success),
              _buildFilterChip('جيد جداً', Icons.star_half, AppColors.info),
              _buildFilterChip('جيد', Icons.thumb_up, AppColors.primary),
              _buildFilterChip('متوسط', Icons.thumbs_up_down, AppColors.warning),
              _buildFilterChip('عادي', Icons.thumb_down, AppColors.textSecondary),
            ],
          ),
          const SizedBox(height: 24),

          _buildSectionTitle('الترتيب'),
          const SizedBox(height: 12),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildSortChip('الاسم', Icons.sort_by_alpha),
              _buildSortChip('سعر الشراء', Icons.shopping_cart),
              _buildSortChip('سعر البيع', Icons.sell),
              _buildSortChip('الربح', Icons.trending_up),
            ],
          ),
          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _selectedFilter = 'الكل';
                      _selectedSortBy = 'الاسم';
                    });
                    widget.onFilterChanged('الكل');
                    widget.onSortChanged('الاسم');
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
Future<void> showQatTypeFilters({
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
    builder: (context) => QatTypeFilters(
      selectedFilter: selectedFilter,
      selectedSortBy: selectedSortBy,
      onFilterChanged: onFilterChanged,
      onSortChanged: onSortChanged,
    ),
  );
}

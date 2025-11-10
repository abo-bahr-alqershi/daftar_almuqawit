import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// محدد فئة المصروف
/// 
/// يوفر واجهة لاختيار فئة المصروف من قائمة محددة
class ExpenseCategorySelector extends StatelessWidget {
  final String? selectedCategory;
  final Function(String) onCategorySelected;

  const ExpenseCategorySelector({
    super.key,
    this.selectedCategory,
    required this.onCategorySelected,
  });

  static const List<Map<String, dynamic>> categories = [
    {'name': 'رواتب', 'icon': Icons.payment, 'color': Colors.blue},
    {'name': 'إيجار', 'icon': Icons.home, 'color': Colors.orange},
    {'name': 'كهرباء', 'icon': Icons.bolt, 'color': Colors.yellow},
    {'name': 'ماء', 'icon': Icons.water_drop, 'color': Colors.cyan},
    {'name': 'مواصلات', 'icon': Icons.directions_car, 'color': Colors.green},
    {'name': 'صيانة', 'icon': Icons.build, 'color': Colors.red},
    {'name': 'مشتريات', 'icon': Icons.shopping_cart, 'color': Colors.purple},
    {'name': 'اتصالات', 'icon': Icons.phone, 'color': Colors.indigo},
    {'name': 'تسويق', 'icon': Icons.campaign, 'color': Colors.pink},
    {'name': 'أخرى', 'icon': Icons.more_horiz, 'color': Colors.grey},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'اختر فئة المصروف',
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            final isSelected = selectedCategory == category['name'];

            return InkWell(
              onTap: () => onCategorySelected(category['name'] as String),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected
                      ? (category['color'] as Color).withOpacity(0.1)
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? (category['color'] as Color)
                        : AppColors.border,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      category['icon'] as IconData,
                      color: isSelected
                          ? (category['color'] as Color)
                          : AppColors.textSecondary,
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      category['name'] as String,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isSelected
                            ? (category['color'] as Color)
                            : AppColors.textPrimary,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

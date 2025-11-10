import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// فلاتر الموردين
class SupplierFilterChips extends StatelessWidget {
  final String? selectedTrustLevel;
  final int? selectedQualityRating;
  final void Function(String?) onTrustLevelChanged;
  final void Function(int?) onQualityRatingChanged;
  final VoidCallback? onClearFilters;

  const SupplierFilterChips({
    super.key,
    this.selectedTrustLevel,
    this.selectedQualityRating,
    required this.onTrustLevelChanged,
    required this.onQualityRatingChanged,
    this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    final hasActiveFilters = selectedTrustLevel != null || selectedQualityRating != null;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Clear Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  'تصفية حسب:',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const Spacer(),
                if (hasActiveFilters)
                  TextButton.icon(
                    onPressed: onClearFilters ?? () {
                      onTrustLevelChanged(null);
                      onQualityRatingChanged(null);
                    },
                    icon: Icon(
                      Icons.clear_all,
                      size: 16,
                      color: AppColors.danger,
                    ),
                    label: Text(
                      'مسح الفلاتر',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.danger,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Trust Level Filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildFilterChip(
                  label: 'موثوق',
                  icon: Icons.verified,
                  color: AppColors.success,
                  isSelected: selectedTrustLevel == 'موثوق',
                  onTap: () => onTrustLevelChanged(
                    selectedTrustLevel == 'موثوق' ? null : 'موثوق',
                  ),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'متوسط',
                  icon: Icons.warning_rounded,
                  color: AppColors.warning,
                  isSelected: selectedTrustLevel == 'متوسط',
                  onTap: () => onTrustLevelChanged(
                    selectedTrustLevel == 'متوسط' ? null : 'متوسط',
                  ),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'غير موثوق',
                  icon: Icons.cancel,
                  color: AppColors.danger,
                  isSelected: selectedTrustLevel == 'غير موثوق',
                  onTap: () => onTrustLevelChanged(
                    selectedTrustLevel == 'غير موثوق' ? null : 'غير موثوق',
                  ),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'جديد',
                  icon: Icons.fiber_new,
                  color: AppColors.info,
                  isSelected: selectedTrustLevel == 'جديد',
                  onTap: () => onTrustLevelChanged(
                    selectedTrustLevel == 'جديد' ? null : 'جديد',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Quality Rating Filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: List.generate(5, (index) {
                final rating = 5 - index;
                return Padding(
                  padding: EdgeInsets.only(left: index < 4 ? 8 : 0),
                  child: _buildRatingChip(
                    rating: rating,
                    isSelected: selectedQualityRating == rating,
                    onTap: () => onQualityRatingChanged(
                      selectedQualityRating == rating ? null : rating,
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required IconData icon,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: color,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? AppColors.textOnDark : color,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: isSelected ? AppColors.textOnDark : color,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingChip({
    required int rating,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final color = _getRatingColor(rating);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: color,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.star,
              size: 16,
              color: isSelected ? AppColors.textOnDark : color,
            ),
            const SizedBox(width: 4),
            Text(
              rating.toString(),
              style: AppTextStyles.labelSmall.copyWith(
                color: isSelected ? AppColors.textOnDark : color,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRatingColor(int rating) {
    if (rating >= 4) return AppColors.success;
    if (rating >= 3) return AppColors.warning;
    return AppColors.danger;
  }
}

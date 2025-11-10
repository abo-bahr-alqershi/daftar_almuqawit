import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../domain/entities/qat_type.dart';

/// محدد نوع القات (Grid View)
/// 
/// يعرض أنواع القات في شبكة لسهولة الاختيار
class QatTypeGridSelector extends StatelessWidget {
  final List<QatType> qatTypes;
  final int? selectedQatTypeId;
  final Function(QatType) onQatTypeSelected;

  const QatTypeGridSelector({
    super.key,
    required this.qatTypes,
    this.selectedQatTypeId,
    required this.onQatTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (qatTypes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.grid_view_outlined,
              size: 64,
              color: AppColors.textHint,
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد أنواع قات',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.1,
      ),
      itemCount: qatTypes.length,
      itemBuilder: (context, index) {
        final qatType = qatTypes[index];
        final isSelected = qatType.id == selectedQatTypeId;

        return InkWell(
          onTap: () => onQatTypeSelected(qatType),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withOpacity(0.1)
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  qatType.icon ?? '🌿',
                  style: const TextStyle(fontSize: 48),
                ),
                const SizedBox(height: 8),
                Text(
                  qatType.name,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? AppColors.primary : AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (qatType.qualityGrade != null) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getQualityColor(qatType.qualityGrade!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      qatType.qualityGrade!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textOnDark,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
                if (qatType.defaultSellPrice != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    '${qatType.defaultSellPrice!.toStringAsFixed(0)} ريال',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getQualityColor(String quality) {
    switch (quality.toLowerCase()) {
      case 'ممتاز':
        return AppColors.success;
      case 'جيد جداً':
        return AppColors.info;
      case 'جيد':
        return AppColors.primary;
      case 'متوسط':
        return AppColors.warning;
      default:
        return AppColors.textSecondary;
    }
  }
}

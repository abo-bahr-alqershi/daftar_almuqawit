import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../domain/entities/qat_type.dart';

/// محدد نوع القات (Grid View) - تصميم راقي هادئ
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

  Color _getQualityColor(String? quality) {
    switch (quality?.toLowerCase()) {
      case 'ممتاز':
        return AppColors.success;
      case 'جيد جداً':
        return AppColors.info;
      case 'جيد':
        return AppColors.primary;
      case 'متوسط':
      case 'عادي':
        return AppColors.warning;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (qatTypes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.background,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.grid_view_rounded,
                size: 64,
                color: AppColors.textHint,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'لا توجد أنواع قات',
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'أضف نوع قات جديد لبدء الاستخدام',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textHint,
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
        final qualityColor = _getQualityColor(qatType.qualityGrade);

        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            onQatTypeSelected(qatType);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isSelected
                    ? qualityColor.withOpacity(0.5)
                    : AppColors.border.withOpacity(0.2),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: qualityColor.withOpacity(0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        qualityColor.withOpacity(0.15),
                        qualityColor.withOpacity(0.08),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      qatType.icon ?? '🌿',
                      style: const TextStyle(fontSize: 36),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  qatType.name,
                  style: AppTextStyles.titleSmall.copyWith(
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: isSelected ? qualityColor : AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                if (qatType.qualityGrade != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [qualityColor, qualityColor.withOpacity(0.8)],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      qatType.qualityGrade!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                if (qatType.defaultSellPrice != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    '${qatType.defaultSellPrice!.toStringAsFixed(0)} ر.ي',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                ],
                if (isSelected)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [qualityColor, qualityColor.withOpacity(0.8)],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

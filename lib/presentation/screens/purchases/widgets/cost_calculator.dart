import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/currency_utils.dart';

/// بطاقة حاسبة التكلفة والدفع
class CostCalculator extends StatelessWidget {
  final double totalAmount;
  final double paidAmount;
  final double remainingAmount;

  const CostCalculator({
    super.key,
    required this.totalAmount,
    required this.paidAmount,
    required this.remainingAmount,
  });

  @override
  Widget build(BuildContext context) {
    final paymentPercentage = totalAmount > 0 ? (paidAmount / totalAmount) * 100 : 0;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.info.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                  ),
                  child: const Icon(
                    Icons.calculate,
                    color: AppColors.info,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppDimensions.spaceM),
                Text(
                  'ملخص الدفع',
                  style: AppTextStyles.headlineSmall.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spaceL),
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingM),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  _buildRow(
                    icon: Icons.shopping_cart,
                    label: 'إجمالي المشتريات',
                    value: CurrencyUtils.format(totalAmount),
                    color: AppColors.primary,
                    isLarge: true,
                  ),
                  const Divider(height: 24),
                  _buildRow(
                    icon: Icons.check_circle,
                    label: 'المبلغ المدفوع',
                    value: CurrencyUtils.format(paidAmount),
                    color: AppColors.success,
                  ),
                  const SizedBox(height: 12),
                  _buildRow(
                    icon: Icons.pending,
                    label: 'المبلغ المتبقي',
                    value: CurrencyUtils.format(remainingAmount),
                    color: remainingAmount > 0 ? AppColors.debt : AppColors.success,
                  ),
                ],
              ),
            ),
            if (remainingAmount > 0) ...[
              const SizedBox(height: AppDimensions.spaceM),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'نسبة الدفع',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        '${paymentPercentage.toStringAsFixed(1)}%',
                        style: AppTextStyles.titleMedium.copyWith(
                          color: _getProgressColor(paymentPercentage),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: paymentPercentage / 100,
                      backgroundColor: AppColors.disabled.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getProgressColor(paymentPercentage),
                      ),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    bool isLarge = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: isLarge ? 22 : 18,
              color: color,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: (isLarge
                      ? AppTextStyles.titleMedium
                      : AppTextStyles.bodyMedium)
                  .copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: (isLarge
                  ? AppTextStyles.headlineSmall
                  : AppTextStyles.titleMedium)
              .copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Color _getProgressColor(double percentage) {
    if (percentage >= 80) {
      return AppColors.success;
    } else if (percentage >= 50) {
      return AppColors.warning;
    } else {
      return AppColors.danger;
    }
  }
}


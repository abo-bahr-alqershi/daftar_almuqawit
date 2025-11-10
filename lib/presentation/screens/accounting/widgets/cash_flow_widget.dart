import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/currency_utils.dart';

/// ويدجت عرض التدفق النقدي
class CashFlowWidget extends StatelessWidget {
  final double income;
  final double expenses;
  final DateTime date;

  const CashFlowWidget({
    super.key,
    required this.income,
    required this.expenses,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    final netCashFlow = income - expenses;
    final isPositive = netCashFlow >= 0;

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
                    Icons.swap_vert,
                    color: AppColors.info,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppDimensions.spaceM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'التدفق النقدي',
                        style: AppTextStyles.headlineSmall.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        date.toIso8601String().split('T')[0],
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppDimensions.spaceL),

            _buildFlowRow(
              icon: Icons.arrow_downward,
              label: 'التدفقات الداخلة',
              amount: income,
              color: AppColors.success,
            ),

            const SizedBox(height: AppDimensions.spaceM),

            _buildFlowRow(
              icon: Icons.arrow_upward,
              label: 'التدفقات الخارجة',
              amount: expenses,
              color: AppColors.danger,
            ),

            const Divider(height: 24),

            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingM),
              decoration: BoxDecoration(
                color: isPositive
                    ? AppColors.success.withOpacity(0.1)
                    : AppColors.danger.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                border: Border.all(
                  color: isPositive ? AppColors.success : AppColors.danger,
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        isPositive ? Icons.trending_up : Icons.trending_down,
                        color: isPositive ? AppColors.success : AppColors.danger,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'صافي التدفق النقدي',
                        style: AppTextStyles.titleMedium.copyWith(
                          color: isPositive ? AppColors.success : AppColors.danger,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    CurrencyUtils.format(netCashFlow),
                    style: AppTextStyles.titleLarge.copyWith(
                      color: isPositive ? AppColors.success : AppColors.danger,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppDimensions.spaceM),

            _buildPercentageBar(income, expenses),
          ],
        ),
      ),
    );
  }

  Widget _buildFlowRow({
    required IconData icon,
    required String label,
    required double amount,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppDimensions.radiusS),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: AppDimensions.spaceM),
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Text(
          CurrencyUtils.format(amount),
          style: AppTextStyles.titleMedium.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildPercentageBar(double income, double expenses) {
    final total = income + expenses;
    final incomePercentage = total > 0 ? (income / total) * 100 : 0;
    final expensesPercentage = total > 0 ? (expenses / total) * 100 : 0;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'النسب المئوية',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            Row(
              children: [
                _buildLegendItem('داخلة', AppColors.success),
                const SizedBox(width: 12),
                _buildLegendItem('خارجة', AppColors.danger),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Row(
            children: [
              if (income > 0)
                Expanded(
                  flex: income.toInt(),
                  child: Container(
                    height: 12,
                    color: AppColors.success,
                  ),
                ),
              if (expenses > 0)
                Expanded(
                  flex: expenses.toInt(),
                  child: Container(
                    height: 12,
                    color: AppColors.danger,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${incomePercentage.toStringAsFixed(1)}%',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.success,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${expensesPercentage.toStringAsFixed(1)}%',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.danger,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

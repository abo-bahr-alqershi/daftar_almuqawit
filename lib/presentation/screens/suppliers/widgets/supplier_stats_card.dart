import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// بطاقة إحصائيات المورد
class SupplierStatsCard extends StatelessWidget {
  final int totalSuppliers;
  final double totalPurchases;
  final double totalDebt;
  final int trustedSuppliers;
  final double averageRating;

  const SupplierStatsCard({
    super.key,
    required this.totalSuppliers,
    required this.totalPurchases,
    required this.totalDebt,
    required this.trustedSuppliers,
    required this.averageRating,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.analytics,
                color: AppColors.textOnDark,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'إحصائيات الموردين',
                style: AppTextStyles.titleLarge.copyWith(
                  color: AppColors.textOnDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Stats Grid
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: Icons.people,
                  label: 'إجمالي الموردين',
                  value: totalSuppliers.toString(),
                  color: AppColors.textOnDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.verified,
                  label: 'موردين موثوقين',
                  value: trustedSuppliers.toString(),
                  color: AppColors.textOnDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: Icons.shopping_cart,
                  label: 'إجمالي المشتريات',
                  value: '${totalPurchases.toStringAsFixed(0)} ر.س',
                  color: AppColors.textOnDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.account_balance_wallet,
                  label: 'إجمالي الديون',
                  value: '${totalDebt.toStringAsFixed(0)} ر.س',
                  color: AppColors.textOnDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Average Rating
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.textOnDark.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.star,
                  color: AppColors.textOnDark,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'متوسط التقييم: ${averageRating.toStringAsFixed(1)}',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.textOnDark,
                  ),
                ),
                const SizedBox(width: 8),
                ...List.generate(5, (index) {
                  return Icon(
                    index < averageRating.floor()
                        ? Icons.star
                        : index < averageRating
                            ? Icons.star_half
                            : Icons.star_border,
                    color: AppColors.textOnDark,
                    size: 18,
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 28,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.titleMedium.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: color.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
